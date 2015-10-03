/**
 File name: bfs_gpu_multi.cu
 Author: Yuede Ji
 Last update: 9:54 10-03-2015
 Description: Using multi thread to implent GPU version of bfs.
    Calculate the shortest distance between each other

**/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define N 1024 //1024 vertex number
//Using arrays to implement queue
#define N_block 32
#define imax(a, b) (a>b?a:b)
char filein[] = "/home/yuede/dataset/kron_10_4.dat";
char fileout[] = "/home/yuede/dataset/kron_10_4.m_gpu";
//Using arrays to implement queue
//int q[N];

int edge[N][N];
//int visit[N];
int dist[N][N];

__global__ void bfs(int *edg, int *dis)
{
    int q[N];
    int vis[N];
    memset(vis, 0, N*sizeof(int));
    memset(q, 0, N*sizeof(int));
    int index = threadIdx.x + blockIdx.x * blockDim.x;
    q[0] = index;
    vis[index] = 1;
    int l = 1; // record the size of the queue
    int front = 0; // identify the front element
    int end = 0; // identify the end element
    printf("index = %d\n", index);
    while(l>0)
    {
        int cur = q[front];
        ++front;
        --l;
        if(front >= N)
            front -= N;
        
        for(int i=0; edg[cur*N + i]!=0; ++i)
        {
            int v = edg[cur*N + i];
            printf("vis[%d] = %d\n", v, vis[v]);
            if(vis[v])
                continue;
            //printf("edg[cur*N + i] = %d\n", edg[cur*N + i]);
            dis[index*N + v] = dis[index*N + cur] + 1;
            //printf("dis[%d] = %d\n", v, dis[v]);
            ++end;
            if(end >= N)
                end -= N;
            q[end] = v;
            vis[v] = 1;
            ++l;
        }
    }
    printf("index = %d finished\n", index);
}
int main()
{
    FILE *fp_in = fopen(filein, "r");
    int v, e;
    int num_v=0;
    memset(edge, 0, N*N*sizeof(int));
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
    int *dev_dist;
        
    //allocate memory on GPU
    cudaMalloc( (void **) &dev_edge, N*N*sizeof(int));
    cudaMalloc( (void **) &dev_dist, N*N*sizeof(int));

    //initialize GPU memory
    cudaMemset( dev_dist, 0, N*N*sizeof(int));
    
    //copy edge from CPU to GPU
    cudaMemcpy(dev_edge, edge, N*N*sizeof(int), cudaMemcpyHostToDevice);
    
    bfs<<<N_block, (N+N_block-1)/N_block>>>(dev_edge, dev_dist);
    //bfs<<<1, 1>>>(dev_edge, dev_dist);
    cudaMemcpy(dist, dev_dist, N*N*sizeof(int), cudaMemcpyDeviceToHost);
    
    cudaFree(dev_edge);
    cudaFree(dev_dist);

    FILE *fp_out = fopen(fileout, "w");
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
