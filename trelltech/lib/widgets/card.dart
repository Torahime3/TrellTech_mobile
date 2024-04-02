import 'package:flutter/material.dart';
import 'package:trelltech/controllers/controller.dart';
import 'package:trelltech/models/card_model.dart';
import 'package:trelltech/utils/colormap_utils.dart';
import 'package:trelltech/widgets/avatar.dart';
import 'package:trelltech/widgets/member_avatar.dart';

Widget buildCard(CardModel card, Controller controller) {
  return GestureDetector(
      onLongPress: () {
        showMenu(
            context: controller.state.context,
            position: const RelativeRect.fromLTRB(0, 200, 0, 0),
            items: <PopupMenuEntry>[
              PopupMenuItem(
                  child: ListTile(
                      title: const Text('Delete card'),
                      onTap: () {
                        controller.cardsController.delete(card.id);
                        Navigator.of(controller.state.context).pop();
                        controller.loadInfo();
                      })),
              PopupMenuItem(
                  child: ListTile(
                      title: const Text("Edit card"),
                      onTap: () {
                        controller.textEditingController.text = card.name;
                        showModalBottomSheet(
                            backgroundColor:
                                const Color.fromARGB(255, 255, 255, 255),
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
                                            controller.cardsController.update(
                                                cardId: card.id,
                                                name: controller
                                                    .textEditingController
                                                    .text);
                                            Navigator.of(context).pop();
                                            controller.loadInfo();
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text("Edit"),
                                        ),
                                        Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: TextFormField(
                                              autofocus: true,
                                              controller: controller
                                                  .textEditingController,
                                              decoration: const InputDecoration(
                                                focusedBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Color.fromARGB(
                                                          255,
                                                          49,
                                                          49,
                                                          49)), // Change underline color
                                                ),
                                              ),
                                              cursorColor: const Color.fromARGB(
                                                  255, 49, 49, 49),
                                              maxLines: null,
                                            ))
                                      ]))
                                    ],
                                  ))));
                            });
                        // Navigator.of(context).pop();
                      }))
            ]);
      },
      child: Column(children: [
        if (getColorFromString(card.coverColor) != Colors.transparent)
          Container(
            height: 30,
            margin:
                const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 0),
            decoration: BoxDecoration(
              color: getColorFromString(card.coverColor),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
          ),
        Container(
          margin: getColorFromString(card.coverColor) != Colors.transparent
              ? const EdgeInsets.only(
                  left: 12.0,
                  right: 12.0,
                  top: 0.0,
                  bottom: 8.0,
                )
              : const EdgeInsets.all(12.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 255),
            borderRadius:
                getColorFromString(card.coverColor) != Colors.transparent
                    ? const BorderRadius.only(
                        bottomLeft: Radius.circular(20.0),
                        bottomRight: Radius.circular(20.0),
                      )
                    : const BorderRadius.all(Radius.circular(20.0)),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 58, 58, 58).withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    // Wrap text widget with Expanded
                    child: Text(
                      card.name,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color.fromARGB(
                            255, 46, 46, 46), // Text color for header
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Liste des labels de la carte
              Wrap(
                spacing: 5,
                runSpacing: 5,
                children: List<Widget>.generate(
                  card.label.length,
                  (int index) {
                    return Material(
                      color: getColorFromString(card.label[index].color),
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30.0, vertical: 0.0),
                        child: Text(
                          card.label[index].name,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Avatar(
                    avatars: controller.members
                        .where((member) => member.cardIds.contains(card.id))
                        .map((member) => MemberAvatar(
                              initials: member.initials ?? '',
                              color: member.color ?? Colors.blue,
                            ))
                        .toList(),
                  ),
                ],
              ),
            ],
          ),
        ),
        // ),
      ]));
}
