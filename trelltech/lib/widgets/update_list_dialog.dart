import 'package:flutter/material.dart';
import 'package:trelltech/controllers/controller.dart';

void updateListDialog(listId, Controller controller) {
  TextEditingController textFieldController = TextEditingController();

  showDialog(
    context: controller.state.context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Update List"),
        content: TextField(
          controller: textFieldController,
          decoration: const InputDecoration(
            hintText: "Enter new list name",
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
            child: const Text("Edit"),
            onPressed: () {
              String name = textFieldController.text;
              if (name.isNotEmpty) {
                controller.listsController.update(
                    id: listId,
                    name: name,
                    onUpdated: () {
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
