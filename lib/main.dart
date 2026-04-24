import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'Gui/map_logic.dart';
import 'Gui/map_painter.dart';
import 'home_page.dart';
import 'random_search/naive_agent.dart';
import 'Problem_formulation.dart';
import 'Local_Search/hill_climbing_agent.dart';
import 'UnInformed_Search/bfs_agent.dart';
import 'UnInformed_Search/dfs_agent.dart';
import 'Informed_Search/a_star_agent.dart';
import 'Informed_Search/greedy_agent.dart';

void main() => runApp(
  const MaterialApp(debugShowCheckedModeBanner: false, home: GameHomePage()),
);

enum AgentType { naive, hillClimbing, bfs, dfs, aStar, greedy }

class MapExplorerApp extends StatefulWidget {
  final AgentType selectedAgent;
  const MapExplorerApp({super.key, required this.selectedAgent});

  @override
  State<MapExplorerApp> createState() => _MapExplorerAppState();
}

class _MapExplorerAppState extends State<MapExplorerApp>
    with TickerProviderStateMixin {
  late MapData mapData;
  late AnimationController _moveController;
  late Animation<Offset> _playerAnimation;
  bool _showGraph = false;
  bool _showFinalPath = false;

  dynamic _aiAgent;

  Offset _aiPos = const Offset(0, 0);
  Timer? _aiTimer;

  final double stepSize = 5.0;

  Offset _currentPos = const Offset(100, 100);
  Offset _targetPos = const Offset(100, 100);
  Timer? _holdTimer;
  Timer? _gameTimer;
  int _secondsElapsed = 0;
  int _moveCount = 0;

  @override
  void initState() {
    super.initState();

    _moveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5),
    );
    _playerAnimation = Tween<Offset>(
      begin: _currentPos,
      end: _targetPos,
    ).animate(_moveController);

    _initGame();
  }

  void _initGame() {
    mapData = MapData(Random().nextInt(10000), step: stepSize);
    AIProblem problem = AIProblem(mapData, stepSize);

    Offset startPoint = const Offset(100, 100);

    if (widget.selectedAgent == AgentType.naive) {
      _aiAgent = NaiveAgent(problem, startPoint);
    } else if (widget.selectedAgent == AgentType.hillClimbing) {
      _aiAgent = HillClimbingAgent(problem, startPoint);
    } else if (widget.selectedAgent == AgentType.bfs) {
      List<Offset> peaks = mapData.findAllLocalPeaks();
      _aiAgent = BFSAgent(problem, peaks, startPoint);
    } else if (widget.selectedAgent == AgentType.dfs) {
      List<Offset> peaks = mapData.findAllLocalPeaks();
      _aiAgent = DFSAgent(problem, peaks, startPoint);
    } else if (widget.selectedAgent == AgentType.aStar) {
      // التعديل هنا
      List<Offset> peaks = mapData.findAllLocalPeaks();
      _aiAgent = AStarAgent(problem, peaks, startPoint);
    } else if (widget.selectedAgent == AgentType.greedy) {
      List<Offset> peaks = mapData.findAllLocalPeaks();
      _aiAgent = GreedyAgent(problem, peaks, startPoint);
    }

    _aiPos = startPoint;
    _currentPos = startPoint;

    _startTimer();
    _startAiLogic();
  }

  void _startTimer() {
    _gameTimer?.cancel();
    _secondsElapsed = 0;
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => _secondsElapsed++);
    });
  }

  void _startAiLogic() {
    _aiTimer?.cancel();
    _aiTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (mounted) {
        setState(() {
          _aiPos = _aiAgent.getNextMove();
        });
        _checkWin();
      }
    });
  }

  void _reset() {
    setState(() {
      _initGame();
      _showFinalPath = false;
      _currentPos = const Offset(100, 100);
      _targetPos = const Offset(100, 100);
      _moveCount = 0;
      _playerAnimation = Tween<Offset>(
        begin: _currentPos,
        end: _targetPos,
      ).animate(_moveController);
    });
  }

  void _move(double dx, double dy) {
    if (_moveController.isAnimating) return;
    setState(() {
      _moveCount++;
      _targetPos = Offset(
        (_currentPos.dx + dx).clamp(0.0, 199.0),
        (_currentPos.dy + dy).clamp(0.0, 199.0),
      );
      _playerAnimation = Tween<Offset>(
        begin: _currentPos,
        end: _targetPos,
      ).animate(_moveController);
      _moveController.forward(from: 0.0).then((_) {
        _currentPos = _targetPos;
        _checkWin();
      });
    });
  }

  void _startMoving(double dx, double dy) {
    _move(dx, dy);
    _holdTimer = Timer.periodic(
      const Duration(milliseconds: 120),
      (timer) => _move(dx, dy),
    );
  }

  void _stopMoving() => _holdTimer?.cancel();

  void _checkWin() {
    double playerDist = (_currentPos - mapData.globalPeakPos).distance;
    if (playerDist < 4.0) {
      _stopGame();
      _showGamifiedWinDialog(isPlayerWinner: true);
      return;
    }

    double aiDist = (_aiPos - mapData.globalPeakPos).distance;
    if (aiDist < 4.0) {
      _stopGame();
      _showGamifiedWinDialog(isPlayerWinner: false);
      return;
    }
  }

  void _stopGame() {
    _stopMoving();
    _gameTimer?.cancel();
    _aiTimer?.cancel();
  }

  void _showGamifiedWinDialog({required bool isPlayerWinner}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (context, anim1, anim2) => const SizedBox(),
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.elasticOut),
          child: AlertDialog(
            backgroundColor: isPlayerWinner
                ? const Color(0xFFFFF9C4)
                : const Color(0xFFE0E0E0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: BorderSide(
                color: isPlayerWinner ? Colors.orange : Colors.grey,
                width: 5,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isPlayerWinner
                      ? "You did it, champ! ✨"
                      : "AI reached first! 🤖",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isPlayerWinner ? Colors.brown : Colors.blueGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                Icon(
                  isPlayerWinner
                      ? Icons.emoji_events
                      : Icons.sentiment_very_dissatisfied,
                  size: 80,
                  color: isPlayerWinner ? Colors.orange : Colors.grey,
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _childStat("Time ⏱️", "$_secondsElapsed sec"),
                      _childStat("Steps 👣", "$_moveCount"),
                    ],
                  ),
                ),
                if (!isPlayerWinner)
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      "Better luck next time!",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  ),
              ],
            ),
actionsAlignment: MainAxisAlignment.center,
          actions: [
            // نستخدم Column هنا لترتيب الأزرار فوق بعضها بشكل جمالي
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. زر العودة للرئيسية
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPlayerWinner ? Colors.orange : Colors.blueGrey,
                    minimumSize: const Size(200, 45), // تكبير الزر قليلاً
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // قفل الديالموج
                    Navigator.pop(context); // الرجوع للهوم
                  },
                  child: const Text(
                    "Back to Home 🏠",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                const SizedBox(height: 8), // مسافة بسيطة بين الزرين

                // 2. زر التحليل (يظهر فقط لأنواع معينة من الـ AI)
                if (widget.selectedAgent != AgentType.naive &&
                    widget.selectedAgent != AgentType.hillClimbing)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _showFinalPath = true;
                        _showGraph = true;
                      });
                      Navigator.pop(context); // قفل الديالوج فقط
                    },
                    icon: const Icon(Icons.auto_awesome_motion, color: Colors.blueGrey),
                    label: const Text(
                      "Analyze AI Strategy 🧠",
                      style: TextStyle(
                        color: Colors.blueGrey, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                
                const SizedBox(height: 10),
              ],
            ),
          ],
        ));
      },
    );
  }

  Widget _childStat(String label, String val) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          val,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.brown,
          ),
        ),
      ],
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2EBD3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF4E342E)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Human vs AI",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF4E342E),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(width: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "⏱️ $_secondsElapsed",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // منطقة الخريطة مع زر الـ Graph
          Center(
            child: Stack(
              // استخدمنا Stack هنا لوضع الزر فوق الخريطة
              children: [
                Container(
                  width: 360,
                  height: 360,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF4E342E),
                      width: 5,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: AnimatedBuilder(
                    animation: _playerAnimation,
                    builder: (context, child) => CustomPaint(
                      painter: MapPainter(
                        mapData,
                        _currentPos,
                        aiPos: _aiPos,
                        showGraph: _showGraph,
                        // التعديل هنا ليشمل الحالتين
                        aiGraph: (widget.selectedAgent == AgentType.bfs)
                            ? (_aiAgent as BFSAgent).graph
                            : (widget.selectedAgent == AgentType.dfs)
                            ? (_aiAgent as DFSAgent).graph
                            : (widget.selectedAgent ==
                                  AgentType.aStar) // أضيفي هذا السطر
                            ? (_aiAgent as AStarAgent).graph
                            : (widget.selectedAgent == AgentType.greedy)
                            ? (_aiAgent as GreedyAgent).graph
                            : null,
                        aiNodePath: _showFinalPath ? _aiAgent.nodePath : null,
                      ),
                    ),
                  ),
                ),

                // زر تبديل الـ Graph (يظهر فقط في حالة BFS)
                // زر تبديل الـ Graph (يظهر في BFS و DFS)
                if (widget.selectedAgent == AgentType.bfs ||
                    widget.selectedAgent == AgentType.dfs ||
                    widget.selectedAgent == AgentType.aStar ||
                    widget.selectedAgent ==
                        AgentType.greedy) // أضيفي الـ aStar هنا
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: () => setState(() => _showGraph = !_showGraph),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4E342E).withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _showGraph
                              ? Icons.auto_graph
                              : Icons.polyline_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 40),
          _buildDpad(),
        ],
      ),
    );
  }

  Widget _buildDpad() {
    return Column(
      children: [
        _controlBtn("↑", () => _startMoving(0, stepSize)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _controlBtn("←", () => _startMoving(-stepSize, 0)),
            const SizedBox(width: 15),
            _actionBtn("NEW", _reset),
            const SizedBox(width: 15),
            _controlBtn("→", () => _startMoving(stepSize, 0)),
          ],
        ),
        _controlBtn("↓", () => _startMoving(0, -stepSize)),
      ],
    );
  }

  Widget _controlBtn(String label, VoidCallback onDown) {
    return GestureDetector(
      onTapDown: (_) => onDown(),
      onTapUp: (_) => _stopMoving(),
      onTapCancel: () => _stopMoving(),
      child: Container(
        width: 65,
        height: 65,
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: const Color(0xFFD7CCC8),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF5D4037), width: 2),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _actionBtn(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 65,
        height: 65,
        decoration: const BoxDecoration(
          color: Color(0xFF5D4037),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
