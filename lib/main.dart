import 'dart:ui';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Enable full-screen immersive mode.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(GameWidget(game: TheGridGame()));
}

class TheGridGame extends FlameGame with HasKeyboardHandlerComponents {
  late Player player;
  List<ZoneComponent> zones = [];
  String currentZone = "Empty Area";

  @override
  Future<void> onLoad() async {
    // Add background that covers the full screen.
    add(Background());
    double currentWidth = canvasSize.x;
    double currentHeight = canvasSize.y;
    // Create and add zones with initial positions.
    zones.add(ZoneComponent(
        zoneName: 'Lounge',
        position: Vector2(currentWidth * 0.1, currentHeight * 0.1)));
    zones.add(ZoneComponent(
        zoneName: 'Meeting Pods',
        position: Vector2(currentWidth * 0.6, currentHeight * 0.1)));
    zones.add(ZoneComponent(
        zoneName: 'Workstations',
        position: Vector2(currentWidth * 0.1, currentHeight * 0.6)));
    zones.add(ZoneComponent(
        zoneName: 'Hallway',
        position: Vector2(currentWidth * 0.6, currentHeight * 0.6)));

    for (var zone in zones) {
      zone.size = Vector2(currentWidth * 0.25, currentHeight * 0.25);
      add(zone);
    }

    // Add the player at an initial position.
    player = Player(position: Vector2(10, 10));
    add(player);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Check for collision between the player and any zone.
    String zoneFound = "Empty Area";
    for (var zone in zones) {
      if (player.toRect().overlaps(zone.toRect())) {
        zoneFound = zone.zoneName;
        break;
      }
    }
    // If the zone changes (or player leaves), log the transition.
    if (zoneFound != currentZone) {
      currentZone = zoneFound ?? "Empty Area";
      
        print('Entered zone: $currentZone');
     
    }
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    // Get the current window dimensions.
    double currentWidth = canvasSize.x;
    double currentHeight = canvasSize.y;
    print(currentWidth);
    print(currentHeight);

    // Update zone positions and sizes relative to the window.
    if (zones.isNotEmpty) {
      zones[0].position =
          Vector2(currentWidth * 0.1, currentHeight * 0.1); // Lounge
      zones[1].position =
          Vector2(currentWidth * 0.6, currentHeight * 0.1); // Meeting Pods
      zones[2].position =
          Vector2(currentWidth * 0.1, currentHeight * 0.6); // Workstations
      zones[3].position =
          Vector2(currentWidth * 0.6, currentHeight * 0.6); // Hallway

      // Optionally, adjust the size of each zone.
      for (var zone in zones) {
        zone.size = Vector2(currentWidth * 0.25, currentHeight * 0.25);
      }
    }
  }
}

class Background extends Component with HasGameRef<TheGridGame> {
  @override
  void render(Canvas canvas) {
    // Use the current game size to cover the entire screen.
    final size = gameRef.size;
    final paint = Paint()..color = Colors.grey.shade300;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), paint);
  }
}

class ZoneComponent extends PositionComponent {
  final String zoneName;
  final TextPaint textPaint = TextPaint(
    style: const TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
  );

  ZoneComponent({
    required this.zoneName,
    required Vector2 position,
  }) : super(position: position, size: Vector2(120, 120));

  @override
  void render(Canvas canvas) {
    // Draw the zone rectangle.
    final paint = Paint()..color = Colors.blueAccent;
    canvas.drawRect(size.toRect(), paint);

    // Overlay the zone name.
    textPaint.render(canvas, zoneName, Vector2(10, 40));
  }
}

class Player extends PositionComponent with KeyboardHandler {
  final double speed = 100.0; // Speed in pixels per second.
  Vector2 velocity = Vector2.zero();
  final TextPaint textPaint = TextPaint(
    style: const TextStyle(
      color: Colors.green,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  );

  Player({required Vector2 position})
      : super(position: position, size: Vector2(30, 30));

  @override
  void render(Canvas canvas) {
    // Draw the player as a green square.
    final paint = Paint()..color = Colors.green;
    canvas.drawRect(size.toRect(), paint);
    textPaint.render(canvas, 'You', Vector2(2, 5));
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Update the player's position based on its velocity.
    position.add(velocity * dt);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // Reset velocity before processing input.
    velocity = Vector2.zero();
    if (keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      velocity.y = -speed;
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
      velocity.y = speed;
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      velocity.x = -speed;
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      velocity.x = speed;
    }
    return true;
  }
}
