// ignore_for_file: avoid_print

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

  const CardPage({
    super.key,
    required this.card,
    required this.board,
    required this.boardColor,
    required this.members,
    required this.loadMembers,
    required this.updateCardById,
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

  @override
  void initState() {
    super.initState();
    _descriptionController.text = widget.card.desc; // Set initial value
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
    print('Start date : ${widget.card.startDate}');
    print('Due date : ${widget.card.dueDate}');
    final boardColor = widget.boardColor;
    print('members: $members');
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
              avatars: members
                  .where((member) => member.cardIds.contains(widget.card.id))
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
                      style: TextStyle(color: Colors.black),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      selectedStartDate == null
                          ? ': none'
                          : ': ${selectedStartDate!.displayedDate()}',
                      style: const TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 1,
                width: 280,
                color: Colors.grey,
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
                      style: TextStyle(color: Colors.black),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      selectedDueDate == null
                          ? ': none'
                          : ': ${selectedDueDate!.displayedDate()}',
                      style: const TextStyle(color: Colors.black),
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

  Widget _buildDescription(String? data) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 40), // Width for the icon
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  data ?? '',
                  style: const TextStyle(fontSize: 18, color: Colors.black),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 10,
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
          children: avatars,
        ),
        const SizedBox(
          width: 8,
        ),
        GestureDetector(
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
    final RenderBox button = context.findRenderObject() as RenderBox;
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
        buttonPosition.dy,
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
                  loadMembers: () {
                    widget.loadMembers();
                  });
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
                  loadMembers: () {
                    widget.loadMembers();
                  });
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

    // Print statements to show member name, ID, and cardIds
    print('Board Members:');
    for (final member in boardMembers) {
      print(
          'Name: ${member.name}, ID: ${member.id}, cardIds: ${member.cardIds}');
      print('Current card ID: ${card.id}');
    }

    print('Card Members:');
    for (final member in cardMembers) {
      print(
          'Name: ${member.name}, ID: ${member.id}, cardIds: ${member.cardIds}');
      print('Current card ID: ${card.id}');
    }
  }
}
