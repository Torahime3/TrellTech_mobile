// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:trelltech/controllers/controller.dart';
import 'package:trelltech/models/board_model.dart';
import 'package:trelltech/utils/materialcolor_utils.dart';
import 'package:trelltech/widgets/appbar.dart';
import 'package:trelltech/widgets/list.dart';
import 'package:trelltech/widgets/list_dialog.dart';

class BoardPage extends StatefulWidget {
  const BoardPage(
      {super.key, required this.board, this.boardColor = Colors.blue});
  final BoardModel board;
  final Color boardColor;

  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  late Controller controller;

  @override
  void initState() {
    super.initState();
    controller = Controller(widget, this);
    controller.loadInfo();
  }

  @override
  void dispose() {
    controller.scrollController.dispose();
    controller.autoScrollTimer?.cancel();
    controller.stopAutoScroll();
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
          controller.boardController.delete(
            id: board.id,
            onDeleted: () {
              controller.loadInfo();
            },
          );
          Navigator.of(context).pop();
        },
        onEdit: () {
          controller.textEditingController.text = board.name;
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
                            controller: controller.textEditingController,
                            decoration: const InputDecoration(
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 49, 49, 49),
                                ),
                              ),
                            ),
                            cursorColor: const Color.fromARGB(255, 49, 49, 49),
                            onFieldSubmitted: (String value) {
                              controller.boardController.update(
                                id: board.id,
                                name: value,
                                onUpdated: () {
                                  controller.loadInfo();
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
              controller: controller.scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: controller.lists.length + 1, // Add one for the button
              itemBuilder: (BuildContext context, int index) {
                if (index < controller.lists.length) {
                  return ListWidget(
                      controller: controller,
                      list: controller.lists[index],
                      cards: controller.allCards[index],
                      index: index);
                } else {
                  // Render the button at the end of the list
                  return Center(
                    child: SizedBox(
                      height: 50,
                      width: 300,
                      child: GestureDetector(
                        onTap: () {
                          createListDialog(controller);
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: getMaterialColor(boardColor).shade400,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: const Text(
                            'Add List',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
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
}
