import 'package:flutter/material.dart';

AppBar appbar(
    {dynamic text = "TrellTech",
    color = Colors.transparent,
    double elevation = 0,
    bool showEditButton = false,
    onEdit,
    onDelete}) {
  List<Widget> actions = [];
  if (showEditButton) {
    actions.add(PopupMenuButton<String>(
        onSelected: (String item) {
          switch (item) {
            case "update":
              onEdit();
              break;
            case "delete":
              onDelete();
              break;
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: "update",
                child: Text('Edit'),
              ),
              const PopupMenuItem<String>(
                value: "delete",
                child: Text('Delete'),
              ),
            ]));
  }
  return AppBar(
      title: Text(text,
          style: const TextStyle(
            color: Color.fromARGB(255, 34, 34, 34),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          )),
      centerTitle: true,
      backgroundColor: color,
      elevation: elevation,
      actions: actions);
}
