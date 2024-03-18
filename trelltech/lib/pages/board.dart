import 'package:flutter/material.dart';
import 'package:trelltech/controllers/board_controller.dart';

import 'package:trelltech/controllers/card_controller.dart';
import 'package:trelltech/controllers/list_controller.dart';
import 'package:trelltech/models/board_model.dart';
import 'package:trelltech/models/card_model.dart';
import 'package:trelltech/models/list_model.dart';
import 'package:trelltech/widgets/appbar.dart';

class BoardPage extends StatefulWidget {
  const BoardPage({super.key, required this.board}) : assert(board != null);
  final BoardModel board;

  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  final ListController _listsController = ListController();
  final CardController _cardsController = CardController();
  final BoardController _boardController = BoardController();
  List<ListModel> lists = [];

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  void _loadInfo() async {
    final fetchedLists = await _listsController.getLists(board: widget.board);
    setState(() {
      lists = fetchedLists;
    });
  }

  // Method to handle button tap and show popup dialog
  void _showCreateListDialog() {
    TextEditingController _textFieldController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Create List"),
          content: TextField(
            controller: _textFieldController,
            decoration: InputDecoration(hintText: "Enter list name"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Create"),
              onPressed: () {
                String name = _textFieldController.text;
                if (name.isNotEmpty) {
                  _createList(name);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _createList(String name) async {
    try {
      // Add the new list
      _listsController.create(name, board: widget.board);

      // Fetch the updated list of lists
      List<ListModel> updatedLists =
          await _listsController.getLists(board: widget.board);

      // Update the state to reflect the new list of lists
      setState(() {
        lists = updatedLists;
      });
    } catch (e) {
      print("Error creating list: $e");
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    final board = widget.board;
    return Scaffold(
      appBar: appbar(text: board.name, color: Colors.blue),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Container(
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: lists.length + 1, // Add one for the button
              itemBuilder: (BuildContext context, int index) {
                if (index < lists.length) {
                  return _buildList(lists[index]);
                } else {
                  // Render the button at the end of the list
                  return Center(
                    child: SizedBox(
                      height: 50,
                      width: 300,
                      child: GestureDetector(
                        onTap: () {
                          // Show the create list dialog
                          _showCreateListDialog();
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: const Text(
                            'Add List',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildList(ListModel list) {
    return FutureBuilder<List<CardModel>>(
      future: _cardsController.getCards(list: list),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final cards = snapshot.data!;
          return Container(
            width: 300,
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Stack(
              children: [
                // List header
                Container(
                    height: 50,
                    color: Colors.black,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Padding(padding: EdgeInsets.only(left: 16.0)),
                        Expanded(
                          child: Text(list.name,
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              )),
                        ),
                        IconButton(
                          // Add your button here
                          icon: const Icon(Icons.more_vert), // Example icon
                          color: Colors.white,
                          onPressed: () {
                            // Handle button press logic here (optional)
                          },
                        ),
                      ],
                    )),
                // List body
                Positioned.fill(
                  top: 50.0,
                  child: ListView.builder(
                    itemCount: cards.length,
                    itemBuilder: (context, index) => _buildCard(cards[index]),
                  ),
                ),
                // List footer (optional, can be removed)
                Positioned(
                  bottom: 0.0,
                  left: 0.0,
                  // right: 0.0,
                  child: _buildAddCardRow(list.id),
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        // Display a loading indicator while fetching cards
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildAddCardRow(listId) {
    // text at the bottom of the list
    return Container(
      padding: const EdgeInsets.all(16.0),
      height: 75,
      width: 75,
      child: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return SizedBox(
                height: 600,
                child: Center(
                  child: Form(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: TextFormField(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Enter a title for this card...",
                            ),
                            onFieldSubmitted: (String value) {
                              _cardsController.create(listId, value);
                              Navigator.of(context).pop();
                              _loadInfo();
                            },
                          )
                        )
                      ],
                    )
                  )
                )
              );
            }
          );
          // _cardsController.create(listId);
          // _loadInfo();
          // setState(() {});
        },
        tooltip: 'Increment Counter',
        backgroundColor: const Color.fromARGB(255, 229, 229, 229),
        shape: const CircleBorder(),
        child: const Text("+"),
      )
    );
  }

  Widget _buildCard(CardModel card) {
    return Container(
      margin: const EdgeInsets.all(12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 95, 95, 95),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            // Wrap text widget with Expanded
            child: Text(
              card.name,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white, // Text color for header
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

}
