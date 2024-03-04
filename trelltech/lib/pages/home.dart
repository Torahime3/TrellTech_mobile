import 'package:flutter/material.dart';
import 'package:trelltech/models/board.dart';
import 'package:trelltech/widgets/appbar.dart';
import 'dart:math' as math;

class HomePage extends StatelessWidget {
  HomePage({super.key});

  List<BoardModel> boards = [];

  void _getInitialInfo() {
    boards = BoardModel.getBoards();
  }

  // Container(
  //             width: 50,
  //             height: 50,
  //             margin: const EdgeInsets.all(10),
  //             color: Colors.red,
  //             child: Text("Bonjour")),

  Widget build(BuildContext context) {
    _getInitialInfo();
    return Scaffold(
      appBar: appbar(),
      body: Column(
        children: [
          Container(
            child: const Text(
              "My boards",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: boards.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  height: 170,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color:
                        Color((math.Random().nextDouble() * 0xFFFFFF).toInt())
                            .withOpacity(1.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.all(10),
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    child: Text(
                      boards[index].getName(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
