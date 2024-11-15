import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OfflineRunnerGame(),
    );
  }
}

class OfflineRunnerGame extends StatefulWidget {
  const OfflineRunnerGame({super.key});

  @override
  _OfflineRunnerGameState createState() => _OfflineRunnerGameState();
}

class _OfflineRunnerGameState extends State<OfflineRunnerGame> {
  // Player position and jump states
  double playerY = 1.0; // Character's vertical position
  double initialPlayerY = 1.0;
  bool isJumping = false;

  // Obstacle positions
  double obstacleX = 1.0;
  bool gameHasStarted = false;

  // Game mechanics
  double time = 0;
  double height = 0;
  double gravity = -4.9; // Gravity constant for jump arc
  double jumpVelocity = 3.5; // Initial jump velocity

  void startGame() {
    gameHasStarted = true;
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      // Gravity for jump mechanic
      time += 0.05;
      height = jumpVelocity * time + gravity * time * time;

      if (isJumping) {
        setState(() {
          playerY = initialPlayerY - height;
        });
      }

      // Reset jump
      if (playerY > 1.0) {
        setState(() {
          playerY = 1.0;
          isJumping = false;
          time = 0;
        });
      }

      // Move obstacle toward the player
      setState(() {
        obstacleX -= 0.05;
      });

      // Reset obstacle position and check for collision
      if (obstacleX < -1.2) {
        obstacleX = 1.0; // Reset obstacle
      }

      // Check for collision
      if (obstacleX < 0.1 && obstacleX > -0.1 && playerY > 0.9) {
        timer.cancel();
        gameHasStarted = false;
        _showGameOverDialog();
      }
    });
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Game Over"),
        content: const Text("You hit an obstacle!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              resetGame();
            },
            child: const Text("Play Again"),
          ),
        ],
      ),
    );
  }

  void jump() {
    if (!isJumping) {
      setState(() {
        time = 0;
        initialPlayerY = playerY;
        isJumping = true;
      });
    }
  }

  void resetGame() {
    setState(() {
      playerY = 1.0;
      obstacleX = 1.0;
      gameHasStarted = false;
      isJumping = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (gameHasStarted) {
          jump();
        } else {
          startGame();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.blue[200],
        body: Center(
          child: Stack(
            children: [
              // Game Start Message
              Container(
                alignment: const Alignment(0, -0.5),
                child: gameHasStarted
                    ? const SizedBox.shrink()
                    : const Text(
                        "TAP TO START",
                        style: TextStyle(fontSize: 24, color: Colors.white),
                      ),
              ),
              // Player
              AnimatedContainer(
                alignment: Alignment(0, playerY),
                duration: const Duration(milliseconds: 0),
                child: Container(
                  height: 50,
                  width: 50,
                  color: Colors.yellow,
                ),
              ),
              // Obstacle
              AnimatedContainer(
                alignment: Alignment(obstacleX, 1.0),
                duration: const Duration(milliseconds: 0),
                child: Container(
                  height: 40,
                  width: 40,
                  color: Colors.red,
                ),
              ),
              // Ground
              Align(
                alignment: const Alignment(0, 1),
                child: Container(
                  height: 10,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
