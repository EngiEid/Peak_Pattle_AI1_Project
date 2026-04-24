# 🏔️ Peak Battle: Human vs AI Explorer

**Peak Battle** is an interactive pathfinding game and AI visualization tool built with Flutter. Challenge different AI strategies to reach the global peak of a procedurally generated map or use the **Analysis Mode** to visualize how different search algorithms "think."

---

## 🚀 Features

- **Real-time Gameplay:** Move your character using a stylized D-Pad to reach the summit.
- **Diverse AI Opponents:** Play against 6 different AI agents, ranging from random moves to advanced pathfinding.
- **Strategy Analysis Mode:** After the game, dive deep into the AI's logic. Visualize the **Search Graph** and the **Final Path** it discovered.
- **Gamified UI:** Elastic animations, custom painters for the map, and a sleek dark-themed interface.
- **Dynamic Maps:** Every game feels different with our hill-shading map generation logic.

---

## 🧠 AI Agents (The Intelligence)

The project showcases a variety of search algorithms classified by their logic:

### 🔍 Uninformed Search
- **Breadth-First Search (BFS):** Explores level-by-level. Guaranteed to find the shortest path in an unweighted graph.
- **Depth-First Search (DFS):** Dives deep into paths. Uses a stack-based approach to explore the map's boundaries.

### 💡 Informed Search (Heuristic-based)
- **A* Search:** The gold standard. Combines actual cost and estimated distance (Heuristic) to find the most optimal path efficiently.
- **Greedy Best-First Search:** Focused purely on the goal. Fast but doesn't always find the shortest path.

### 🧗 Local Search
- **Hill Climbing:** Always moves towards a higher elevation. Simple yet prone to getting stuck in "Local Peaks."

---

## 🛠️ Project Structure

The project is organized into a modular directory structure to separate concerns between UI, logic, and AI algorithms:

```text
lib/
├── 📁 gui/                     # UI components, map logic, and custom painters
│   ├── map_logic.dart
│   └── map_painter.dart
├── 📁 best_first_Search/         # Heuristic-based search algorithms
│   ├── a_star_agent.dart
│   └── greedy_agent.dart
├── 📁 Local_Search/            # Optimization & local search algorithms
│   └── hill_climbing_agent.dart
├── 📁 random_search/           # Baseline movement logic
│   └── naive_agent.dart
├── 📁 uninformed_search/       # Blind search algorithms
│   ├── bfs_agent.dart
│   └── dfs_agent.dart
├── graph_factory.dart          # Utility for building search graphs
├── home_page.dart              # Main menu and algorithm selection
├── main.dart                   # Application entry point
└── Problem_formulation.dart    # Definitions of states, actions, and costs
