import 'package:flutter/material.dart';
import 'package:trelltech/controllers/board_controller.dart';
import 'package:trelltech/controllers/workspace_controller.dart';
import 'package:trelltech/models/board_model.dart';
import 'package:trelltech/models/workspace_model.dart';
import 'package:trelltech/pages/board.dart';
import 'package:trelltech/widgets/appbar.dart';

enum SampleItem { update, delete, add }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final BoardController _boardController = BoardController();
  final WorkspaceController _workspaceController = WorkspaceController();
  List<AnimationController> _animationControllers = [];
  List<Animation<Offset>> _slideAnimations = [];
  List<BoardModel> boards = [];
  List<Workspace> workspaces = [];
  bool boardsVisible = false;
  final TextEditingController _textEditingController = TextEditingController();
  String selectedButton = '';


  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  void _initAnimationsForWorkspace(List<BoardModel> boards) {
    _animationControllers = List.generate(boards.length, (index) {
      return AnimationController(
        duration: Duration(milliseconds: 200 + (index * 100)),
        vsync: this,
      )..forward();
    });

    _slideAnimations = _animationControllers.map((controller) {
      return Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ),
      );
    }).toList();
  }

  void _loadInfo() async {
    final fetchedBoards = await _boardController.getBoards();
    final fetchedWorkspaces = await _workspaceController.get();

    setState(() {
      boards = fetchedBoards;
      workspaces = fetchedWorkspaces;
    });
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildExpansionPanelBody(id) {
    return Column(children: [
      FutureBuilder<List<BoardModel>>(
          future: _boardController.getBoardsInWorkspace(id),
          builder: (context, snapshot) {
            boards = snapshot.data ?? [];
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              List<BoardModel> boards = snapshot.data!;
              _initAnimationsForWorkspace(boards);
              return ListView.builder(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(), // Disable scrolling to allow the parent ListView to handle scrolling
                itemCount: boards.length,
                itemBuilder: (BuildContext context, int index) {
                  return SlideTransition(
                    position: _slideAnimations[index],
                    child: Container(
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
                                      },
                                    );
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BoardPage(
                                  board: boards[index],
                                  boardColor:
                                      Colors.primaries.elementAt(index % 18),
                                ),
                              ),
                            );
                          },
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            elevation: 4,
                            child: Ink(
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.primaries.elementAt(index % 18),
                              ),
                              child: Container(
                                margin: const EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.dashboard,
                                      color: Colors.primaries
                                          .elementAt(index % 18)
                                          .shade900,
                                    ),
                                    const SizedBox(width: 10),
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
                      ),
                    ),
                  );
                },
              );
            } else {
              return const Padding(
                padding: EdgeInsets.all(.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }
          })
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appbar(text: "My Workspaces", color: Colors.white),
        body: ListView.builder(
          itemCount: workspaces.length,
          itemBuilder: (BuildContext context, int index) {
            return Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    setState(() {
                      workspaces[index].toggleExpansion();
                    });
                  },
                  child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: const BoxDecoration(
                        border: Border(
                            bottom:
                                BorderSide(color: Colors.black, width: 0.5)),
                      ),
                      child: Row(children: [
                        Icon(
                            (workspaces[index].isExpanded
                                ? Icons.arrow_drop_up
                                : Icons.arrow_drop_down),
                            color: Colors.black),
                        const SizedBox(
                          width: 10,
                        ),
                        FutureBuilder<String>(
                            future: _workspaceController
                                .getName(workspaces[index].id),
                            builder: (context, snapshot) {
                              return Text(snapshot.data ?? '',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ));
                            }),
                        IconButton(
                          onPressed: () {
                            showMenu(
                              context: context,
                              position: const RelativeRect.fromLTRB(0, 0, 0, 0),
                              items: [
                                const PopupMenuItem(
                                  value: 'update',
                                  child: ListTile(
                                    leading: Icon(Icons.edit),
                                    title: Text('Edit name'),
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: ListTile(
                                    leading: Icon(Icons.delete),
                                    title: Text('Delete workspace'),
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: "createBoard",
                                  child: ListTile(
                                    leading: Icon(Icons.add),
                                    title: Text('Create board'),
                                  ),
                                )
                              ],
                            ).then((value) {
                              switch (value) {
                                case "update":
                                  _textEditingController.text =
                                      workspaces[index].displayName;
                                  showModalBottomSheet(
                                    backgroundColor: const Color.fromARGB(
                                        255, 255, 255, 255),
                                    context: context,
                                    builder: (BuildContext context) {
                                      return SizedBox(
                                        height: 600,
                                        child: Center(
                                          child: Form(
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                      16.0),
                                                  child: TextFormField(
                                                    autofocus: true,
                                                    controller:
                                                        _textEditingController,
                                                    decoration:
                                                        const InputDecoration(
                                                      focusedBorder:
                                                          UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: Color.fromARGB(
                                                              255, 49, 49, 49),
                                                        ),
                                                      ),
                                                    ),
                                                    cursorColor:
                                                        const Color.fromARGB(
                                                            255, 49, 49, 49),
                                                    onFieldSubmitted:
                                                        (String value) {
                                                      _workspaceController
                                                          .update(
                                                              workspaces[index]
                                                                  .id,
                                                              value);
                                                      Navigator.of(context)
                                                          .pop();
                                                      setState(() {
                                                        workspaces[index].displayName = _textEditingController.text;
                                                      });
                                                      _loadInfo();
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                  break;
                                case "delete":
                                  _workspaceController
                                      .delete(workspaces[index].id);
                                  _loadInfo();
                                  setState(() {});
                                  break;
                                case "createBoard":
                                  showModalBottomSheet(
                                    backgroundColor: const Color.fromARGB(
                                        255, 255, 255, 255),
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Modal(workspaceId: workspaces[index].id);
                                    }
                                  ).then((value) {
                                    if (value == null) {
                                      _textEditingController.clear();
                                      selectedButton = '';
                                    }
                                    _loadInfo();
                                  });
                              }
                            });
                          },
                          icon: const Icon(Icons.more_vert),
                        )
                      ])),
                ),
                if (workspaces[index].isExpanded)
                  _buildExpansionPanelBody(workspaces[index].id),
              ],
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
                          child: Form(
                              child: Column(
                        children: [
                          Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: TextFormField(
                                autofocus: true,
                                decoration: const InputDecoration(
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color.fromARGB(255, 49, 49,
                                            49)), // Change underline color
                                  ),
                                  hintText: "Add a title to your new workspace",
                                ),
                                cursorColor:
                                    const Color.fromARGB(255, 49, 49, 49),
                                onFieldSubmitted: (String value) {
                                  _workspaceController.create(value);
                                  _loadInfo();
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
      switch(selectedButton) {
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
        }
      );
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
                                                  padding: const EdgeInsets.all(
                                                      16.0),
                                                  child: TextFormField(
                                                    // autofocus: true,
                                                    controller: _textEditingController,
                                                    decoration:
                                                        const InputDecoration(
                                                      focusedBorder:
                                                          UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: Color.fromARGB(
                                                              255, 49, 49, 49),
                                                        ),
                                                      ),
                                                      hintText:
                                                          "Add a title to your new board",
                                                    ),
                                                    cursorColor:
                                                        const Color.fromARGB(
                                                            255, 49, 49, 49),
                                                    onFieldSubmitted:
                                                        (String value) {
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
                                                            _textEditingController.text = buttonNames[buttonIndex];
                                                          });
                                                          // _loadInfo();
                                                        },
                                                        child: Container(
                                                          padding: const EdgeInsets.all(10),
                                                          margin: const EdgeInsets.all(5),
                                                          decoration: BoxDecoration(
                                                            color: selectedButton == buttonNames[buttonIndex]
                                                                ? Colors.black
                                                                : Colors.grey,
                                                            borderRadius: BorderRadius.circular(5),
                                                          ),
                                                          child: Text(buttonNames[buttonIndex], style: const TextStyle(color: Colors.white),),
                                                        ),
                                                      )
                                                    )
                                                  )
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                              
  }
}