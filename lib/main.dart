import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const TetrisApp());
}

class TetrisApp extends StatelessWidget {
  const TetrisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tetirs',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const TetrisGame(),
    );
  }
}

class TetrisGame extends StatefulWidget {
  const TetrisGame ({super.key});

  @override
  State<TetrisGame> createState() => _TetrisGameState();
}

class _TetrisGameState extends  State<TetrisGame> {
  final TetrisEngine _engine = TetrisEngine();
  Timer? _gameTimer;
  Timer? _fallTimer;

  @override
  void initState() {
    super.initState();
    _startGame();

  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _fallTimer?.cancel();
    super.dispose();
  }

  void _startGame() {
    _engine.reset();

    _gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      setState(() {
        _engine.updateTime();
      });
    });

    _fallTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!_engine.paused && !_engine.gameOver) {
        setState(() {
          _engine.movePiece(0, 1);
        });
      }
    });
  }

  void _restartGame() {
    setState(() {
      _engine.reset();
    });
  }

  void _togglePause() {
    setState(() {
      _engine.togglePause();
    });
  }

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 10),
                Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildGameBoard(),
                        const SizedBox(width: 10),
                        _buildSidebar(),
                      ],
                    ),
                ),
                _buildControls(),
              ],
            ),
          ),
      ),
    );
  }

  Widget _buildHeader() {
    final progress = _engine.progress;
    return Column(
      children: [
        Text(
          'Tetris',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 20,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(10),
              ),,
            ),
            AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 20,
              width: 20,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.green, Colors.lightGreen],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Positioned.fill(
              child: Center(
                child: Text(
                  '${(progress * 100).toStringAsFixed(1)}% Complete',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Elasped: ${_engine.formattedTime}',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ],
    );
  }


  Widget _buildGameBoard() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white54, width: 2),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: TetrisEngine.gridWidth),
      ),
      itemCount: TetrisEngine.gridWidth * TetrisEngine.gridHeight,
      itemBuilder: (context, index) {
        final x = index % TetrisEngine.gridWidth;
        final y = index ~/ TetrisEngine.gridWidth;
        final Cell = _engine.getCell(x, y);

        return Container(
          margin: const EdgeInsets.all(0.6),
          decoration: BoxDecoration(
            color: cell.color,
            border: cell.color != Colors.black ? Border.all(color: Colors.white30, width: 1) : null,
          ),
        );
      },
    ),
    );
  }


  Widget _buildSidebar() {
    return SizedBox(
      width: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard('Score', _engine.score.toString()),
          _buildInfoCard('Level', _engine.level.toString()),
          _buildInfoCard('Lines', _engine.linesCleared.toString()),

          const SizedBox(height: 20),

          Text(
            'Next',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 5),
          _buildNextPiecePreview(),

          const Spacer(),

          if(_engine.gameOver)
            _buildStatusCard('GAME OVER', Colors.red)
          else if (_engine.paused)
            _buildStatusCard('PAUSED', Colors.orange),

          const SizedBox(height: 20),

          _buildControlsInfo(),
        ],
      ),
    );
  }


  Widget _buildInfoCard(String title, String value) {
    return Card(
      color: Colors.grey[900],
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start ,
            children: [
              Text(
                value,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                ),
              ),
            ],
          ),
      ),
    );
  }


  Widget _buildStatusCard(String text, Color color) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
              fontWeight: FontWeight.bold
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }


  Widget _buildNextPiecePreview() {
    final nextPiece = _engine.nextPiece;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: nextPiece.shape.map((row) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((cell) {
              return Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: cell == 1 ? nextPiece.color : Colors.transparent,
                  border: cell == 1? Border.all(color: Colors.white30) : null,
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }


  Widget _buildControlsInfo() {
    return Card(
      color: Colors.grey[900],
      child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Controls:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold
                ),
              ),
              SizedBox(height: 4),
              Text(
                '<-_->: Move\n: Rotate\n: Soft Drop\n: Pause\n: Restart',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 10
                ),
              ),
            ],
          ),
        ),
      );
    }


    Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          //Left Button
          _buildControlButton(Icons.arrow_left, () {
            if (!_engine.paused && !_engine.gameOver) {
              setState(() => _engine.movePiece(-1, 0));
            }
          }),

          //Rotate Button
          _buildControlButton(Icons.arrow_upward, () {
            if (!_engine.paused && !_engine.gameOver) {
              setState(() => _engine.rotatePiece());
            }
          }),

          //Right Button
          _buildControlButton(Icons.arrow_right, () {
            if (!_engine.paused && !_engine.gameOver) {
              setState(() => _engine.movePiece(1,0));
            }
          }),

          //Down Button
          _buildControlButton(Icons.arrow_downward, () {
            if (!_engine.paused && !_engine.gameOver) {
              setState(() => _engine.movePiece(0, 1));
            }
          }),

          //Pause Button
          _buildControlButton(_engine.paused ? Icons.play_arrow : Icons.pause, _togglePause,
            color: _engine.paused ? Colors.green : Colors.orange,
          ),

          // Restart button
          _buildControlButton(Icons.refresh, _restartGane, color: Colors.red),
        ],
      ),
    );
  }


  Widget _buildControlButton(IconData icon, VoidCallback onPressed, {Color? color}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? Colors.blue,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(16),
      ),
      onPressed: onPressed,
      child: Icon(icon, color: Colors.white),
    );
  }
}


