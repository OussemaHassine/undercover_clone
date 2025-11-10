import 'package:flutter/material.dart';
import 'player_setup_screen.dart';
import 'role_distribution_screen.dart';

void main() {
  runApp(const UndercoverApp());
}

class UndercoverApp extends StatelessWidget {
  const UndercoverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Undercover Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.deepPurple,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/roleDistribution': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return RoleDistributionScreen(
            playerNames: List<String>.from(args['names']),
            predefinedRoles: List<String>.from(args['roles']),
            predefinedCitizenWord: args['citizenWord'],
            predefinedUndercoverWord: args['undercoverWord'],
          );
        },
      },
    );
    ;
  }
}


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Undercover Game')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PlayerSetupScreen(),
              ),
            );
          },
          child: const Text('Start Game Setup'),
        ),
      ),
    );
  }
}

