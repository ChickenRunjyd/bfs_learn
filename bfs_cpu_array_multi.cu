/**
 File name: bfs_cpu_array_multi.cu
 Author: Yuede Ji
 Last update: 21:54 10-02-2015
 Description: Using array to implent CPU version of bfs.
    Calculate the shortest distance between each other 
**/

#include <stdio.h>
#include <queue>
#include <stdlib.h>
#include <string.h>

using namespace std;
#define N 1024 // vertex number
//Using arrays to implement queue
#define imax(a, b) (a>b?a:b)

char filein[] = "/home/yuede/dataset/edge.dat";
char fileout[] = "/home/yuede/dataset/edge.cpu_multi";
//Using arrays to implement queue
int q[N];

int edge[N][N];
int visit[N];
int dist[N][N];

int bfs(int root)
{
    //memset(dist, 0, sizeof(int) * N * N);
    memset(visit, 0, sizeof(int) * N);
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
            dist[root][v] = dist[root][cur] + 1;
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
    memset(dist, 0, N*N*sizeof(int));
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

    for(int i=0; i<num_v; ++i)
        bfs(i);
    FILE *fp_out = fopen(fileout, "w");
    //fprintf("num_v = %d\n", num_v);
    for(int i=0; i<num_v; ++i)
    {
        fprintf(fp_out, "%d", i);
        for(int j=0; j<num_v; ++j)
            fprintf(fp_out, " %d", imax(dist[i][j], dist[j][i]));
        fprintf(fp_out, "\n");
    }
    fclose(fp_out);
    printf("Finished!\n");
    return 0;
}
