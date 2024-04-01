// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:trelltech/controllers/board_controller.dart';
import 'package:trelltech/controllers/card_controller.dart';
import 'package:trelltech/controllers/list_controller.dart';
import 'package:trelltech/controllers/member_controller.dart';
import 'package:trelltech/models/board_model.dart';
import 'package:trelltech/models/card_model.dart';
import 'package:trelltech/models/list_model.dart';
import 'package:trelltech/models/member_model.dart';
import 'package:trelltech/utils/colormap_utils.dart';
import 'package:trelltech/utils/materialcolor_utils.dart';
import 'package:trelltech/widgets/appbar.dart';
import 'package:trelltech/widgets/member_avatar.dart';

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
  final ScrollController _scrollController = ScrollController();
  Timer? autoScrollTimer;
  final Map<String, GlobalKey> listKeys = {};
  final TextEditingController _textEditingController =
      TextEditingController(text: "Initial Text");
  List<ListModel> lists = [];
  List<List<CardModel>> allCards = [];
  List<MemberModel> members = [];

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  void _loadInfo() async {
    loadBoardMembers();
    final fetchedLists = await _listsController.getLists(board: widget.board);
    final fetchedCards = await Future.wait(
        fetchedLists.map((list) => _cardsController.getCards(list: list)));
    setState(() {
      lists = fetchedLists;
      allCards = fetchedCards;
      _loadCardMembers();
    });
  }

  void updateCardById(String cardId,
      {String? name, String? startDate, String? dueDate}) {
    for (int i = 0; i < allCards.length; i++) {
      int index = allCards[i].indexWhere((card) => card.id == cardId);
      if (index != -1) {
        CardModel updatedCard = allCards[i][index];
        if (name != null) {
          updatedCard.name = name;
        }
        if (startDate != null) {
          updatedCard.startDate = startDate;
        }
        if (dueDate != null) {
          updatedCard.dueDate = dueDate;
        }

        setState(() {
          allCards[i][index] = updatedCard;
        });
        break;
      }
    }
  }

  void loadBoardMembers() async {
    int index = 0;
    try {
      List<MemberModel> boardMembers =
          await _memberController.getBoardMembers(widget.board.id);

      // Generate initials for board members
      for (MemberModel member in boardMembers) {
        member.initials = generateInitials(member.name);
        member.color = Colors.primaries.elementAt(index % 18);
        index += 1;
      }

      setState(() {
        members = List.from(boardMembers);
      });
    } catch (e) {
      print('Error loading members: $e');
    }
  }

  void _loadCardMembers() async {
    try {
      for (List<CardModel> cardList in allCards) {
        for (CardModel card in cardList) {
          List<MemberModel> cardMemberList =
              await _memberController.getCardMembers(card.id);

          for (MemberModel member in cardMemberList) {
            // Check if the member already exists in members list
            MemberModel existingMember = members.firstWhere(
              (m) => m.id == member.id,
              orElse: () => member,
            );

            // Add cardId to member's cardIds list if it's not already present
            if (!existingMember.cardIds.contains(card.id)) {
              existingMember.cardIds.add(card.id);
            }

            // If the member was not already in the list, add it
            if (!members.contains(existingMember)) {
              members.add(existingMember);
            }
          }
        }
      }

      setState(() {
        print("_loadMembers executed sucessfully");
      });
    } catch (e) {
      print('Error loading members: $e');
    }
  }

  void updateMemberCardIds(String memberId, String newCardId, bool isAdding) {
    int index = members.indexWhere((member) => member.id == memberId);
    if (index != -1) {
      MemberModel updatedMember = members[index];

      // Add or remove the card ID based on the 'add' flag
      if (isAdding) {
        updatedMember.cardIds.add(newCardId);
      } else {
        updatedMember.cardIds.remove(newCardId);
      }

      setState(() {
        members[index] = updatedMember;
      });
    }
  }

  String generateInitials(String name) {
    List<String> nameParts = name.split(' ');
    String initials = '';

    // Take the first letter of each word in the name
    for (String part in nameParts) {
      initials += part[0];
    }

    return initials.toUpperCase();
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
              ),
            ),

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
                            updateCardById: updateCardById,
                            updateMemberCardIds: updateMemberCardIds,
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
    return Column(
      children: [
        if (getColorFromString(card.coverColor) != Colors.transparent)
          Container(
            height: 30,
            margin:
                const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 0),
            decoration: BoxDecoration(
              color: getColorFromString(card.coverColor),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
          ),
        Container(
          margin: getColorFromString(card.coverColor) != Colors.transparent
              ? const EdgeInsets.only(
                  left: 12.0,
                  right: 12.0,
                  top: 0.0,
                  bottom: 8.0,
                )
              : const EdgeInsets.all(12.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 255),
            borderRadius:
                getColorFromString(card.coverColor) != Colors.transparent
                    ? const BorderRadius.only(
                        bottomLeft: Radius.circular(20.0),
                        bottomRight: Radius.circular(20.0),
                      )
                    : const BorderRadius.all(Radius.circular(20.0)),
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
                                                  _cardsController.update(
                                                      cardId: card.id,
                                                      name:
                                                          _textEditingController
                                                              .text);
                                                  Navigator.of(context).pop();
                                                  _loadInfo();
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text("Edit"),
                                              ),
                                              Padding(
                                                  padding: const EdgeInsets.all(
                                                      16.0),
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
                                                  ))
                                            ]))
                                          ],
                                        ))));
                                  });
                              // Navigator.of(context).pop();
                            }))
                  ]);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      // Wrap text widget with Expanded
                      child: Text(
                        card.name,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(
                              255, 46, 46, 46), // Text color for header
                        ),
                      ),
                    ),
                  ],
                ),
                // Liste des labels de la carte
                Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: List<Widget>.generate(
                    card.label.length,
                    (int index) {
                      return Material(
                        color: getColorFromString(card.label[index].color),
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30.0, vertical: 0.0),
                          child: Text(
                            card.label[index].name,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    avatarRow(
                      avatars: members
                          .where((member) => member.cardIds.contains(card.id))
                          .map((member) => MemberAvatar(
                                initials: member.initials ?? '',
                                color: member.color ?? Colors.blue,
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget avatarRow({required List<Widget> avatars}) {
    return Row(
      children: avatars
          .map((avatar) => Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: avatar,
              ))
          .toList(),
    );
  }
}
