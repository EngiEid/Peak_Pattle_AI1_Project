import 'package:flutter/material.dart';
import 'dart:ui';
import 'main.dart';

class GameHomePage extends StatelessWidget {
  const GameHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          Container(color: Colors.black.withOpacity(0.4)),

Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const SizedBox(height: 60), 
      
      Text(
        "PEAK BATTLE",
        style: TextStyle(
          fontSize: 50,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          letterSpacing: 5,
          shadows: [
            Shadow(
              blurRadius: 10,
              color: Colors.black.withOpacity(0.8),
              offset: const Offset(2, 2),
            ),
          ],
        ),
      ),
      const Text(
        "Choose Your Opponent's Intelligence",
        style: TextStyle(
          color: Colors.white70,
          fontSize: 16,
          fontWeight: FontWeight.w300,
        ),
      ),
      
      const SizedBox(height: 30),

      Container(
        height: 450,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.transparent, 
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(), 
            child: Column(
              children: [
                _buildAlgoCard(
                  context,
                  title: "The Naive Way",
                  subtitle: "Random moves, zero strategy.",
                  icon: Icons.shuffle,
                  color: Colors.orangeAccent,
                  agentType: AgentType.naive,
                ),
                _buildAlgoCard(
                  context,
                  title: "Hill Climbing",
                  subtitle: "Always looking for the highest point.",
                  icon: Icons.terrain,
                  color: Colors.greenAccent,
                  agentType: AgentType.hillClimbing,
                ),
                _buildAlgoCard(
                  context,
                  title: "Breadth-First Search",
                  subtitle: "Level-by-level graph exploration.",
                  icon: Icons.hub_outlined,
                  color: Colors.cyanAccent,
                  agentType: AgentType.bfs,
                ),
                _buildAlgoCard(
                  context,
                  title: "Depth-First Search",
                  subtitle: "Diving deep into the peak paths.",
                  icon: Icons.account_tree_outlined,
                  color: Colors.deepPurpleAccent,
                  agentType: AgentType.dfs,
                ),
                _buildAlgoCard(
                  context,
                  title: "A* Search",
                  subtitle: "The shortest path to victory.",
                  icon: Icons.auto_awesome,
                  color: Colors.blueAccent.withOpacity(0.5),
                  agentType: AgentType.aStar,
                ),
                _buildAlgoCard(
                  context,
                  title: "Greedy Search",
                  subtitle: "Fast and direct, but is it optimal?",
                  icon: Icons.flash_on,
                  color: Colors.pinkAccent,
                  agentType: AgentType.greedy,
                ),
                const SizedBox(height: 20), 
              ],
            ),
          ),
        ),
      ),
    ],
  ),
),
        ],
      ),
    );
  }

  Widget _buildAlgoCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required AgentType? agentType,
    bool isLocked = false,
  }) {
    return GestureDetector(
      onTap: isLocked
          ? null
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      MapExplorerApp(selectedAgent: agentType!),
                ),
              );
            },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8,
        ), 
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 7,
              sigmaY: 7,
            ), 
            child: Container(
              width: 320,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isLocked ? Colors.white12 : color.withOpacity(0.7),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isLocked
                          ? Colors.transparent
                          : color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isLocked ? Icons.lock_outline : icon,
                      color: isLocked ? Colors.grey : color,
                      size: 32,
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
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isLocked)
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white24,
                      size: 14,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
