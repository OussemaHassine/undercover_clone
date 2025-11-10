import 'package:flutter/material.dart';
import 'dart:math';
import 'role_distribution_screen.dart'; // import to navigate back there

class GameRoundScreen extends StatefulWidget {
  final List<String> names;
  final List<String> roles;
  final String citizenWord;
  final String undercoverWord;

  const GameRoundScreen({
    super.key,
    required this.names,
    required this.roles,
    required this.citizenWord,
    required this.undercoverWord,
  });

  @override
  State<GameRoundScreen> createState() => _GameRoundScreenState();
}

class _GameRoundScreenState extends State<GameRoundScreen> {
  late List<String> remainingPlayers;
  late List<String> remainingRoles;
  Map<String, int> votes = {};
  bool votingPhase = false;
  int roundNumber = 1;

  // possible word pairs
  final List<List<String>> wordPairs = [
    ['Cat', 'Tiger'],
    ['Coffee', 'Tea'],
    ['Ship', 'Boat'],
    ['Sun', 'Moon'],
    ['Pencil', 'Pen'],
    ['Apple', 'Banana'],
    ['Chair', 'Table'],
  ];

  late String citizenWord;
  late String undercoverWord;

  @override
  void initState() {
    super.initState();
    // Initialize with values from previous screen
    remainingPlayers = List.from(widget.names);
    remainingRoles = List.from(widget.roles);
    citizenWord = widget.citizenWord;
    undercoverWord = widget.undercoverWord;
    _resetVotes();
  }

  void _resetVotes() {
    votes = {for (var p in remainingPlayers) p: 0};
  }

  void _voteFor(String player) {
    setState(() {
      votes[player] = (votes[player] ?? 0) + 1;
    });
  }

  void _eliminateHighestVoted() {
    int maxVotes = votes.values.reduce(max);
    List<String> topVoted =
    votes.entries.where((e) => e.value == maxVotes).map((e) => e.key).toList();

    // tie = no elimination
    if (topVoted.length > 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('It’s a tie! No one is eliminated this round.')),
      );
      setState(() {
        roundNumber++;
        votingPhase = false;
        _resetVotes();
      });
      return;
    }

    final eliminated = topVoted.first;
    final roleIndex = remainingPlayers.indexOf(eliminated);
    final eliminatedRole = remainingRoles[roleIndex];

    setState(() {
      remainingPlayers.removeAt(roleIndex);
      remainingRoles.removeAt(roleIndex);
      votingPhase = false;
      roundNumber++;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$eliminated was eliminated! ($eliminatedRole)')),
    );

    _checkWinConditions();
  }

  void _checkWinConditions() {
    if (!remainingRoles.contains('Undercover')) {
      _showGameResult('Citizens Win! 🎉');
    } else if (remainingPlayers.length == 2) {
      _showGameResult('Undercover Wins! 😈');
    } else {
      _resetVotes();
    }
  }

  void _showGameResult(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Game Over'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // back to home
            },
            child: const Text('Back to Home'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              _restartToRoleDistribution();
            },
            child: const Text('Restart Game'),
          ),
        ],
      ),
    );
  }

  // 🧩 Restart flow — go back to Role Distribution
  void _restartToRoleDistribution() {
    final random = Random();

    // new random words
    final pair = wordPairs[random.nextInt(wordPairs.length)];
    final citizenWord = pair[0];
    final undercoverWord = pair[1];

    // new undercover
    final undercoverIndex = random.nextInt(widget.names.length);
    final roles = List.generate(
      widget.names.length,
          (i) => i == undercoverIndex ? 'Undercover' : 'Citizen',
    );

    // navigate to Role Distribution
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => RoleDistributionScreen(
          playerNames: widget.names,
          predefinedRoles: roles,
          predefinedCitizenWord: citizenWord,
          predefinedUndercoverWord: undercoverWord,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game Rounds')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Round $roundNumber',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Remaining Players: ${remainingPlayers.length}',
              style: const TextStyle(fontSize: 18),
            ),
            const Divider(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: remainingPlayers.length,
                itemBuilder: (context, index) {
                  final player = remainingPlayers[index];
                  final playerVotes = votes[player] ?? 0;

                  return Card(
                    elevation: 2,
                    child: ListTile(
                      title: Text(player),
                      subtitle: votingPhase
                          ? Text('Votes: $playerVotes',
                          style: const TextStyle(fontSize: 16))
                          : null,
                      trailing: votingPhase
                          ? IconButton(
                        icon: const Icon(Icons.how_to_vote),
                        onPressed: () => _voteFor(player),
                      )
                          : null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(bottom: 20), // lifts above snackbar
              child: SafeArea(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  onPressed: () {
                    if (!votingPhase) {
                      setState(() {
                        votingPhase = true;
                        _resetVotes();
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Voting phase started — everyone votes!'),
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.all(16),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } else {
                      _eliminateHighestVoted();
                    }
                  },
                  child: Text(
                    votingPhase
                        ? 'Eliminate Voted Player'
                        : 'Start Voting Phase',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
