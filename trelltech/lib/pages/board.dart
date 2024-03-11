import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:trelltech/models/board_model.dart';
import 'package:trelltech/models/list_model.dart';
import 'package:trelltech/models/card_model.dart';
import 'package:trelltech/widgets/appbar.dart';

class BoardPage extends StatelessWidget {
  final BoardModel board;

  BoardPage(this.board, {super.key});

  List<ListModel> lists = [];
  List<CardModel> cards = [];

  void _getInitialInfo() {
    lists = ListModel.getList();
    cards = CardModel.getCard();
  }

  @override
  Widget build(BuildContext context) {
    _getInitialInfo();
    return Scaffold(
      appBar: appbar(text: board.getName(), color: board.getColor()),
      body: Container(
        color: const Color.fromARGB(255, 255, 255, 255),
        child: ListView.builder(
          itemCount: lists.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (BuildContext context, int index) {
            List<CardModel> cards =
                CardModel.getCard(); // Fetch cards for the current list
            return Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 244, 244, 244),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              width: 375,
              margin: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lists[index].name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  // Display cards as rounded black boxes
                  for (var card in cards)
                    Container(
                      margin: EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.all(10),
                      child: Text(
                        card.getName(),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
// Container list(index) {
//   return Container(
//     decoration: BoxDecoration(
//       color: Color.fromARGB(255, 244, 244, 244),
//       borderRadius: BorderRadius.circular(20),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.grey.withOpacity(0.5),
//           spreadRadius: 5,
//           blurRadius: 7,
//           offset: const Offset(0, 6),
//         ),
//       ],
//     ),
//     width: 375,
//     margin: const EdgeInsets.all(15),
//     child: Column(
//       children: [
//         Text(),
//         Text("carte 1"),
//         Text("carte 2"),
//         Text("carte 3"),
//       ],
//     ),
//   );
