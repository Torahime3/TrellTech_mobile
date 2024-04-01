import 'package:flutter/material.dart';
import 'package:trelltech/models/list_model.dart';
import 'package:trelltech/controllers/controller.dart';
import 'package:trelltech/widgets/update_list_dialog.dart';

void showPopupMenu(
    BuildContext context, ListModel list, Controller controller) {
  final RenderBox button = context.findRenderObject() as RenderBox;
  final Offset buttonPosition = button.localToGlobal(Offset.zero);

  showMenu(
    context: context,
    position: RelativeRect.fromLTRB(
      buttonPosition.dx,
      buttonPosition.dy,
      buttonPosition.dx,
      buttonPosition.dy,
    ),
    items: [
      const PopupMenuItem(
        value: 'update',
        child: ListTile(
          leading: Icon(Icons.edit, color: Colors.blue),
          title: Text('Edit'),
        ),
      ),
      const PopupMenuItem(
        value: 'delete',
        child: ListTile(
          leading: Icon(Icons.delete, color: Colors.red),
          title: Text('Delete'),
        ),
      ),
    ],
  ).then((value) {
    if (value == 'update') {
      updateListDialog(list.id, controller);
    } else if (value == 'delete') {
      controller.listsController.delete(
          id: list.id,
          onDeleted: () {
            controller.loadInfo();
          });
    }
  });
}
