// import 'dart:js_interop';

import 'package:flutter/material.dart';
// import 'package:trelltech/widgets/form.dart';

AppBar appbar({dynamic text = "TrellTech", color = Colors.transparent, bool showEditButton = false, onEdit, onDelete}) {
  List<Widget> actions = [];

  if (showEditButton) {
    actions.add(
      IconButton(
        icon: const Icon(Icons.edit),
        onPressed: onEdit,
      ),
    );
    actions.add(
      IconButton(
        icon: const Icon(Icons.delete),
        onPressed: onDelete,
      )
    );
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
    elevation: 0,
    actions: actions
  );
}
