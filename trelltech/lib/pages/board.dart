import 'package:flutter/material.dart';
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
  List<ListModel> lists = [];
  List<CardModel> cards = [];

  @override
  void initState() {
    super.initState();
    _getInitialInfo();
  }

  void _getInitialInfo() async {
    final fetchedLists = await _listsController.getLists(board: widget.board);
    final fetchedCards = await _cardsController.getCards();

    setState(() {
      lists = fetchedLists;
      cards = fetchedCards;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(),
      //text: board.name, color: Colors.blue), // Use BoardModel properties
      body: Container(
        color: Colors.white, // Background color
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: lists.length,
          itemBuilder: (BuildContext context, int index) {
            return _buildList(lists[index]);
          },
        ),
      ),
    );
  }

  Widget _buildList(ListModel list) {
    return Container(
      width: 300,
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.black, // List background color
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Stack(
        // Use Stack for positioning
        children: [
          Column(
            // Existing list content
            children: [
              //list header
              Container(
                height: 50,
                color: Colors.black,
                child: Center(
                  child: Text(
                    list.name,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Expanded(
                //list body
                child: ListView.builder(
                  itemCount: cards.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildCard(cards[index]);
                  },
                ),
              ),
            ],
          ),
          Positioned(
            // list footer
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: _buildAddCardRow(),
          ),
        ],
      ),
    );
  }

  Widget _buildAddCardRow() {
    // text at the bottom of the list
    return Container(
      padding: const EdgeInsets.all(16.0),
      height: 50,
      color: Colors.black, // Background color
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "+ Add Card",
            style: TextStyle(
              fontSize: 16,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(CardModel card) {
    return Container(
      margin: const EdgeInsets.all(12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 95, 95, 95),
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
