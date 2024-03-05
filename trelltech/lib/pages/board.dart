import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:trelltech/models/board_model.dart';
import 'package:trelltech/widgets/appbar.dart';

class BoardPage extends StatelessWidget {
  final BoardModel board;

  BoardPage(this.board, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appbar(text: board.getName(), color: board.getColor()),
        body: const Center(
          child: Text('Board'),
        ));
  }
}
