import heapq

class AStarPlanner:
    def __init__(self, grid_size, start, goal, obstacles):
        self.grid_size = grid_size
        self.start = start
        self.goal = goal
        self.obstacles = set(obstacles)
        self.moves = [(0, 1), (1, 0), (0, -1), (-1, 0)]  # Right, Down, Left, Up

    def heuristic(self, a, b):
        """Manhattan distance heuristic"""
        return abs(a[0] - b[0]) + abs(a[1] - b[1])

    def neighbors(self, node):
        """Get valid adjacent nodes"""
        x, y = node
        for dx, dy in self.moves:
            nx, ny = x + dx, y + dy
            if 0 <= nx < self.grid_size and 0 <= ny < self.grid_size and (nx, ny) not in self.obstacles:
                yield (nx, ny)

    def find_path(self):
        """A* search"""
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

        return None  # No path found

    def reconstruct_path(self, came_from):
        """Reconstruct path from A* search"""
        current = self.goal
        path = []
        while current:
            path.append(current)
            current = came_from[current]
        return path[::-1]

# Define grid and obstacles
grid_size = 5
start = (0, 0)
goal = (4, 4)
obstacles = [(2, 2), (3, 3)]  # Obstacles at (2,2) and (3,3)

# Run A* search
planner = AStarPlanner(grid_size, start, goal, obstacles)
path = planner.find_path()

# Convert to PDDL move actions
if path:
    print("A* Path:", path)
    pddl_moves = []
    for i in range(len(path) - 1):
        x1, y1 = path[i]
        x2, y2 = path[i + 1]
        pddl_moves.append(f"(move {x1} {y1} {x2} {y2})")

    print("\nPDDL Plan:")
    print("\n".join(pddl_moves))
else:
    print("No path found")
