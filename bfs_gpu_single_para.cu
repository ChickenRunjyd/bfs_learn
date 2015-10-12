/**
 File name: bfs_gpu_single_para.cu
 Author: Yuede Ji
 Last update: 13:38 10-08-2015
 Description: Using single thread to implent parallel GPU version of bfs.
    Calculate the shortest distance from 0 to others
**/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

using namespace std;
#define N 1024 // vertex number
//Using arrays to implement queue


char filein[] = "/home/yuede/dataset/edge.dat";
char fileout[] = "/home/yuede/dataset/edge.s_gpu";
//Using arrays to implement queue
//int q[N];

int edge[N][N];
int visit[N];
int dist[N];

/** Deal the current node, and put his children nodes in the queue.
**/
__device__ void deal_one_node(int cur, int length, int *edg, int *q)
{
    int index = cur + threadIdx.x + blockIdx.x * blockDim.x;
    if(index >= N)
        index -= N;
    for(int i=0; edg[index*N + i]!=0; ++i)
    {
        int v = edg[cur*N + i];
        if(vis[v])
            continue;
        ++l;
        ++end;
        if(end >= N)
            end -= N;
        q[end] = v;
        vis[v] = 1;
    } 
}

__global__ void bfs(int *q, int *edg, int *vis, int *dis)
{
    q[0] = 0;
    int l = 1; // record the size of the queue
    int front = 0; // identify the front element
    int end = 0; // identify the end element
    while(l>0)
    {
        int cur = q[front];
        ++front;
        --l;
        if(front >= N)
            front -= N;

        deal_one_node<<<1, 1>>>(cur, l, edg, q);
        /**
        for(int i=0; edg[cur*N + i]!=0; ++i)
        {
            int v = edg[cur*N + i];
            if(vis[v])
                continue;
            //printf("edg[cur*N + i] = %d\n", edg[cur*N + i]);
            dis[v] = dis[cur] + 1;
            printf("dis[%d] = %d\n", v, dis[v]);
            ++end;
            if(end >= N)
                end -= N;
            q[end] = v;
            vis[v] = 1;
            ++l;
        }
        **/
    }
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

    int *dev_edge;
    int *dev_visit;
    int *dev_dist;
    int *q;
        
    //allocate memory on GPU
    cudaMalloc( (void **) &dev_edge, N*N*sizeof(int));
    cudaMalloc( (void **) &dev_visit, N*N*sizeof(int));
    cudaMalloc( (void **) &dev_dist, N*sizeof(int));
    cudaMalloc( (void **) &q, N*sizeof(int));

    //initialize GPU memory
    cudaMemset( dev_visit, 0, N*N*sizeof(int));
    cudaMemset( dev_dist, 0, N*sizeof(int));
    
    //copy edge from CPU to GPU
    cudaMemcpy(dev_edge, edge, N*N*sizeof(int), cudaMemcpyHostToDevice);
    
    bfs<<<1, 1>>>(q, dev_edge, dev_visit, dev_dist);
    cudaMemcpy(dist, dev_dist, N*sizeof(int), cudaMemcpyDeviceToHost);
    
    cudaFree(dev_edge);
    cudaFree(dev_visit);
    cudaFree(dev_dist);

    FILE *fp_out = fopen(fileout, "w");
    for(int i=0; i<num_v; ++i)
        fprintf(fp_out, "distance[0][%d] = %d\n", i, dist[i]);
    fclose(fp_out);
    printf("Finished!\n");
    return 0;
}
