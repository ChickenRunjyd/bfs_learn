/**
 File name: bfs_cpu_stl.cu
 Author: Yuede Ji
 Last update: 10:27 10-02-2015
 Description: Using stl queue to implement the easiest version of bfs.

**/

#include <stdio.h>
#include <queue>
#include <stdlib.h>
#include <string.h>

using namespace std;

#define N 1025

char filein[] = "/home/yuede/dataset/kron_10_4.dat";
char fileout[] = "/home/yuede/dataset/kron_10_4.stl";

queue<int> q;

int edge[N][N];
int visit[N];
int dist[N];
int bfs(int root)
{
    memset(dist, 0, sizeof(int) * N);
    q.push(root);
    while(!q.empty())
    {
        int bottom = q.front();
        q.pop();
        for(int i=0; edge[bottom][i]!=0; ++i)
        {
            int v = edge[bottom][i];
            if(visit[v])
                continue;
            dist[v] = dist[bottom] + 1;
            q.push(v);
            visit[v] = 1;
        }
    }
    return 0;
}
int main()
{
    FILE *fp_in = fopen(filein, "r");
    ///fscanf(fp, "%d", &n);
    ///printf("%d\n", n); 
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
    //printf("num_v = %d\n", num_v);
    FILE * fp_out = fopen(fileout, "w");
    for(int i=0; i<num_v; ++i)
        fprintf(fp_out, "distance[0][%d] = %d\n", i, dist[i]);
    fclose(fp_out);
    printf("Finished!\n");
    return 0;
}
