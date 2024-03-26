import 'package:flutter/material.dart';
import 'package:trelltech/controllers/card_controller.dart';
import 'package:trelltech/controllers/member_controller.dart';
import 'package:trelltech/models/board_model.dart';
import 'package:trelltech/models/card_model.dart';
import 'package:trelltech/models/member_model.dart';
import 'package:trelltech/widgets/appbar.dart';
import 'package:trelltech/widgets/member_avatar.dart';

class CardPage extends StatefulWidget {
  final CardModel card;
  final BoardModel board;
  final Color boardColor;

  const CardPage(
      {super.key,
      required this.card,
      required this.board,
      required this.boardColor});

  @override
  State<CardPage> createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
  final MemberController _memberController = MemberController();
  List<MemberModel> members = [];
  final CardController _cardsController = CardController();
  late final TextEditingController _descriptionController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMembers();
    // ignore: avoid_print
    print(widget.card.id);
    _descriptionController.text = widget.card.desc; // Set initial value
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _loadMembers() async {
    try {
      List<MemberModel> memberDetails = [];
      for (String memberId in widget.card.idMembers) {
        final MemberModel member =
            await _memberController.getMemberDetails(id: memberId);
        memberDetails.add(member);
      }
      setState(() {
        members = memberDetails;
      });
    } catch (e) {
      throw ('Error loading members: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final boardColor = widget.boardColor;
    return Scaffold(
      appBar: appbar(
        text: widget.card.name,
        color: boardColor,
        showEditButton: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            cardDetailsContainer(
              icon: Icons.description,
              data: widget.card.desc,
              onTap: () {
                _editDescription();
              },
            ),
            cardDetailsContainer(
              icon: Icons.person,
              avatars: members
                  .map((member) => MemberAvatar(initials: member.initials))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget cardDetailsContainer({
    required IconData icon,
    String? data,
    List<Widget>? avatars,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(12.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 0, 0, 0),
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
                if (avatars != null && avatars.isNotEmpty)
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
        color: Colors.white,
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
                  style: const TextStyle(fontSize: 18, color: Colors.white),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: avatars,
            ),
            const SizedBox(
              width: 8,
            ), // Add spacing between avatars and the "+" button
            GestureDetector(
              onTap: () {
                _showCardOptionsMenu(
                    context, widget.card); // Call the method here
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
        ),
      ],
    );
  }

  void _showCardOptionsMenu(BuildContext context, CardModel card) {
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
          enabled: false,
          child: Text('Board Mem', style: TextStyle(color: Colors.grey)),
        ),
        const PopupMenuItem(
          value: 'update',
          child: ListTile(
            title: Text('Update'),
          ),
        ),
        const PopupMenuItem(
          enabled: false,
          child: Text('Card Members', style: TextStyle(color: Colors.grey)),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: ListTile(
            title: Text('Delete'),
          ),
        ),
      ],
    );
  }
}
