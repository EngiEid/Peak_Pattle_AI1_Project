import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'map_logic.dart';
import 'map_painter.dart';
import 'home_page.dart'; // تأكدي من استيراد ملف الـ Home Page الجديد
import 'naive_agent.dart';
import 'Problem_formulation.dart';
import 'hill_climbing_agent.dart';
import 'bfs_agent.dart';
import 'dfs_agent.dart';

void main() => runApp(
  const MaterialApp(
    debugShowCheckedModeBanner: false,
    home:
        GameHomePage(), // تم التغيير هنا لتكون نقطة البداية هي الصفحة الرئيسية
  ),
);

enum AgentType { naive, hillClimbing, bfs, dfs }

class MapExplorerApp extends StatefulWidget {
  final AgentType selectedAgent; // استلام نوع الـ AI المختار
  const MapExplorerApp({super.key, required this.selectedAgent});

  @override
  State<MapExplorerApp> createState() => _MapExplorerAppState();
}

class _MapExplorerAppState extends State<MapExplorerApp>
    with TickerProviderStateMixin {
  late MapData mapData;
  late AnimationController _moveController;
  late Animation<Offset> _playerAnimation;
  bool _showGraph = false; // هل نظهر الرسم البياني؟

  // حل المشكلة: تعريف واحد فقط ونوعه dynamic ليدعم كل أنواع الـ Agents
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
    // تأكدي من استدعاء الأنيميشن قبل _initGame أو العكس بحذر
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

    // نقطة البداية الموحدة (المنتصف)
    Offset startPoint = const Offset(100, 100);

    if (widget.selectedAgent == AgentType.naive) {
      _aiAgent = NaiveAgent(problem, startPoint);
    } else if (widget.selectedAgent == AgentType.hillClimbing) {
      _aiAgent = HillClimbingAgent(problem, startPoint);
    } else if (widget.selectedAgent == AgentType.bfs) {
      List<Offset> peaks = mapData.findAllLocalPeaks();
      _aiAgent = BFSAgent(problem, peaks, startPoint);
    }
    if (widget.selectedAgent == AgentType.dfs) {
      List<Offset> peaks = mapData.findAllLocalPeaks();
      _aiAgent = DFSAgent(problem, peaks, startPoint);
    }

    // تحديث موقع الـ AI ليبدأ من المنتصف فعلياً في الرسم
    _aiPos = startPoint;
    _currentPos = startPoint; // اللاعب يبدأ من المنتصف أيضاً

    _startTimer();
    _startAiLogic();
  }

  // بقية الدوال (startTimer, startAiLogic, move...) تبقى كما هي

  void _startTimer() {
    _gameTimer?.cancel();
    _secondsElapsed = 0;
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => _secondsElapsed++);
    });
  }

  void _startAiLogic() {
    _aiTimer?.cancel();
    // خلي الـ AI يتحرك كل 300ms عشان يتماشى مع سرعة الـ AnimationController
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
    // فحص فوز اللاعب
    double playerDist = (_currentPos - mapData.globalPeakPos).distance;
    if (playerDist < 4.0) {
      // مسافة سماح للاعب
      _stopGame();
      _showGamifiedWinDialog(isPlayerWinner: true);
      return;
    }

    // فحص فوز الـ AI
    double aiDist = (_aiPos - mapData.globalPeakPos).distance;
    if (aiDist < 4.0) {
      // مسافة سماح للـ AI
      _stopGame();
      _showGamifiedWinDialog(isPlayerWinner: false);
      return;
    }
  }

  // دالة مساعدة لإيقاف كل الموقتات والحركات
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
                // تغيير العنوان بناءً على النتيجة
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
                // تغيير الأيقونة: كأس للفوز أو وجه حزين للخسارة
                Icon(
                  isPlayerWinner
                      ? Icons.emoji_events
                      : Icons.sentiment_very_dissatisfied,
                  size: 80,
                  color: isPlayerWinner ? Colors.orange : Colors.grey,
                ),
                const SizedBox(height: 15),
                // إحصائيات الجولة
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
            actions: [
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPlayerWinner
                        ? Colors.orange
                        : Colors.blueGrey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // إغلاق الـ Dialog
                    Navigator.pop(context); // العودة للـ Home Page
                  },
                  child: const Text(
                    "Back to Home 🏠",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
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
          // صف العنوان والتايمر
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
                            : null,
                      ),
                    ),
                  ),
                ),

                // زر تبديل الـ Graph (يظهر فقط في حالة BFS)
                // زر تبديل الـ Graph (يظهر في BFS و DFS)
                if (widget.selectedAgent == AgentType.bfs ||
                    widget.selectedAgent == AgentType.dfs)
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
