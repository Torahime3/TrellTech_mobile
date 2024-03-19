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
        showEditButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: details.isEmpty
            ? const Text(
                'Loading...') // Display loading text while details are fetched
            : Text(
                details[0].desc ?? '',
                style: const TextStyle(fontSize: 18),
              ),
      ),
    );
  }
}
