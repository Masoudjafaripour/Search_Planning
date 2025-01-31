#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <stdbool.h>

#define ROWS 5
#define COLS 5
#define INF 9999

typedef struct {
    int x, y;
    int gCost, hCost, fCost;
    struct Node* parent;
} Node;

typedef struct {
    Node* nodes[ROWS * COLS];
    int size;
} PriorityQueue;

int heuristic(int x1, int y1, int x2, int y2) {
    return abs(x1 - x2) + abs(y1 - y2); // Manhattan distance
}

void swap(Node** a, Node** b) {
    Node* temp = *a;
    *a = *b;
    *b = temp;
}

void push(PriorityQueue* pq, Node* node) {
    pq->nodes[pq->size] = node;
    int i = pq->size++;
    while (i > 0 && pq->nodes[i]->fCost < pq->nodes[(i - 1) / 2]->fCost) {
        swap(&pq->nodes[i], &pq->nodes[(i - 1) / 2]);
        i = (i - 1) / 2;
    }
}

Node* pop(PriorityQueue* pq) {
    if (pq->size == 0) return NULL;
    Node* min = pq->nodes[0];
    pq->nodes[0] = pq->nodes[--pq->size];
    int i = 0;
    while (2 * i + 1 < pq->size) {
        int smallest = 2 * i + 1;
        if (smallest + 1 < pq->size && pq->nodes[smallest + 1]->fCost < pq->nodes[smallest]->fCost)
            smallest++;
        if (pq->nodes[i]->fCost <= pq->nodes[smallest]->fCost)
            break;
        swap(&pq->nodes[i], &pq->nodes[smallest]);
        i = smallest;
    }
    return min;
}

bool isValid(int grid[ROWS][COLS], int x, int y, bool visited[ROWS][COLS]) {
    return x >= 0 && y >= 0 && x < ROWS && y < COLS && grid[x][y] == 0 && !visited[x][y];
}

void reconstructPath(Node* node) {
    if (node == NULL) return;
    reconstructPath(node->parent);
    printf("(%d, %d)\n", node->x, node->y);
}

void aStar(int grid[ROWS][COLS], int startX, int startY, int goalX, int goalY) {
    PriorityQueue openSet = { .size = 0 };
    bool visited[ROWS][COLS] = {false};
    int directions[4][2] = {{0,1}, {1,0}, {0,-1}, {-1,0}};
    
    Node* startNode = (Node*)malloc(sizeof(Node));
    *startNode = (Node){startX, startY, 0, heuristic(startX, startY, goalX, goalY), 0, NULL};
    push(&openSet, startNode);
    
    while (openSet.size > 0) {
        Node* current = pop(&openSet);
        visited[current->x][current->y] = true;
        
        if (current->x == goalX && current->y == goalY) {
            printf("Path found:\n");
            reconstructPath(current);
            return;
        }
        
        for (int i = 0; i < 4; i++) {
            int nx = current->x + directions[i][0];
            int ny = current->y + directions[i][1];
            if (isValid(grid, nx, ny, visited)) {
                Node* neighbor = (Node*)malloc(sizeof(Node));
                *neighbor = (Node){nx, ny, current->gCost + 1, heuristic(nx, ny, goalX, goalY), 0, current};
                neighbor->fCost = neighbor->gCost + neighbor->hCost;
                push(&openSet, neighbor);
            }
        }
    }
    printf("No path found!\n");
}

int main() {
    int grid[ROWS][COLS] = {
        {0, 0, 0, 1, 0},
        {1, 1, 0, 1, 0},
        {0, 0, 0, 0, 0},
        {0, 1, 1, 1, 0},
        {0, 0, 0, 0, 0}
    };
    
    aStar(grid, 0, 0, 4, 4);
    return 0;
}
