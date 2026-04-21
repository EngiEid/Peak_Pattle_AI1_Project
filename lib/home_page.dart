import 'package:flutter/material.dart';
import 'dart:ui';
import 'main.dart'; // تأكد أن هذا الملف يحتوي على enum AgentType و MapExplorerApp

class GameHomePage extends StatelessWidget {
  const GameHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. خلفية اللعبة
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/background.png'), 
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // 2. طبقة تعتيم فوق الخلفية
          Container(color: Colors.black.withOpacity(0.4)),

          // 3. المحتوى الأساسي
          Center(
            child: SingleChildScrollView( // إضافة للسماح بالتمرير لو زادت الكروت
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "PEAK BATTLE",
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 5,
                      shadows: [
                        Shadow(blurRadius: 10, color: Colors.black.withOpacity(0.8), offset: const Offset(2, 2)),
                      ],
                    ),
                  ),
                  const Text(
                    "Choose Your Opponent's Intelligence",
                    style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w300),
                  ),
                  const SizedBox(height: 40),

                  // خيار Naive
                  _buildAlgoCard(
                    context,
                    title: "The Naive Way",
                    subtitle: "Random moves, zero strategy.",
                    icon: Icons.shuffle,
                    color: Colors.orangeAccent,
                    agentType: AgentType.naive,
                  ),

                  // خيار Hill Climbing
                  _buildAlgoCard(
                    context,
                    title: "Hill Climbing",
                    subtitle: "Always looking for the highest point.",
                    icon: Icons.terrain,
                    color: Colors.greenAccent,
                    agentType: AgentType.hillClimbing,
                  ),

                  // خيار BFS (المعدل)
                  _buildAlgoCard(
                    context,
                    title: "Breadth-First Search",
                    subtitle: "Level-by-level graph exploration.",
                    icon: Icons.hub_outlined, 
                    color: Colors.cyanAccent,
                    agentType: AgentType.bfs,
                  ),

                  // خيار DFS (الجديد)
                  _buildAlgoCard(
                    context,
                    title: "Depth-First Search",
                    subtitle: "Diving deep into the peak paths.",
                    icon: Icons.account_tree_outlined, 
                    color: Colors.deepPurpleAccent,
                    agentType: AgentType.dfs,
                  ),
                  
                  // خيار A* (مغلق حالياً)
                  // _buildAlgoCard(
                  //   context,
                  //   title: "A* Search",
                  //   subtitle: "The shortest path to victory.",
                  //   icon: Icons.auto_awesome,
                  //   color: Colors.blueAccent.withOpacity(0.5),
                  //   isLocked: true,
                  //   agentType: null, 
                  // ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlgoCard(BuildContext context, 
      {required String title, 
      required String subtitle, 
      required IconData icon, 
      required Color color, 
      required AgentType? agentType,
      bool isLocked = false}) {
    return GestureDetector(
      onTap: isLocked ? null : () {
        Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (context) => MapExplorerApp(selectedAgent: agentType!)
          )
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8), // تقليل المسافة قليلاً
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7), // زيادة التغبيش لشكل أرقى
            child: Container(
              width: 320,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isLocked ? Colors.white12 : color.withOpacity(0.7), 
                  width: 1.5
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isLocked ? Colors.transparent : color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isLocked ? Icons.lock_outline : icon, 
                      color: isLocked ? Colors.grey : color, 
                      size: 32
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title, 
                          style: TextStyle(
                            color: isLocked ? Colors.grey : Colors.white, 
                            fontSize: 17, 
                            fontWeight: FontWeight.bold
                          )
                        ),
                        Text(
                          subtitle, 
                          style: const TextStyle(color: Colors.white60, fontSize: 11)
                        ),
                      ],
                    ),
                  ),
                  if (!isLocked) 
                    const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}