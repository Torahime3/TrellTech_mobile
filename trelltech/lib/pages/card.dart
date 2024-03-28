import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trelltech/controllers/card_controller.dart';
import 'package:trelltech/models/board_model.dart';
import 'package:trelltech/models/card_model.dart';
import 'package:trelltech/models/member_model.dart';
import 'package:trelltech/utils/materialcolor_utils.dart';
import 'package:trelltech/utils/date_format.dart';
import 'package:trelltech/widgets/appbar.dart';
import 'package:trelltech/widgets/member_avatar.dart';

class CardPage extends StatefulWidget {
  final CardModel card;
  final BoardModel board;
  final Color boardColor;
  final List<MemberModel> members;
  final void Function() loadMembers;
  final void Function(String cardId,
      {String? name, String? startDate, String? dueDate}) updateCardById;
  final void Function(String memberId, String newCardIds, bool isAdding)
      updateMemberCardIds;

  const CardPage({
    super.key,
    required this.card,
    required this.board,
    required this.boardColor,
    required this.members,
    required this.loadMembers,
    required this.updateCardById,
    required this.updateMemberCardIds,
  });

  @override
  State<CardPage> createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
  late final TextEditingController _descriptionController =
      TextEditingController();
  List<MemberModel> members = [];
  final CardController _cardsController = CardController();
  DateTime? selectedStartDate;
  DateTime? selectedDueDate;
  List<String> selectedMemberIds = [];
  final GlobalKey _buttonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _descriptionController.text = widget.card.desc;
    members = widget.members;
    if (widget.card.startDate.isNotEmpty) {
      selectedStartDate = DateTime.parse(widget.card.startDate);
    }
    if (widget.card.dueDate.isNotEmpty) {
      selectedDueDate = DateTime.parse(widget.card.dueDate);
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final boardColor = widget.boardColor;
    List<MemberModel> cardMembers = members
        .where((member) => member.cardIds.contains(widget.card.id))
        .toList();

    return Scaffold(
      appBar: appbar(
        text: widget.card.name,
        color: boardColor,
        showEditButton: false,
      ),
      backgroundColor: getMaterialColor(boardColor).shade700,
      body: SingleChildScrollView(
        child: Column(
          children: [
            descriptionContainer(
              icon: Icons.description,
              data: widget.card.desc,
              onTap: () {
                _editDescription();
              },
            ),
            avatarContainer(
              icon: Icons.person,
              avatars: cardMembers
                  .map(
                      (member) => MemberAvatar(initials: member.initials ?? ''))
                  .toList(),
            ),
            dateContainer(), // Adding the date container
          ],
        ),
      ),
    );
  }

  Widget dateContainer() {
    return Container(
      margin: const EdgeInsets.all(12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        children: [
          const Icon(Icons.schedule),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  showStartDatePicker();
                },
                child: Row(
                  children: [
                    const Text(
                      'Start Date',
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      selectedStartDate == null
                          ? ': none'
                          : ': ${selectedStartDate!.displayedDate()}',
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 2,
                width: 280,
                color: Colors.black,
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  showDueDatePicker();
                },
                child: Row(
                  children: [
                    const Text(
                      'End Date',
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      selectedDueDate == null
                          ? ': none'
                          : ': ${selectedDueDate!.displayedDate()}',
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDatePicker(
      DateTime? selectedDate,
      void Function(DateTime) onUpdateDate,
      bool isStartDate // Indicates whether it's for start date or due date
      ) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 300.0,
          child: Column(
            children: [
              Expanded(
                child: CupertinoDatePicker(
                  initialDateTime: selectedDate ?? DateTime.now(),
                  onDateTimeChanged: (DateTime newDate) {
                    setState(() {
                      selectedDate = newDate;
                    });
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      onUpdateDate(selectedDate!);
                      String formattedDate = trelloDate(selectedDate!);
                      if (isStartDate) {
                        _cardsController.update(widget.card.id,
                            startDate: formattedDate);
                        widget.updateCardById(widget.card.id,
                            startDate: formattedDate);
                      } else {
                        _cardsController.update(widget.card.id,
                            dueDate: formattedDate);
                        widget.updateCardById(widget.card.id,
                            dueDate: formattedDate);
                      }
                      Navigator.pop(context);
                    },
                    child: const Text('Update'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void showStartDatePicker() {
    _showDatePicker(selectedStartDate, (DateTime newDate) {
      setState(() {
        selectedStartDate = newDate;
      });
    }, true); // Pass true to indicate it's for the start date
  }

  void showDueDatePicker() {
    _showDatePicker(selectedDueDate, (DateTime newDate) {
      setState(() {
        selectedDueDate = newDate;
      });
    }, false); // Pass false to indicate it's for the due date
  }

  Widget avatarContainer({
    required IconData icon,
    required List<Widget> avatars,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(12.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(10.0),
        ),
        constraints:
            const BoxConstraints(minHeight: 75), // Set the minimum height
        child: IntrinsicHeight(
          child: Padding(
            padding: const EdgeInsets.all(0.0),
            child: Stack(
              children: [
                _buildIcon(icon),
                Positioned(
                  top: 1,
                  left: 40, // Adjust this value as needed
                  child: _buildAvatarsContainer(avatars),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(IconData icon) {
    return Positioned(
      top: 10,
      left: 0,
      child: Icon(
        icon,
        color: Colors.black,
        size: 24,
      ),
    );
  }

  Widget descriptionContainer({
    required IconData icon,
    String? data,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(12.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(10.0),
        ),
        constraints:
            const BoxConstraints(minHeight: 75), // Set the minimum height
        child: IntrinsicHeight(
          child: Padding(
            padding: const EdgeInsets.all(0.0),
            child: Stack(
              children: [
                _buildIcon(icon),
                _buildDescription(data),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDescription(String? data) {
    final bool hasData = data?.isNotEmpty == true;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(width: 40), // Width for the icon
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: data?.contains('\n') == true
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  hasData ? data! : 'Tap to add description',
                  style: TextStyle(
                    fontSize: 18,
                    color: hasData
                        ? Colors.black
                        : Colors.grey, // Set color based on data presence
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 10,
                  textAlign: data?.contains('\n') == true
                      ? TextAlign.start
                      : TextAlign.center, // Check if multiline or not
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _editDescription() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Description'),
          content: TextField(
            controller: _descriptionController,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            decoration: const InputDecoration(
              hintText: 'Enter the description...',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Call the updateDesc method from card_controller
                _cardsController.updateDesc(
                  id: widget.card.id, // Pass the card id
                  desc: _descriptionController.text, // Pass the new description
                  onUpdated: () {
                    // Handle any UI update after the description is updated
                    setState(() {
                      widget.card.desc = _descriptionController.text;
                    });
                  },
                );
                Navigator.of(context).pop();
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAvatarsContainer(List<Widget> avatars) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (Widget avatar in avatars)
              Padding(
                padding: const EdgeInsets.only(
                    right: 4.0), // Adjust spacing as needed
                child: avatar,
              ),
          ],
        ),
        GestureDetector(
          key: _buttonKey, // Assign the GlobalKey to the green button
          onTap: () {
            _showCardOptionsMenu(context, widget.card);
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showCardOptionsMenu(BuildContext context, CardModel card) {
    // Use the GlobalKey to get the position of the green button
    final RenderBox button =
        _buttonKey.currentContext!.findRenderObject() as RenderBox;
    final Offset buttonPosition = button.localToGlobal(Offset.zero);

    final List<MemberModel> cardMembers = widget.members
        .where((member) => member.cardIds.contains(card.id))
        .toList();

    final List<MemberModel> boardMembers = widget.members
        .where((member) => !member.cardIds.contains(card.id))
        .toList();

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        buttonPosition.dx,
        buttonPosition.dy + 40,
        buttonPosition.dx,
        buttonPosition.dy,
      ),
      items: [
        if (boardMembers.isNotEmpty)
          const PopupMenuItem(
            enabled: false,
            child: Text('Board Members', style: TextStyle(color: Colors.grey)),
          ),
        for (final member in boardMembers)
          PopupMenuItem(
            value: 'board_member_${member.id}',
            onTap: () {
              // Remove the card member from the card
              _cardsController.addMemberToCard(
                memberId: member.id,
                cardId: card.id,
                onAdded: () {
                  widget.updateMemberCardIds(member.id, card.id, true);
                  setState(() {});
                },
              );
            },
            child: ListTile(
              title: Text(member.name),
              leading: CircleAvatar(
                backgroundColor: Colors.transparent,
                child: MemberAvatar(initials: member.initials ?? ''),
              ),
            ),
          ),
        if (cardMembers.isNotEmpty)
          const PopupMenuItem(
            enabled: false,
            child: Text('Card Members', style: TextStyle(color: Colors.grey)),
          ),
        for (final member in cardMembers)
          PopupMenuItem(
            value: 'card_member_${member.id}',
            onTap: () {
              // Remove the card member from the card
              _cardsController.removeMemberFromCard(
                memberId: member.id,
                cardId: card.id,
                onDeleted: () {
                  widget.updateMemberCardIds(member.id, card.id, false);
                  setState(() {});
                },
              );
            },
            child: ListTile(
              title: Text(member.name),
              leading: CircleAvatar(
                backgroundColor: Colors.transparent,
                child: MemberAvatar(initials: member.initials ?? ''),
              ),
            ),
          ),
      ],
    );
  }
}
