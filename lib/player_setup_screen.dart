import 'package:flutter/material.dart';
import 'role_distribution_screen.dart';

class PlayerSetupScreen extends StatefulWidget {
  const PlayerSetupScreen({super.key});

  @override
  State<PlayerSetupScreen> createState() => _PlayerSetupScreenState();
}

class _PlayerSetupScreenState extends State<PlayerSetupScreen> {
  // Controller for number of players input
  final TextEditingController _numPlayersController = TextEditingController();

  // List of controllers for player name inputs
  List<TextEditingController> _nameControllers = [];

  // Stores the chosen number of players
  int? _numPlayers;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Player Setup')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input: number of players
            TextField(
              controller: _numPlayersController,
              decoration: const InputDecoration(
                labelText: 'Number of players (3–12)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final n = int.tryParse(value);
                // Only accept valid range between 3 and 12
                if (n != null && n >= 3 && n <= 12) {
                  setState(() {
                    _numPlayers = n;
                    // Create a text controller for each player's name
                    _nameControllers =
                        List.generate(n, (_) => TextEditingController());
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            // Dynamically show name fields for each player
            if (_numPlayers != null)
              Expanded(
                child: ListView.builder(
                  itemCount: _numPlayers!,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: TextField(
                        controller: _nameControllers[index],
                        decoration: InputDecoration(
                          labelText: 'Player ${index + 1} name',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Start Game Button
            ElevatedButton(
              onPressed: _numPlayers == null
                  ? null // Disabled if no player count entered
                  : () {
                // Collect all entered names
                final names =
                _nameControllers.map((c) => c.text.trim()).toList();

                // Simple validation: ensure all names are filled
                if (names.any((name) => name.isEmpty)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter all player names!'),
                    ),
                  );
                  return;
                }

                // Navigate to Role Distribution Screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RoleDistributionScreen(playerNames: names),
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
}
