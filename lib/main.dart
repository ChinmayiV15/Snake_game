import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(SnakeGameApp());
}

class SnakeGameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.black,
        hintColor: Colors.green,
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.green,
        ),
      ),
      home: SnakeGameScreen(),
    );
  }
}

class SnakeGameScreen extends StatefulWidget {
  @override
  _SnakeGameScreenState createState() => _SnakeGameScreenState();
}

class _SnakeGameScreenState extends State<SnakeGameScreen> {
  static const int _rows = 20;
  static const int _columns = 20;
  static const double _squareSize = 20.0;
  final Random _random = Random();
  final GlobalKey _boardKey = GlobalKey();
  List<Point<int>> _snake = [Point(10, 10)];
  Point<int> _food = Point(5, 5);
  String _direction = 'up';
  Timer? _timer;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _startGame();
    _loadSounds();
  }

  void _startGame() {
    _snake = [Point(10, 10)];
    _direction = 'up';
    _score = 0;
    _placeFood();
    _timer = Timer.periodic(Duration(milliseconds: 150), (timer) {
      _moveSnake();
    });
  }

  void _loadSounds() async {
    // Load sound assets here
  }

  void _playSound(String sound) {
    // Play sound based on action
  }

  void _placeFood() {
    setState(() {
      _food = Point(
        _random.nextInt(_columns),
        _random.nextInt(_rows),
      );
    });
  }

  void _moveSnake() {
    setState(() {
      Point<int> newHead;

      switch (_direction) {
        case 'up':
          newHead = Point(_snake.first.x, _snake.first.y - 1);
          break;
        case 'down':
          newHead = Point(_snake.first.x, _snake.first.y + 1);
          break;
        case 'left':
          newHead = Point(_snake.first.x - 1, _snake.first.y);
          break;
        case 'right':
          newHead = Point(_snake.first.x + 1, _snake.first.y);
          break;
        default:
          return;
      }

      if (_snake.contains(newHead) ||
          newHead.x < 0 ||
          newHead.y < 0 ||
          newHead.x >= _columns ||
          newHead.y >= _rows) {
        _timer?.cancel();
        _showGameOverDialog();
        return;
      }

      _snake.insert(0, newHead);

      if (newHead == _food) {
        _score += 10; // Increase score
        _placeFood();
        _playSound('eat');
      } else {
        _snake.removeLast();
      }
    });
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Game Over', style: TextStyle(color: Colors.red)),
          backgroundColor: Colors.black,
          content: Text('Your score: $_score', style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _startGame();
              },
              child: Text('Restart', style: TextStyle(color: Colors.green)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Share score functionality
              },
              child: Text('Share', style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  void _changeDirection(String newDirection) {
    setState(() {
      if (_direction == 'up' && newDirection == 'down' ||
          _direction == 'down' && newDirection == 'up' ||
          _direction == 'left' && newDirection == 'right' ||
          _direction == 'right' && newDirection == 'left') {
        return;
      }
      _direction = newDirection;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _buildBoard() {
    return Container(
      key: _boardKey,
      width: _columns * _squareSize,
      height: _rows * _squareSize,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, Colors.grey[900]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.green, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Draw the snake
          for (var point in _snake)
            AnimatedPositioned(
              duration: Duration(milliseconds: 150),
              left: point.x * _squareSize,
              top: point.y * _squareSize,
              child: Container(
                width: _squareSize,
                height: _squareSize,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.8),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          // Draw the food
          Positioned(
            left: _food.x * _squareSize,
            top: _food.y * _squareSize,
            child: Container(
              width: _squareSize,
              height: _squareSize,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [Colors.red, Colors.orange],
                  center: Alignment(0, 0),
                  radius: 1.0,
                ),
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.8),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectionButton(IconData icon, String direction) {
    return ElevatedButton(
      onPressed: () => _changeDirection(direction),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.all(16),
        elevation: 8,
        shadowColor: Colors.green.withOpacity(0.6),
      ),
      child: Icon(icon, color: Colors.black, size: 24),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Snake Game', style: TextStyle(color: Colors.green)),
        centerTitle: true,
        backgroundColor: Colors.black,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                'Score: $_score',
                style: TextStyle(color: Colors.green, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: _buildBoard(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDirectionButton(Icons.arrow_upward, 'up'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDirectionButton(Icons.arrow_back, 'left'),
                    SizedBox(width: 20),
                    _buildDirectionButton(Icons.arrow_forward, 'right'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDirectionButton(Icons.arrow_downward, 'down'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
