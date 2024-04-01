import 'package:flutter/material.dart';
import 'package:trelltech/controllers/board_controller.dart';

class CreateForm extends StatefulWidget {
  const CreateForm({super.key});

  @override
  State<CreateForm> createState() => _CreateFormState();
}

class _CreateFormState extends State<CreateForm> {
  final TextEditingController _textEditingController = TextEditingController();
  final BoardController _boardController = BoardController();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 600,
        child: Center(
            child: Form(
                child: Column(
          children: [
            Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Board name",
                  ),
                  controller: _textEditingController,
                  onFieldSubmitted: (String? value) {
                    _boardController.create(
                        name: value,
                        onCreated: () {
                          _textEditingController.clear();
                          Navigator.of(context).pop();
                        });
                  },
                ))
          ],
        ))));
  }
}
