#!/bin/bash

# Define file names
DOMAIN_FILE="grid-domain.pddl"
PROBLEM_FILE="grid-problem.pddl"
PLANNER="./fast-downward.py"
PYTHON_SCRIPT="a_star.py"

# Step 1: Write the PDDL domain file
cat <<EOT > $DOMAIN_FILE
(define (domain gridworld)
  (:requirements :strips)

  (:predicates
    (at ?x ?y)  
    (goal ?x ?y) 
    (blocked ?x ?y) 
    (adjacent ?x1 ?y1 ?x2 ?y2)
  )

  (:action move
    :parameters (?x1 ?y1 ?x2 ?y2)
    :precondition (and (at ?x1 ?y1) (adjacent ?x1 ?y1 ?x2 ?y2) (not (blocked ?x2 ?y2)))
    :effect (and (at ?x2 ?y2) (not (at ?x1 ?y1)))
  )
)
EOT

echo "✅ Domain file created: $DOMAIN_FILE"

# Step 2: Write the Python A* script
cat <<EOT > $PYTHON_SCRIPT
import heapq

class AStarPlanner:
    def __init__(self, grid_size, start, goal, obstacles):
        self.grid_size = grid_size
        self.start = start
        self.goal = goal
        self.obstacles = set(obstacles)
        self.moves = [(0, 1), (1, 0), (0, -1), (-1, 0)]

    def heuristic(self, a, b):
        return abs(a[0] - b[0]) + abs(a[1] - b[1])

    def neighbors(self, node):
        x, y = node
        for dx, dy in self.moves:
            nx, ny = x + dx, y + dy
            if 0 <= nx < self.grid_size and 0 <= ny < self.grid_size and (nx, ny) not in self.obstacles:
                yield (nx, ny)

    def find_path(self):
        open_list = []
        heapq.heappush(open_list, (0, self.start))
        came_from = {self.start: None}
        g_score = {self.start: 0}
        f_score = {self.start: self.heuristic(self.start, self.goal)}

        while open_list:
            _, current = heapq.heappop(open_list)
            if current == self.goal:
                return self.reconstruct_path(came_from)
            for neighbor in self.neighbors(current):
                tentative_g = g_score[current] + 1
                if neighbor not in g_score or tentative_g < g_score[neighbor]:
                    came_from[neighbor] = current
                    g_score[neighbor] = tentative_g
                    f_score[neighbor] = tentative_g + self.heuristic(neighbor, self.goal)
                    heapq.heappush(open_list, (f_score[neighbor], neighbor))

        return None

    def reconstruct_path(self, came_from):
        current = self.goal
        path = []
        while current:
            path.append(current)
            current = came_from[current]
        return path[::-1]

# Define grid
grid_size = 5
start = (0, 0)
goal = (4, 4)
obstacles = [(2, 2), (3, 3)]

planner = AStarPlanner(grid_size, start, goal, obstacles)
path = planner.find_path()

if path:
    print("A* Path:", path)
    with open("grid-problem.pddl", "w") as f:
        f.write("(define (problem move-agent)\n  (:domain gridworld)\n  (:objects 0 1 2 3 4)\n  (:init\n    (at 0 0)\n    (goal 4 4)\n")
        for obs in obstacles:
            f.write(f"    (blocked {obs[0]} {obs[1]})\n")
        for x in range(grid_size):
            for y in range(grid_size):
                for dx, dy in [(0, 1), (1, 0), (0, -1), (-1, 0)]:
                    nx, ny = x + dx, y + dy
                    if 0 <= nx < grid_size and 0 <= ny < grid_size:
                        f.write(f"    (adjacent {x} {y} {nx} {ny})\n")
        f.write("  )\n  (:goal (at 4 4))\n)")
    print("✅ Problem file generated")
else:
    print("❌ No path found")
EOT

echo "✅ Python A* script created: $PYTHON_SCRIPT"

# Step 3: Run the A* algorithm to generate the problem PDDL file
echo "🔍 Running A* search..."
python3 $PYTHON_SCRIPT

# Step 4: Run Fast Downward Planner
echo "🚀 Running Fast Downward planner..."
$PLANNER $DOMAIN_FILE $PROBLEM_FILE --search "astar(lmcut())"

echo "✅ Planning complete!"
