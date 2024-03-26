// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:trelltech/controllers/board_controller.dart';
import 'package:trelltech/controllers/card_controller.dart';
import 'package:trelltech/controllers/list_controller.dart';
import 'package:trelltech/controllers/member_controller.dart';
import 'package:trelltech/models/board_model.dart';
import 'package:trelltech/models/card_model.dart';
import 'package:trelltech/models/list_model.dart';
import 'package:trelltech/models/member_model.dart';
import 'package:trelltech/utils/materialcolor_utils.dart';
import 'package:trelltech/widgets/appbar.dart';

import 'card.dart';

class BoardPage extends StatefulWidget {
  const BoardPage(
      {super.key, required this.board, this.boardColor = Colors.blue});
  final BoardModel board;
  final Color boardColor;

  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  final ListController _listsController = ListController();
  final CardController _cardsController = CardController();
  final BoardController _boardController = BoardController();
  final MemberController _memberController = MemberController();
  final TextEditingController _textEditingController =
      TextEditingController(text: "Initial Text");
  List<ListModel> lists = [];
  List<List<CardModel>> allCards = []; // Store cards for each list
  List<MemberModel> members = [];
  Map<String, List<MemberModel>> cardAssignedMembers = {};

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  void _loadInfo() async {
    final fetchedLists = await _listsController.getLists(board: widget.board);
    final fetchedCards = await Future.wait(
        fetchedLists.map((list) => _cardsController.getCards(list: list)));
    setState(() {
      lists = fetchedLists;
      allCards = fetchedCards;
      _loadMembers();
    });
  }

  void _loadMembers() async {
    try {
      List<MemberModel> boardMembers =
          await _memberController.getBoardMembers(widget.board.id);
      List<MemberModel> allMembers = List.from(boardMembers);

      for (List<CardModel> cardList in allCards) {
        for (CardModel card in cardList) {
          List<MemberModel> cardMemberList =
              await _memberController.getCardMembers(card.id);

          for (MemberModel member in cardMemberList) {
            member.cardIds.add(card.id);
          }
          allMembers.addAll(cardMemberList);
        }
      }

      setState(() {
        members = allMembers;
      });
    } catch (e) {
      print('Error loading members: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('members: $members');
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
            },
          );
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
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 49, 49, 49),
                                ),
                              ),
                            ),
                            cursorColor: const Color.fromARGB(255, 49, 49, 49),
                            onFieldSubmitted: (String value) {
                              _boardController.update(
                                id: board.id,
                                name: value,
                                onUpdated: () {
                                  _loadInfo();
                                },
                              );
                              Navigator.of(context).pop();
                              setState(() {
                                board.name = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Container(
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: lists.length + 1, // Add one for the button
              itemBuilder: (BuildContext context, int index) {
                if (index < lists.length) {
                  return _buildList(lists[index], allCards[index]);
                } else {
                  // Render the button at the end of the list
                  return Center(
                    child: SizedBox(
                      height: 50,
                      width: 300,
                      child: GestureDetector(
                        onTap: () {
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

  Widget _buildList(ListModel list, List<CardModel> cards) {
    final boardColor = widget.boardColor;
    return Container(
      width: 300,
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: getMaterialColor(boardColor).shade300,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // List header
          Container(
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
              color: getMaterialColor(boardColor).shade400,
            ),
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
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  color: Colors.white,
                  onPressed: () {
                    _showPopupMenu(context, list);
                  },
                ),
              ],
            ),
          ),
          // List body
          Expanded(
            child: ListView.builder(
              itemCount: cards.length,
              itemBuilder: (context, index) {
                final card = cards[index];
                return GestureDetector(
                  onTap: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CardPage(
                          card: card,
                          board: widget.board,
                          boardColor: widget.boardColor,
                          members: members,
                        ),
                      ),
                    );
                  },
                  child: _buildCard(card),
                );
              },
            ),
          ),
          // List footer
          _buildAddCardRow(list.id),
        ],
      ),
    );
  }

  void _createListDialog() {
    TextEditingController textFieldController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Create List"),
          content: TextField(
            controller: textFieldController,
            decoration: const InputDecoration(
              hintText: "Enter list name",
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                    color: Color.fromARGB(
                        255, 49, 49, 49)), // Change underline color
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
                String name = textFieldController.text;
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
    TextEditingController textFieldController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Update List"),
          content: TextField(
            controller: textFieldController,
            decoration: const InputDecoration(
              hintText: "Enter new list name",
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                    color: Color.fromARGB(
                        255, 49, 49, 49)), // Change underline color
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
                String name = textFieldController.text;
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
                              child: ListView(children: [
                            ElevatedButton(
                              onPressed: () {
                                _cardsController.create(
                                    listId, _textEditingController.text);
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
                                      borderSide: BorderSide(
                                          color: Color.fromARGB(255, 49, 49,
                                              49)), // Change underline color
                                    ),
                                    hintText: "Enter a title for this card...",
                                  ),
                                  cursorColor:
                                      const Color.fromARGB(255, 49, 49, 49),
                                  maxLines: null,
                                  // onFieldSubmitted: (String value) {
                                  //   _cardsController.create(listId, value);
                                  //   Navigator.of(context).pop();
                                  //   _loadInfo();
                                  // },
                                ))
                          ]))
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
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 58, 58, 58).withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: GestureDetector(
        onLongPress: () {
          showMenu(
              context: context,
              position: const RelativeRect.fromLTRB(0, 200, 0, 0),
              items: <PopupMenuEntry>[
                PopupMenuItem(
                    child: ListTile(
                        title: const Text('Delete card'),
                        onTap: () {
                          _cardsController.delete(card.id);
                          Navigator.of(context).pop();
                          _loadInfo();
                        })),
                PopupMenuItem(
                    child: ListTile(
                        title: const Text("Edit card"),
                        onTap: () {
                          _textEditingController.text = card.name;
                          showModalBottomSheet(
                              backgroundColor:
                                  const Color.fromARGB(255, 255, 255, 255),
                              context: context,
                              builder: (BuildContext context) {
                                return SizedBox(
                                    height: 600,
                                    child: Center(
                                        child: Form(
                                            child: Column(
                                      children: [
                                        Expanded(
                                            child: ListView(children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              _cardsController.update(card.id,
                                                  _textEditingController.text);
                                              Navigator.of(context).pop();
                                              _loadInfo();
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text("Edit"),
                                          ),
                                          Padding(
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                              child: TextFormField(
                                                autofocus: true,
                                                controller:
                                                    _textEditingController,
                                                decoration:
                                                    const InputDecoration(
                                                  focusedBorder:
                                                      UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Color.fromARGB(
                                                            255,
                                                            49,
                                                            49,
                                                            49)), // Change underline color
                                                  ),
                                                ),
                                                cursorColor:
                                                    const Color.fromARGB(
                                                        255, 49, 49, 49),
                                                maxLines: null,
                                                // onFieldSubmitted: (String value) {
                                                //   _cardsController.update(card.id, value);
                                                //   Navigator.of(context).pop();
                                                //   _loadInfo();
                                                //   Navigator.of(context).pop();
                                                // },
                                              ))
                                        ]))
                                      ],
                                    ))));
                              });
                          // Navigator.of(context).pop();
                        }))
              ]);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              // Wrap text widget with Expanded
              child: Text(
                card.name,
                style: const TextStyle(
                  fontSize: 16,
                  color:
                      Color.fromARGB(255, 46, 46, 46), // Text color for header
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
