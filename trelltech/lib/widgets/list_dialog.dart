import 'package:flutter/material.dart';
import 'package:trelltech/controllers/controller.dart';

void createListDialog(Controller controller) {
  TextEditingController textFieldController = TextEditingController();
  showDialog(
    context: controller.state.context,
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
                controller.listsController.create(name,
                    board: controller.widget.board, onCreated: () {
                  controller.loadInfo();
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
