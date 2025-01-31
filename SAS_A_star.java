import java.util.*;

class Node implements Comparable<Node> {
    int x, y, gCost, hCost, fCost;
    Node parent;

    Node(int x, int y, int gCost, int hCost, Node parent) {
        this.x = x;
        this.y = y;
        this.gCost = gCost;
        this.hCost = hCost;
        this.fCost = gCost + hCost;
        this.parent = parent;
    }

    @Override
    public int compareTo(Node other) {
        return Integer.compare(this.fCost, other.fCost);
    }
}

public class AStarSearch2D {
    private static final int[][] DIRECTIONS = {{0,1}, {1,0}, {0,-1}, {-1,0}};
    
    public static List<int[]> aStarSearch(int[][] grid, int[] start, int[] goal) {
        PriorityQueue<Node> openSet = new PriorityQueue<>();
        Map<String, Node> visited = new HashMap<>();

        Node startNode = new Node(start[0], start[1], 0, heuristic(start, goal), null);
        openSet.add(startNode);
        
        while (!openSet.isEmpty()) {
            Node current = openSet.poll();
            String key = current.x + "," + current.y;
            visited.put(key, current);
            
            if (current.x == goal[0] && current.y == goal[1]) {
                return reconstructPath(current);
            }
            
            for (int[] dir : DIRECTIONS) {
                int nx = current.x + dir[0];
                int ny = current.y + dir[1];
                if (isValid(grid, nx, ny, visited)) {
                    int newG = current.gCost + 1;
                    Node neighbor = new Node(nx, ny, newG, heuristic(new int[]{nx, ny}, goal), current);
                    openSet.add(neighbor);
                }
            }
        }
        return Collections.emptyList(); // No path found
    }
    
    private static int heuristic(int[] a, int[] b) {
        return Math.abs(a[0] - b[0]) + Math.abs(a[1] - b[1]); // Manhattan Distance
    }
    
    private static boolean isValid(int[][] grid, int x, int y, Map<String, Node> visited) {
        return x >= 0 && y >= 0 && x < grid.length && y < grid[0].length && grid[x][y] == 0 && !visited.containsKey(x + "," + y);
    }
    
    private static List<int[]> reconstructPath(Node node) {
        List<int[]> path = new ArrayList<>();
        while (node != null) {
            path.add(new int[]{node.x, node.y});
            node = node.parent;
        }
        Collections.reverse(path);
        return path;
    }
    
    public static void main(String[] args) {
        int[][] grid = {
            {0, 0, 0, 1, 0},
            {1, 1, 0, 1, 0},
            {0, 0, 0, 0, 0},
            {0, 1, 1, 1, 0},
            {0, 0, 0, 0, 0}
        };
        int[] start = {0, 0};
        int[] goal = {4, 4};
        
        List<int[]> path = aStarSearch(grid, start, goal);
        
        if (!path.isEmpty()) {
            System.out.println("Path found:");
            for (int[] step : path) {
                System.out.println("(" + step[0] + ", " + step[1] + ")");
            }
        } else {
            System.out.println("No path found!");
        }
    }
}
