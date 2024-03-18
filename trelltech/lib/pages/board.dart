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
  void _CreateListDialog() {
    TextEditingController _textFieldController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Create List"),
          content: TextField(
            controller: _textFieldController,
            decoration: const InputDecoration(hintText: "Enter list name"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Create"),
              onPressed: () {
                String name = _textFieldController.text;
                if (name.isNotEmpty) {
                  try {
                    _listsController.create(name, board: widget.board);
                    _loadInfo();
                  } catch (e) {
                    print("Error creating list: $e");
                    // Handle error
                  }
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _updateListDialog(listId) {
    TextEditingController _textFieldController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Update List"),
          content: TextField(
            controller: _textFieldController,
            decoration: const InputDecoration(hintText: "Enter new list name"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Update"),
              onPressed: () {
                String name = _textFieldController.text;
                if (name.isNotEmpty) {
                  try {
                    _listsController.update(id: listId, name: name);
                    _loadInfo();
                  } catch (e) {
                    print("Error updating list: $e");
                    // Handle error
                  }
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
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
                          _CreateListDialog();
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
                        child: Text(
                          list.name,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        color: Colors.white,
                        onPressed: () {
                          // Handle button press logic here to show the popup menu
                          _showPopupMenu(context, list);
                        },
                      ),
                    ],
                  ),
                ),
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
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  void _showPopupMenu(BuildContext context, ListModel list) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final Offset buttonPosition = button.localToGlobal(Offset.zero);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        buttonPosition.dx,
        buttonPosition.dy,
        buttonPosition.dx,
        buttonPosition.dy,
      ),
      items: [
        const PopupMenuItem(
          value: 'update',
          child: ListTile(
            leading: Icon(Icons.edit, color: Colors.blue),
            title: Text('Update'),
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete, color: Colors.red),
            title: Text('Delete'),
          ),
        ),
      ],
    ).then((value) {
      if (value == 'update') {
        _updateListDialog(list.id);
      } else if (value == 'delete') {
        _listsController.delete(id: list.id);
        _loadInfo();
      }
    });
  }

  Widget _buildAddCardRow(listId) {
    // list footer
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
                              ))
                        ],
                      ))));
                });
            // _cardsController.create(listId);
            // _loadInfo();
            // setState(() {});
          },
          tooltip: 'Increment Counter',
          backgroundColor: const Color.fromARGB(255, 229, 229, 229),
          shape: const CircleBorder(),
          child: const Text("+"),
        ));
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
