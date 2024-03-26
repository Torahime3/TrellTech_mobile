import 'package:flutter/material.dart';
import 'package:trelltech/controllers/board_controller.dart';
import 'package:trelltech/controllers/workspace_controller.dart';
import 'package:trelltech/models/board_model.dart';
import 'package:trelltech/models/workspace_model.dart';
import 'package:trelltech/pages/board.dart';
import 'package:trelltech/widgets/appbar.dart';

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

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  void _loadInfo() async {
    final fetchedBoards = await _boardController.getBoards();
    final fetchedWorkspaces = await _workspaceController.get();

    _animationControllers = List.generate(fetchedBoards.length, (index) {
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

    setState(() {
      boards = fetchedBoards;
      workspaces = fetchedWorkspaces;
    });

  }

  void _loadWorkspaceBoards(id) async {
    final workspaceBoards = await _boardController.getBoardsInWorkspace(id);
    setState(() {
      boards = workspaceBoards;
    });
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }


  Widget _buildExpansionPanelBody() {
    // final boards = await _boardController.getBoardsInWorkspace(id);

    return SizedBox (
        height: 400,
        child: ListView.builder(
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
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      elevation: 15,
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
                ),
              ),
            );
          },
        )
    );
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
                    ExpansionPanelList(
                      elevation: 0,
                      children: [
                        ExpansionPanel(
                          canTapOnHeader: true,
                          headerBuilder: 
                            (context, isOpen) {
                              return ListTile(
                                title: Text(workspaces[index].id.toString())
                              );
                            },
                          body: _buildExpansionPanelBody(),
                          isExpanded: workspaces[index].getIsExpanded()
                        )
                      ],
                      expansionCallback: (i, isOpen) {
                        print("IMMA DIE");
                        print(workspaces[index].getIsExpanded());
                        _loadWorkspaceBoards(workspaces[index].id);

                        setState(() {
                          workspaces[index].toggleExpansion(); // Toggle expansion state
                          if (workspaces[index].getIsExpanded()) {
                            _loadWorkspaceBoards(workspaces[index].id);
                          } else {
                            boards.clear();
                          }
                        });
                      }
                    ),
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
                                    borderSide: BorderSide(
                                        color: Color.fromARGB(255, 49, 49,
                                            49)), // Change underline color
                                  ),
                                  hintText: "Add a title to your new board",
                                ),
                                cursorColor:
                                    const Color.fromARGB(255, 49, 49, 49),
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
        )
    );
  }
}
