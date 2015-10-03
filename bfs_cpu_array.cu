/**
 File name: bfs_cpu_stl.cu
 Author: Yuede Ji
 Last update: 18:25 10-02-2015
 Description: Using array to implent CPU version of bfs.
    Calculate the shortest distance from 0 to others
**/

#include <stdio.h>
#include <queue>
#include <stdlib.h>
#include <string.h>

using namespace std;
#define N 1025 // vertex number
//Using arrays to implement queue


char filein[] = "/home/yuede/dataset/kron_10_4.dat";
char fileout[] = "/home/yuede/dataset/kron_10_4.result";
//Using arrays to implement queue
int q[N];

int edge[N][N];
int visit[N];
int dist[N];

int bfs(int root)
{
    memset(dist, 0, sizeof(int) * N);
    q[0] = root;
    int l = 1; // record the size of the queue
    int front = 0; // identify the front element
    int end = 0; // identify the end element
    while(l>0)
    {
        int cur = q[front];
        ++front;
        --l;
        if(front >= N)
            front %= N;
        
        for(int i=0; edge[cur][i]!=0; ++i)
        {
            int v = edge[cur][i];
            if(visit[v])
                continue;
            dist[v] = dist[cur] + 1;
            ++end;
            if(end >= N)
                end %= N;
            q[end] = v;
            visit[v] = 1;
            ++l;
        }
    }
    return 0;
}
int main()
{
    FILE *fp_in = fopen(filein, "r");
    int v, e;
    int num_v=0;
    memset(edge, 0, N*N*sizeof(int));
    memset(visit, 0, N*sizeof(int));
    while(fscanf(fp_in, "%d %d", &v, &e)!=EOF)
    {
        ++num_v;
        for(int i=0; i<e; ++i)
        {
            int v1;
            fscanf(fp_in, "%d", &v1);
            edge[v][i] = v1;//v->v1
        }
    }
    fclose(fp_in);

    bfs(0);
    FILE *fp_out = fopen(fileout, "w");
    //fprintf("num_v = %d\n", num_v);
    for(int i=0; i<num_v; ++i)
        fprintf(fp_out, "distance[0][%d] = %d\n", i, dist[i]);
    fclose(fp_out);
    printf("Finished!\n");
    return 0;
}
