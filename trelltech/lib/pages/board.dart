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

  @override
  void initState() {
    super.initState();
    _getInitialInfo();
  }

  void _getInitialInfo() async {
    final fetchedLists = await _listsController.getLists(board: widget.board);
    setState(() {
      lists = fetchedLists;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(),
      body: Container(
        color: Colors.white,
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
                  right: 0.0,
                  child: _buildAddCardRow(),
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
