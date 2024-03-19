import 'package:flutter/material.dart';
import 'package:trelltech/controllers/board_controller.dart';
import 'package:trelltech/models/board_model.dart';
import 'package:trelltech/pages/board.dart';
import 'package:trelltech/widgets/appbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final BoardController _boardController = BoardController();
  List<BoardModel> boards = [];

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  void _loadInfo() async {
    final fetchedBoards = await _boardController.getBoards();
    setState(() {
      boards = fetchedBoards;
    });
  }

  @override
  Widget build(BuildContext context) {
    // _getInitialInfo();
    return Scaffold(
        appBar: appbar(),
        body: ListView.builder(
          itemCount: boards.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              margin: const EdgeInsets.all(10),
              child: GestureDetector(
                onLongPress: () {
                  showMenu(
                      context: context,
                      position: const RelativeRect.fromLTRB(0, 200, 0, 0),
                      items: <PopupMenuEntry>[
                        PopupMenuItem(
                            child: ListTile(
                                title: const Text('Delete board'),
                                onTap: () {
                                  _boardController.delete(
                                      id: boards[index].id,
                                      onDeleted: () {
                                        _loadInfo();
                                      });
                                  Navigator.of(context).pop();
                                })),
                      ]);
                },
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => BoardPage(
                                board: boards[index],
                                boardColor:
                                    Colors.primaries.elementAt(index % 18))));
                  },
                  child: Ink(
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.primaries.elementAt(index % 18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Icon(
                            Icons.dashboard,
                            color:
                                Colors.primaries.elementAt(index % 18).shade900,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            boards[index].getName(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
                backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                context: context,
                builder: (BuildContext context) {
                  return SizedBox(
                      height: 600,
                      child: Center(
                          // child: Text('Your modal content goes here'),
                          child: Form(
                              child: Column(
                        children: [
                          Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: TextFormField(
                                autofocus: true, 
                                decoration: const InputDecoration(
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color.fromARGB(255, 49, 49, 49)), // Change underline color
                                  ),
                                ),
                                cursorColor: const Color.fromARGB(255, 49, 49, 49),
                                onFieldSubmitted: (String value) {
                                  _boardController.create(
                                      name: value,
                                      onCreated: () {
                                        _loadInfo();
                                      });
                                  Navigator.of(context).pop();
                                },
                              ))
                        ],
                      ))));
                });
          },
          tooltip: 'Increment Counter',
          backgroundColor: const Color.fromARGB(255, 229, 229, 229),
          elevation: 1,
          shape: const CircleBorder(),
          child: const Icon(Icons.add),
        ));
  }
}
