import 'package:flutter/material.dart';
import 'package:trelltech/controllers/card_controller.dart';
import 'package:trelltech/models/card_model.dart';
import 'package:trelltech/widgets/appbar.dart';

class CardPage extends StatefulWidget {
  const CardPage({super.key, required this.card, required this.boardColor});
  final CardModel card;
  final Color boardColor;

  @override
  State<CardPage> createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
  final CardController _cardsController = CardController();
  List<CardModel> details = [];

  @override
  void initState() {
    super.initState();
    _loadCardDetails();
  }

  void _loadCardDetails() async {
    final cardDetails =
        await _cardsController.getCardDetails(card: widget.card);
    setState(() {
      details = cardDetails;
    });
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
              data: details.isNotEmpty ? details[0].desc : 'Loading...',
            ),
            cardDetailsContainer(
              icon: Icons.description,
              data: details.isNotEmpty ? details[0].name : 'Loading...',
            ),
          ],
        ),
      ),
    );
  }

  Widget cardDetailsContainer({IconData? icon, String? data}) {
    return Container(
      width: MediaQuery.of(context).size.width,
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
            SizedBox(width: 20), // Adjust the spacing as needed
            Text(
              data ?? '',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
