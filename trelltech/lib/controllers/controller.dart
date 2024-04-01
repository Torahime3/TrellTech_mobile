import 'dart:async';

import 'package:flutter/material.dart';
import 'package:trelltech/controllers/board_controller.dart';
import 'package:trelltech/controllers/card_controller.dart';
import 'package:trelltech/controllers/list_controller.dart';
import 'package:trelltech/controllers/member_controller.dart';
import 'package:trelltech/models/card_model.dart';
import 'package:trelltech/models/list_model.dart';
import 'package:trelltech/models/member_model.dart';
import 'package:trelltech/pages/board.dart';

class Controller extends State {
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
  final BoardPage widget;
  final State state;

  Controller(this.widget, this.state);

  ListController get listsController => _listsController;
  CardController get cardsController => _cardsController;
  BoardController get boardController => _boardController;
  MemberController get memberController => _memberController;
  ScrollController get scrollController => _scrollController;
  TextEditingController get textEditingController => _textEditingController;

  void loadInfo() async {
    loadBoardMembers();
    final fetchedLists = await _listsController.getLists(board: widget.board);
    final fetchedCards = await Future.wait(
        fetchedLists.map((list) => _cardsController.getCards(list: list)));
    state.setState(() {
      lists = fetchedLists;
      allCards = fetchedCards;
      loadCardMembers();
    });
  }

  void moveListBetween(ListModel listMoved, ListModel firstList,
      ListModel secondList, State reloadState) {
    listMoved.moveListBetween(firstList, secondList);
    lists.sort((a, b) => a.pos.compareTo(b.pos));
    loadInfo();
    reloadState.setState(() {});
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

        state.setState(() {
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

      state.setState(() {
        members = List.from(boardMembers);
      });
    } catch (e) {
      rethrow;
    }
  }

  void loadCardMembers() async {
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

      state.setState(() {});
    } catch (e) {
      rethrow;
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

      state.setState(() {
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
    final screenSize = MediaQuery.of(state.context).size;
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
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}
