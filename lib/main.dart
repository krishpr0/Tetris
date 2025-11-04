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


//Tetris Game Engine
class TetrisEngine {
  static const int gridWidth = 10;
  static const int gridHeight = 20;
  static const int targetHours = 20;

  List<List<TetrisCell>> grid = [];
  Tetromino? currentPiece;
  Tetromino? nextPiece;
  int score = 0;
  int level = 1;
  int linesCleared = 0;
  bool gameOver = false;
  bool paused = false;
  Duration elapsedTime = Duration.zero;
  DateTime? lastUpdate;
  double fallSpeed = 1.0;

  static final List<TetrominoShape> shapes = [
    TetrominoShape.I,
    TetrominoShape.O,
    TetrominoShape.T,
    TetrominoShape.J,
    TetrominoShape.L,
    TetrominoShape.S,
    TetrominoShape.Z,
  ];

  TetrisEngine() {
    reset();
  }

  void reset() {
      grid = List.generate(gridHeight, (y) => List.generate(gridWidth, (x) => TetrisCell(x, y)));
      score = 0;
      level = 1;
      linesCleared = 0;
      gameOver = false;
      paused = false;
      elapsedTime = Duration.zero;
      lastUpdate = DateTime.now();
      fallSpeed = 1.0;

      nextPiece = _createRandomTetromino() {
        final random = Random();
        final shape = shapes[random.nextInt(shapes.length)];
        return Tetromino(shape);
      }

      void _spawnNewPiece() {
        currentPiece = nextPiece;
        nextPiece = _createRandomTetromino();
        currentPiece!.x = gridWidth ~/ 2 - currentPiece!.width ~/ 2;
        currentPiece!.y = 0;

        if (!_isVaildPosition()) {
          gameOver = true;
        }
      }
      bool _isVaildPosition() {
          for (int y = 0; y < currentPiece!.height; y++) {
            for (int x = 0; x < currentPiece!.width; x++) {
              if (currentPiece!.shape[y][x] == 0) continue;

              final boardX = currentPiece!.x + x;
              final boardY = currentPiece!.y + y;

              if (boardX < 0 || boardX >= gridWidth || boardY >= gridHeight) {
                return false;
              }

              if (boardY >= 0 && grid[boardY][boardX].color != Colors.black){
                return false;
              }
            }
          }
          return  true;
      }

      void movePiece(int dx, int dy) {
        if (paused || gameOver) return;

        currentPiece!.x += dx;
        currentPiece!.y += dy;

        if (!_isVaildPosition()) {
          currentPiece!.x -= dx;
          currentPiece!.y -= dy;

          if (dy > 0) {
            _lockPiece();
            _clearLines();
            _spawnNewPiece();
          }
        }
      }

      void rotatePiece() {
        if (paused || gameOver) return;

        final oldRoatation = currentPiece!.rotation;
        currentPiece!.rotate();

        if (!_isVaildPosition()) {
          currentPiece!.rotation = oldRoatation;
        }
      }

      void _lockPiece() {
        for (int y = 0; y < currentPiece!.height; y++) {
          for (int x = 0; x < currentPiece!.width; x++) {
            if (currentPiece!.shape[y][x] == 0) continue;

            final boardX = currentPiece!.x + x;
            final boardY = currentPiece!.y + y;

            if (boardY >= 0) {
              grid[boardY][boardX].color = currentPiece!.color;
            }
          }
        }
      }


      void _clearLines() {
        int linesClearedThisTurn = 0;

        for (int y = gridHeight - 1; y>= 0; y--) {
          bool lineComplete = true;

          for (int x = 0; x < gridWidth; x++) {
            if (grid[y][x].color == Colors.black) {
              lineComplete = false;
              break;
            }
          }

          if (lineComplete) {
            for (int ny = y; ny > 0; ny--) {
              for (int x = 0; x < gridWidth; x++) {
                grid[ny][x].color = grid[ny - 1][x].color;
              }
            }

            for (int x= 0; x < gridWidth; x++) {
              grid[0][x].color = Colors.black;
            }
            linesClearedThisTurn++;
            y++;
          }
        }

        if (linesClearedThisTurn > 0) {
          linesCleared += linesClearedThisTurn;
          score += linesClearedThisTurn * linesClearedThisTurn * 100 * level;
          level = linesCleared ~/ 10 + 1;
          fallSpeed = 1.0 / level;
        }
      }

      void updateTime() {
        if (paused || gameOver) return;

        final now = DateTime.now();
        if (lastUpdate != null) {
          elapsedTime += now.difference(lastUpdate!);
        }
        lastUpdate = now;
      }

      void togglePause() {
        if (!gameOver) {
          paused = !paused;
          if (!paused) {
            lastUpdate = DateTime.now();
          }
        }
      }

      TetrisCell getCell(int x, int y) {
        if (currentPiece != null && !gameOver) {
          final pieceX = x - currentPiece!.x;
          final pieceY = y - currentPiece!.y;

          if (pieceX >= 0 &&
              pieceX < currentPiece!.width &&
              pieceY >= 0  &&
              pieceY < currentPiece!.height &&
              currentPiece!.shape[pieceY][pieceX] == 1) {
            return TetrisCell(x, y, color: currentPiece!.color);
          }
        }
        return grid[y][x];
      }

      double get progress => elapsedTime.inSeconds / (targetHours * 3600);

      String get formattedTime {
        final hours = elapsedTime.inHours;
        final minutes = elapsedTime.inMinutes.remainder(60);
        final seconds = elapsedTime.inSeconds.remainder(60);
        return '${hours}h ${minutes}m ${seconds}s';
      }
  }

  class TetrisCell {
    final int x, y;
    Color color;

    TetrisCell(this.x, this.y, {this.color = Colors.black});
  }

  enum TetrominoShape {I, O, T, J, L, S, Z}

  class Tetromino {
    TetrominoShape type;
    int x, y;
    int rotation = 0;

    Tetromino(this.type) {
      x = 0;
      y = 0;
  }

  List<List<int> get shape {
      switch (type) {
        case TetrominoShape.I:
          return [
            [1, 1, 1, 1]
        ];

          case TetrominoShape.O:
            return [
              [1, 1], [1, 1]
        ];

            case TetrominoShpae.T:
              return [
                [1, 1, 1], [1, 0, 0]
        ];

              case TetrominoShape.J:
                return [
                  [1, 1, 1], [1, 0, 0]
        ];

                case TetrominoShape.L:
                  return [
                    [1, 1, 1], [0, 0, 1]
        ];

                  case TetrominoShape.S:
                    return [
                      [0, 1, 1], [1, 1, 0]
        ];

                    case TetrominoShape.Z:
                      return [
                        [1, 1, 0], [0, 1, 1]
        ];
      }
    }

    Color get color {
      switch (type) {
        case TetrominoShape.I: return Colors.cyan;
        case TetrominoShape.O: return Colors.yellow;
        case TetrominoShape.T: return Colors.purple;
        case TetrominoShape.J: return Colors.blue;
        case TetrominoShape.L: return Colors.orange;
        case TetrominoShape.S: return Colors.green;
        case TetrominoShape.Z: return Colors.red;
    }
  }

  int get width => shape[0]. length;
    int get height => shape.length;

    void rotate() {
      rotation = (rotation + 1) % 4;
    }
}

