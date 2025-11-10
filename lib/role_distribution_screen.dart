import 'dart:math';
import 'package:flutter/material.dart';
import 'game_round_screen.dart';

class RoleDistributionScreen extends StatefulWidget {
  final List<String> playerNames;

  // Optional predefined data (used for Restart Game)
  final List<String>? predefinedRoles;
  final String? predefinedCitizenWord;
  final String? predefinedUndercoverWord;

  const RoleDistributionScreen({
    super.key,
    required this.playerNames,
    this.predefinedRoles,
    this.predefinedCitizenWord,
    this.predefinedUndercoverWord,
  });

  @override
  State<RoleDistributionScreen> createState() => _RoleDistributionScreenState();
}

class _RoleDistributionScreenState extends State<RoleDistributionScreen> {
  final List<List<String>> wordPairs = [
    ['Cat', 'Tiger'],
    ['Coffee', 'Tea'],
    ['Ship', 'Boat'],
    ['Sun', 'Moon'],
    ['Pencil', 'Pen'],
    ['Apple', 'Banana'],
    ['Chair', 'Table'],
    ['Laptop', 'Computer'],
    ['Rain', 'Snow'],
  ];

  late int undercoverIndex;
  late String citizenWord;
  late String undercoverWord;
  late List<String> roles;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    final random = Random();

    if (widget.predefinedRoles != null &&
        widget.predefinedCitizenWord != null &&
        widget.predefinedUndercoverWord != null) {
      // Restart case: use provided roles and words
      roles = List.from(widget.predefinedRoles!);
      citizenWord = widget.predefinedCitizenWord!;
      undercoverWord = widget.predefinedUndercoverWord!;
    } else {
      // Normal case: generate random undercover and word pair
      undercoverIndex = random.nextInt(widget.playerNames.length);
      final pair = wordPairs[random.nextInt(wordPairs.length)];
      citizenWord = pair[0];
      undercoverWord = pair[1];

      roles = List.generate(
        widget.playerNames.length,
            (i) => i == undercoverIndex ? 'Undercover' : 'Citizen',
      );
    }
  }

  void _nextPlayer() {
    setState(() {
      currentIndex++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // All players viewed their role
    if (currentIndex >= widget.playerNames.length) {
      return Scaffold(
        appBar: AppBar(title: const Text('Roles Ready')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'All players have seen their roles!',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameRoundScreen(
                        names: widget.playerNames,
                        roles: roles,
                        citizenWord: citizenWord,
                        undercoverWord: undercoverWord,
                      ),
                    ),
                  );
                },
                child: const Text('Start Game'),
              ),
            ],
          ),
        ),
      );
    }

    // Current player's info
    final playerName = widget.playerNames[currentIndex];
    final playerRole = roles[currentIndex];
    final playerWord =
    playerRole == 'Undercover' ? undercoverWord : citizenWord;

    return Scaffold(
      appBar: AppBar(title: const Text('Role Distribution')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Pass the device to $playerName',
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Your Role'),
                    content: Text(
                      'Role: $playerRole\nWord: $playerWord\n\nKeep it secret!',
                      style: const TextStyle(fontSize: 18),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // close dialog
                          _nextPlayer();
                        },
                        child: const Text('Done'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Show My Role'),
            ),
            const SizedBox(height: 15),
            Text(
              '(${currentIndex + 1}/${widget.playerNames.length})',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
