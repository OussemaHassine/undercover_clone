import 'package:flutter/material.dart';
import 'role_distribution_screen.dart';

class PlayerSetupScreen extends StatefulWidget {
  const PlayerSetupScreen({super.key});

  @override
  State<PlayerSetupScreen> createState() => _PlayerSetupScreenState();
}

class _PlayerSetupScreenState extends State<PlayerSetupScreen> {
  final TextEditingController _numPlayersController = TextEditingController();
  List<TextEditingController> _nameControllers = [];
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
            // 🧮 Number of players input
            TextField(
              controller: _numPlayersController,
              decoration: const InputDecoration(
                labelText: 'Number of players (3–12)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final n = int.tryParse(value);

                // ✅ If empty or invalid -> reset the state
                if (n == null || n < 3 || n > 12) {
                  setState(() {
                    _numPlayers = null;
                    _nameControllers = [];
                  });
                  return;
                }

                // ✅ Valid number -> regenerate controllers
                setState(() {
                  _numPlayers = n;
                  _nameControllers =
                      List.generate(n, (_) => TextEditingController());
                });
              },
            ),

            const SizedBox(height: 16),

            // 🧍‍♂️ Player name inputs (only shown when valid count)
            if (_numPlayers != null && _numPlayers! >= 3 && _numPlayers! <= 12)
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

            // 🚀 Start Game Button
            ElevatedButton(
              onPressed: _numPlayers == null
                  ? null
                  : () {
                final names =
                _nameControllers.map((c) => c.text.trim()).toList();

                if (names.any((name) => name.isEmpty)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter all player names!'),
                      behavior: SnackBarBehavior.floating,
                      margin: EdgeInsets.all(16),
                    ),
                  );
                  return;
                }

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
