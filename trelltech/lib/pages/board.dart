import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import 'package:trelltech/controllers/board_controller.dart';
import 'package:trelltech/controllers/card_controller.dart';
import 'package:trelltech/controllers/list_controller.dart';
import 'package:trelltech/models/board_model.dart';
import 'package:trelltech/models/card_model.dart';
import 'package:trelltech/models/list_model.dart';
import 'package:trelltech/widgets/appbar.dart';

class BoardPage extends StatefulWidget {
  const BoardPage(
      {super.key, required this.board, this.boardColor = Colors.blue})
      : assert(board != null);
  final BoardModel board;
  final Color boardColor;

  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  final ListController _listsController = ListController();
  final CardController _cardsController = CardController();
  final BoardController _boardController = BoardController();
  final TextEditingController _textEditingController = TextEditingController(text: "Initial Text");
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
  void _createListDialog() {
    TextEditingController _textFieldController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Create List"),
          content: TextField(
            controller: _textFieldController,
            decoration: const InputDecoration(
              hintText: "Enter list name",
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color.fromARGB(255, 49, 49, 49)), // Change underline color
              ),
            ),
            cursorColor: const Color.fromARGB(255, 49, 49, 49),
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
                  _listsController.create(name, board: widget.board,
                      onCreated: () {
                    _loadInfo();
                  });
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
            decoration: const InputDecoration(
              hintText: "Enter new list name",
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color.fromARGB(255, 49, 49, 49)), // Change underline color
              ),
            ),
            cursorColor: const Color.fromARGB(255, 49, 49, 49),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Edit"),
              onPressed: () {
                String name = _textFieldController.text;
                if (name.isNotEmpty) {
                  _listsController.update(
                      id: listId,
                      name: name,
                      onUpdated: () {
                        _loadInfo();
                      });
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
    final boardColor = widget.boardColor;
    return Scaffold(
      appBar: appbar(
          text: board.name,
          color: boardColor,
          showEditButton: true,
          onDelete: () {
            _boardController.delete(
                id: board.id,
                onDeleted: () {
                  _loadInfo();
                });
            Navigator.of(context).pop();
          },
          onEdit: () {
            _textEditingController.text = board.name;
            showModalBottomSheet(
                backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                context: context,
                builder: (BuildContext context) {
                  return SizedBox(
                      height: 600,
                      child: Center(
                          // child: Text('Your modal content goes here'),
                          child: Form(
                              child: Column(
                        children: [
                          Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: TextFormField(
                                autofocus: true,
                                controller: _textEditingController,
                                decoration: const InputDecoration(
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color.fromARGB(255, 49, 49, 49)), // Change underline color
                                  ),
                                ),
                                cursorColor: const Color.fromARGB(255, 49, 49, 49),
                                onFieldSubmitted: (String value) {
                                  _boardController.update(
                                      id: board.id,
                                      name: value,
                                      onUpdated: () {
                                        _loadInfo();
                                      });
                                  Navigator.of(context).pop();
                                  setState(() {
                                    board.name = value;
                                  });
                                },
                              ))
                        ],
                      ))));
                });
          }),
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
                          _createListDialog();
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
            title: Text('Edit'),
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
        _listsController.delete(
            id: list.id,
            onDeleted: () {
              _loadInfo();
            });
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
            _textEditingController.text = "";
            showModalBottomSheet(
                backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                context: context,
                builder: (BuildContext context) {
                  return SizedBox(
                      height: 600,
                      child: Center(
                          child: Form(
                              child: Column(
                        children: [
                          Expanded(
                            child: ListView(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    
                                    _cardsController.create(listId, _textEditingController.text);
                                    Navigator.of(context).pop();
                                    _loadInfo();
                                  },
                                  child: const Text("Create"),
                                        
                                ),
                                Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: TextFormField(
                                      autofocus: true,
                                      controller: _textEditingController,
                                      decoration: const InputDecoration(
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Color.fromARGB(255, 49, 49, 49)), // Change underline color
                                        ),
                                        hintText: "Enter a title for this card...",
                                      ),
                                      cursorColor: const Color.fromARGB(255, 49, 49, 49),
                                      maxLines: null,
                                      // onFieldSubmitted: (String value) {
                                      //   _cardsController.create(listId, value);
                                      //   Navigator.of(context).pop();
                                      //   _loadInfo();
                                      // },
                                    )
                                )
                              ]
                            )
                          )
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
      child: GestureDetector(
        onLongPress: () {
          showMenu(
            context: context, 
            position: const RelativeRect.fromLTRB(0, 200, 0, 0), 
            items: <PopupMenuEntry>
            [
              PopupMenuItem(child: ListTile(
                title: const Text('Delete card'),
                onTap: () {
                  _cardsController.delete(card.id);
                  Navigator.of(context).pop();
                  _loadInfo();
                }
              )),
              PopupMenuItem(child: ListTile(
                title: const Text("Edit card"),
                onTap: () {
                  _textEditingController.text = card.name;
                  showModalBottomSheet(
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    context: context,
                    builder: (BuildContext context) {
                      return SizedBox(
                        height: 600,
                        child: Center(
                          child: Form(
                            child: Column(
                              children: [
                                Expanded(
                                  child: ListView(
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          _cardsController.update(card.id, _textEditingController.text);
                                          Navigator.of(context).pop();
                                          _loadInfo();
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text("Edit"),
                                        
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                            child: TextFormField(
                                              autofocus: true,
                                              controller: _textEditingController,
                                              decoration: const InputDecoration(
                                                focusedBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(color: Color.fromARGB(255, 49, 49, 49)), // Change underline color
                                                ),
                                              ),
                                              cursorColor: const Color.fromARGB(255, 49, 49, 49),
                                              maxLines: null,
                                              // onFieldSubmitted: (String value) {
                                              //   _cardsController.update(card.id, value);
                                              //   Navigator.of(context).pop();
                                              //   _loadInfo();
                                              //   Navigator.of(context).pop();
                                              // },
                                              
                                            )
                                          
                                      )
                                    ]
                                  )
                                )
                              ],
                            )
                          )
                        )
                      );
                    }
                  );
                  // Navigator.of(context).pop();
                }
              ))
            ]
          );
        },
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
