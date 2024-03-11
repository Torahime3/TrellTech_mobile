import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
import 'package:trelltech/models/board_model.dart';
import 'package:trelltech/models/list_model.dart';
import 'package:trelltech/widgets/appbar.dart';

class BoardPage extends StatelessWidget {
  final BoardModel board;

  BoardPage(this.board, {super.key});

  List<ListModel> lists = [];

  void _getInitialInfo() {
    lists = ListModel.getList();
  }

  @override
  Widget build(BuildContext context) {
    _getInitialInfo();
    return Scaffold(
        appBar: appbar(text: board.getName(), color: Colors.blue),
        body: Container(
          color: const Color.fromARGB(255, 255, 255, 255),
          child: ListView.builder(
            itemCount: lists.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (BuildContext context, int index) {
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
                  children: [
                    Text(
                      lists[index].name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text("carte 1"),
                    const Text("carte 2"),
                    const Text("carte 3"),
                  ],
                ),
              );
            },
          ),
        ));
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
