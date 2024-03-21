import 'package:flutter/material.dart';

// import 'package:trelltech/widgets/form.dart';
enum SampleItem { update, delete }

SampleItem? selectedItem;

AppBar appbar(
    {dynamic text = "TrellTech",
    color = Colors.transparent,
    double elevation = 0,
    bool showEditButton = false,
    onEdit,
    onDelete}) {
  List<Widget> actions = [];
  if (showEditButton) {
    actions.add(PopupMenuButton<SampleItem>(
        onSelected: (SampleItem item) {
          switch (item) {
            case SampleItem.update:
              onEdit();
              break;
            case SampleItem.delete:
              onDelete();
              break;
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<SampleItem>>[
              const PopupMenuItem<SampleItem>(
                value: SampleItem.update,
                child: Text('Edit'),
              ),
              const PopupMenuItem<SampleItem>(
                value: SampleItem.delete,
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
