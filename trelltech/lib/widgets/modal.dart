import 'package:flutter/material.dart';
import 'package:trelltech/controllers/board_controller.dart';

class Modal extends StatefulWidget {
  final String workspaceId;
  const Modal({required this.workspaceId, super.key});

  @override
  State<Modal> createState() => _ModalState();
}

class _ModalState extends State<Modal> {
  final TextEditingController _textEditingController = TextEditingController();
  final BoardController _boardController = BoardController();
  String selectedButton = '';

  List<String> buttonNames = [
    '1-on-1 Meeting Agenda',
    'Company Overview',
    'Project Management',
    'Weekly Planning',
    'Kanban',
    'Go To Market Strategy',
    'Agile',
  ];

  _handleSubmit(input, workspaceId) {
    String idBoardSource = '';

    if (input.isNotEmpty && selectedButton.isNotEmpty) {
      // Both name and template are available (Either custom name or template name)
      switch (selectedButton) {
        case '1-on-1 Meeting Agenda':
          idBoardSource = '5b2281bb004ac866019e51fa';
          break;
        case 'Company Overview':
          idBoardSource = '5994be8ce20c9b37589141c2';
          break;
        case 'Project Management':
          idBoardSource = '5c4efa1d25a9692173830e7f';
          break;
        case 'Weekly Planning':
          idBoardSource = '5ec98d97f98409568dd89dff';
          break;
        case 'Kanban':
          idBoardSource = '5e6005043fbdb55d9781821e';
          break;
        case 'Go To Market Strategy':
          idBoardSource = '5aaafd432693e874ec11495c';
          break;
        case 'Agile':
          idBoardSource = '591ca6422428d5f5b2794aee';
          break;
      }
      _boardController.createTemplate(input, workspaceId, idBoardSource);
      // _loadInfo();
    } else if (input.isNotEmpty && selectedButton.isEmpty) {
      // Only name is given (No template)
      _boardController.create(
          name: input,
          id: workspaceId,
          onCreated: () {
            // _loadInfo();
          });
    }
    selectedButton = '';
    _textEditingController.clear();
  }

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
                  // autofocus: true,
                  controller: _textEditingController,
                  decoration: const InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 49, 49, 49),
                      ),
                    ),
                    hintText: "Add a title to your new board",
                  ),
                  cursorColor: const Color.fromARGB(255, 49, 49, 49),
                  onFieldSubmitted: (String value) {
                    if (value.isNotEmpty) {
                      _handleSubmit(value, widget.workspaceId);
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Wrap(
                      spacing: 10,
                      children: List.generate(
                          buttonNames.length,
                          (buttonIndex) => GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedButton = buttonNames[buttonIndex];
                                    _textEditingController.text =
                                        buttonNames[buttonIndex];
                                  });
                                  // _loadInfo();
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  margin: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: selectedButton ==
                                            buttonNames[buttonIndex]
                                        ? Colors.black
                                        : Colors.grey,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    buttonNames[buttonIndex],
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ))))
            ],
          ),
        ),
      ),
    );
  }
}
