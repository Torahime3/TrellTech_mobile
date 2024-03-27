import 'dart:async';

import 'package:flutter/material.dart';
import 'package:trelltech/controllers/board_controller.dart';
import 'package:trelltech/controllers/card_controller.dart';
import 'package:trelltech/controllers/list_controller.dart';
import 'package:trelltech/models/board_model.dart';
import 'package:trelltech/models/card_model.dart';
import 'package:trelltech/models/list_model.dart';
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
  final ScrollController _scrollController = ScrollController();
  Timer? autoScrollTimer;
  final Map<String, GlobalKey> listKeys = {};
  final TextEditingController _textEditingController =
      TextEditingController(text: "Initial Text");
  List<ListModel> lists = [];
  List<List<CardModel>> allCards = []; // Store cards for each list

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
    });
  }

  void moveListBetween(
      ListModel listMoved, ListModel firstList, ListModel secondList) {
    listMoved.moveListBetween(firstList, secondList);
    lists.sort((a, b) => a.pos.compareTo(b.pos));
    _loadInfo();
  }

  void startAutoScroll(double direction) {
    autoScrollTimer?.cancel();

    autoScrollTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (_scrollController.hasClients) {
        double newPosition = _scrollController.position.pixels + direction;
        if (newPosition < _scrollController.position.minScrollExtent) {
          newPosition = _scrollController.position.minScrollExtent;
          stopAutoScroll();
        } else if (newPosition > _scrollController.position.maxScrollExtent) {
          newPosition = _scrollController.position.maxScrollExtent;
          stopAutoScroll();
        }
        _scrollController.jumpTo(newPosition);
      }
    });
  }

  void stopAutoScroll() {
    autoScrollTimer?.cancel();
    autoScrollTimer = null;
  }

  void onDragUpdate(DragUpdateDetails details) {
    final screenSize = MediaQuery.of(context).size;
    final position = details.globalPosition;

    if (position.dx > screenSize.width - 100) {
      startAutoScroll(5.0);
    } else if (position.dx < 100) {
      startAutoScroll(-5.0);
    } else {
      stopAutoScroll();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    autoScrollTimer?.cancel();
    stopAutoScroll();
    super.dispose();
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
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: lists.length + 1, // Add one for the button
              itemBuilder: (BuildContext context, int index) {
                if (index < lists.length) {
                  return _buildList(lists[index], allCards[index], index);
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

  Widget _buildList(ListModel list, List<CardModel> cards, int index) {
    final boardColor = widget.boardColor;
    listKeys[list.id] ??= GlobalKey();
    final GlobalKey currentListKey = listKeys[list.id]!;

    return DragTarget<ListModel>(onWillAcceptWithDetails:
        (DragTargetDetails<ListModel> incomingListData) {
      return incomingListData.data.id != list.id;
    }, onAcceptWithDetails: (DragTargetDetails<ListModel> details) {
      final RenderBox renderBox =
          currentListKey.currentContext?.findRenderObject() as RenderBox;
      final Offset targetCenter =
          renderBox.localToGlobal(renderBox.size.center(Offset.zero));
      final bool isLeft = (details.offset.dx + 100) < targetCenter.dx;
      final ListModel listDetails = details.data;
      if (isLeft) {
        if (index == 0) {
          return;
        }
        moveListBetween(listDetails, lists[index], lists[index - 1]);
      } else {
        if (index == lists.length - 1) {
          return;
        }
        moveListBetween(listDetails, lists[index], lists[index + 1]);
      }
    }, builder: (BuildContext context, List<ListModel?> candidateData,
        List<dynamic> rejectedData) {
      return Container(
        key: currentListKey,
        width: 300,
        margin: index == 0
            ? const EdgeInsets.only(
                left: 36.0, right: 12.0, top: 12.0, bottom: 12.0)
            : const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: getMaterialColor(boardColor).shade300,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //
            // List header
            //

            Listener(
              onPointerMove: (PointerMoveEvent pme) {
                final screenSize = MediaQuery.of(context).size;
                final position = pme.position;

                if (position.dx > screenSize.width - 20) {
                  startAutoScroll(13.0);
                } else if (position.dx < 20) {
                  startAutoScroll(-13.0);
                } else {
                  stopAutoScroll();
                }
              },
              onPointerUp: (PointerUpEvent pue) {
                stopAutoScroll();
              },
              child: LongPressDraggable<ListModel>(
                data: list,
                feedback: Container(
                  height: 50,
                  width: 200,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                      bottomLeft: Radius.circular(20.0),
                      bottomRight: Radius.circular(20.0),
                    ),
                    color: getMaterialColor(boardColor).shade600,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Padding(padding: EdgeInsets.only(left: 16.0)),
                      Expanded(
                        child: Text(
                          '${list.name} | ${list.pos}',
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
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
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
                          '${list.name} | ${list.pos}',
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
              ),
            ),

            //
            // List body
            //

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
    });
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
