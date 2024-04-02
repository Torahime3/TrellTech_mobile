import "package:flutter/material.dart";
import "package:trelltech/controllers/controller.dart";
import "package:trelltech/models/card_model.dart";
import "package:trelltech/models/list_model.dart";
import "package:trelltech/pages/card.dart";
import "package:trelltech/utils/materialcolor_utils.dart";
import "package:trelltech/widgets/add_card.dart";
import "package:trelltech/widgets/card.dart";
import "package:trelltech/widgets/popup.dart";

class ListWidget extends StatefulWidget {
  final Controller controller;
  final ListModel list;
  final List<CardModel> cards;
  final int index;

  const ListWidget(
      {super.key,
      required this.controller,
      required this.list,
      required this.cards,
      required this.index});

  @override
  State<ListWidget> createState() => _ListWidgetState();
}

class _ListWidgetState extends State<ListWidget> {
  @override
  Widget build(BuildContext context) {
    Controller controller = widget.controller;

    controller.listKeys[widget.list.id] ??= GlobalKey();
    final GlobalKey currentListKey = controller.listKeys[widget.list.id]!;

    return DragTarget<ListModel>(onWillAcceptWithDetails:
        (DragTargetDetails<ListModel> incomingListData) {
      return incomingListData.data.id != widget.list.id;
    }, onAcceptWithDetails: (DragTargetDetails<ListModel> details) {
      final RenderBox renderBox =
          currentListKey.currentContext?.findRenderObject() as RenderBox;
      final Offset targetCenter =
          renderBox.localToGlobal(renderBox.size.center(Offset.zero));
      final bool isLeft = (details.offset.dx + 100) < targetCenter.dx;
      final ListModel listDetails = details.data;
      if (isLeft) {
        if (widget.index == 0) {
          return;
        }
        controller.moveListBetween(listDetails, controller.lists[widget.index],
            controller.lists[widget.index - 1], this);
      } else {
        if (widget.index == controller.lists.length - 1) {
          return;
        }
        controller.moveListBetween(listDetails, controller.lists[widget.index],
            controller.lists[widget.index + 1], this);
      }
    }, builder: (BuildContext context, List<ListModel?> candidateData,
        List<dynamic> rejectedData) {
      return Container(
        key: currentListKey,
        width: 300,
        margin: widget.index == 0
            ? const EdgeInsets.only(
                left: 36.0, right: 12.0, top: 12.0, bottom: 12.0)
            : const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: getMaterialColor(controller.widget.boardColor).shade300,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //
            // List header
            //

            Listener(
              onPointerMove: (PointerMoveEvent pme) {
                final screenSize = MediaQuery.of(context).size;
                final position = pme.position;

                if (position.dx > screenSize.width - 20) {
                  controller.startAutoScroll(13.0);
                } else if (position.dx < 20) {
                  controller.startAutoScroll(-13.0);
                } else {
                  controller.stopAutoScroll();
                }
              },
              onPointerUp: (PointerUpEvent pue) {
                controller.stopAutoScroll();
              },
              child: LongPressDraggable<ListModel>(
                data: widget.list,
                feedback: Container(
                  height: 50,
                  width: 200,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                      bottomLeft: Radius.circular(20.0),
                      bottomRight: Radius.circular(20.0),
                    ),
                    color:
                        getMaterialColor(controller.widget.boardColor).shade600,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Padding(padding: EdgeInsets.only(left: 16.0)),
                      Expanded(
                        child: Text(
                          widget.list.name,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        color: Colors.white,
                        onPressed: () {
                          showPopupMenu(context, widget.list, controller);
                        },
                      ),
                    ],
                  ),
                ),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                    color:
                        getMaterialColor(controller.widget.boardColor).shade400,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Padding(padding: EdgeInsets.only(left: 16.0)),
                      Expanded(
                        child: Text(
                          widget.list.name,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        color: Colors.white,
                        onPressed: () {
                          showPopupMenu(context, widget.list, controller);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Expanded(
              child: ListView.builder(
                itemCount: widget.cards.length,
                itemBuilder: (context, index) {
                  final card = widget.cards[index];
                  return GestureDetector(
                    onTap: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CardPage(
                            card: card,
                            board: controller.widget.board,
                            boardColor: controller.widget.boardColor,
                            members: controller.members,
                            updateCardById: controller.updateCardById,
                            updateMemberCardIds: controller.updateMemberCardIds,
                          ),
                        ),
                      );
                    },
                    child: buildCard(card, controller),
                  );
                },
              ),
            ),
            // List footer
            buildAddCardRow(widget.list.id, controller),
          ],
        ),
      );
    });
  }
}
