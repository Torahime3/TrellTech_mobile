import 'package:flutter/material.dart';
import 'package:trelltech/controllers/controller.dart';

Widget buildAddCardRow(listId, Controller controller) {
  // list footer
  return Container(
      padding: const EdgeInsets.all(16.0),
      height: 75,
      width: 75,
      child: FloatingActionButton(
        onPressed: () {
          controller.textEditingController.text = "";
          showModalBottomSheet(
              backgroundColor: const Color.fromARGB(255, 255, 255, 255),
              context: controller.state.context,
              builder: (BuildContext context) {
                return SizedBox(
                    height: 600,
                    child: Center(
                        child: Form(
                            child: Column(
                      children: [
                        Expanded(
                            child: ListView(children: [
                          ElevatedButton(
                            onPressed: () {
                              controller.cardsController.create(listId,
                                  controller.textEditingController.text);
                              Navigator.of(context).pop();
                              controller.loadInfo();
                            },
                            child: const Text("Create"),
                          ),
                          Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: TextFormField(
                                autofocus: true,
                                controller: controller.textEditingController,
                                decoration: const InputDecoration(
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color.fromARGB(255, 49, 49,
                                            49)), // Change underline color
                                  ),
                                  hintText: "Enter a title for this card...",
                                ),
                                cursorColor:
                                    const Color.fromARGB(255, 49, 49, 49),
                                maxLines: null,
                                // onFieldSubmitted: (String value) {
                                //   _cardsController.create(listId, value);
                                //   Navigator.of(context).pop();
                                //   _loadInfo();
                                // },
                              ))
                        ]))
                      ],
                    ))));
              });
          // _cardsController.create(listId);
          // _loadInfo();
          // setState(() {});
        },
        tooltip: 'Increment Counter',
        backgroundColor: const Color.fromARGB(255, 229, 229, 229),
        shape: const CircleBorder(),
        child: const Text("+"),
      ));
}
