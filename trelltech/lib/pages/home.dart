import 'dart:math';

import 'package:flutter/material.dart';
import 'package:trelltech/models/board_model.dart';
import 'package:trelltech/pages/board.dart';
import 'package:trelltech/widgets/appbar.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  List<BoardModel> boards = [];

  void _getInitialInfo() {
    boards = BoardModel.getBoards();
  }

  @override
  Widget build(BuildContext context) {
    _getInitialInfo();
    return Scaffold(
      appBar: appbar(),
      body: Expanded(
        child: ListView.builder(
          itemCount: boards.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              margin: const EdgeInsets.all(10),
              child: InkWell(
                onTap: () {
                  print("Salut" + Random().nextInt(10).toString());
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => BoardPage(boards[index])));
                },
                child: Ink(
                  height: 170,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: boards[index].getColor(),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
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
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: const FloatingActionButton(
        onPressed: null,
        tooltip: 'Increment Counter',
        backgroundColor: Color.fromARGB(255, 229, 229, 229),
        child: Icon(Icons.add),
      ),
    );
  }
}
