import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => MemoryGameProvider(),
      child: MaterialApp(
        home: MemoryGameApp(),
      ),
    ),
  );
}

class CardModel {
  final int id;
  final String frontImage; // Specify the path to the front image for each card
  bool isFaceUp = false;

  CardModel(this.id, this.frontImage);
}

class MemoryGameProvider extends ChangeNotifier {
  List<CardModel> cards = [];
  List<CardModel> selectedCards = [];
  bool isGameWon = false;

  MemoryGameProvider() {
    // Initialize the cards list with your card data.
    for (int i = 0; i < 8; i++) {
      cards.add(CardModel(i, 'assets/card${i + 1}.png'));
      cards.add(CardModel(i + 8, 'assets/card${i + 1}.png'));
    }

    // Shuffle the cards.
    cards.shuffle();
  }

  void flipCard(int cardId) {
    if (!isGameWon) {
      if (selectedCards.length < 2) {
        final card = cards.firstWhere((c) => c.id == cardId);
        if (!card.isFaceUp) {
          card.isFaceUp = true;
          selectedCards.add(card);
          if (selectedCards.length == 2) {
            if (selectedCards[0].frontImage == selectedCards[1].frontImage) {
              selectedCards.clear();
              if (cards.every((card) => card.isFaceUp)) {
                isGameWon = true;
                notifyListeners();
              }
            } else {
              Future.delayed(const Duration(seconds: 1), () {
                for (final selectedCard in selectedCards) {
                  selectedCard.isFaceUp = false;
                }
                selectedCards.clear();
                notifyListeners();
              });
            }
          }
          notifyListeners();
        }
      }
    }
  }
}

class MemoryGameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Memory Card Game')),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, // You can adjust the grid size
                ),
                itemBuilder: (context, index) {
                  return MemoryCard(index);
                },
              ),
            ),
            if (Provider.of<MemoryGameProvider>(context).isGameWon)
              Text('You won!'),
          ],
        ),
      ),
    );
  }
}

class MemoryCard extends StatelessWidget {
  final int cardIndex;

  MemoryCard(this.cardIndex);

  @override
  Widget build(BuildContext context) {
    final cardProvider = Provider.of<MemoryGameProvider>(context);

    if (cardIndex < cardProvider.cards.length) {
      final card = cardProvider.cards[cardIndex];

      return GestureDetector(
        onTap: () {
          cardProvider.flipCard(card.id);
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: card.isFaceUp ? Colors.white : Colors.blue, // Change the background color
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: card.isFaceUp
                ? Image.asset(card.frontImage) // Display the front image
                : Container(),  // Empty container for the back
          ),
        ),
      );
    } else {
      // Handle the case where cardIndex is out of bounds.
      return Container(); // Or display a placeholder.
    }
  }
}
