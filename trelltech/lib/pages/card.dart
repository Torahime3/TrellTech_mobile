import 'package:flutter/material.dart';
import 'package:trelltech/controllers/member_controller.dart';
import 'package:trelltech/models/card_model.dart';
import 'package:trelltech/models/member_model.dart';
import 'package:trelltech/widgets/appbar.dart';
import 'package:trelltech/widgets/memberAvatar.dart';

class CardPage extends StatefulWidget {
  final CardModel card;
  final Color boardColor;

  const CardPage({Key? key, required this.card, required this.boardColor})
      : super(key: key);

  @override
  State<CardPage> createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
  final MemberController _memberController = MemberController();
  List<MemberModel> members = [];

  @override
  void initState() {
    super.initState();
    _loadMembers();
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
      print('Error loading members: $e');
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
            ),
            SizedBox(height: 16),
            if (members.isNotEmpty)
              Container(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                height: 50.0,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: MemberAvatar(
                        initials: members[index].initials,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

Widget cardDetailsContainer({IconData? icon, String? data}) {
  return Container(
    margin: const EdgeInsets.all(12.0),
    padding: const EdgeInsets.all(16.0),
    decoration: BoxDecoration(
      color: Color.fromARGB(255, 0, 0, 0),
      borderRadius: BorderRadius.circular(10.0),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
          ),
          SizedBox(width: 20),
          Text(
            data ?? '',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ],
      ),
    ),
  );
}
