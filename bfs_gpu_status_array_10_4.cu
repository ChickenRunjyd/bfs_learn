/**
 File name: bfs_gpu_status_array_10_4.cu
 Author: Yuede Ji
 Last update: 21:22 10-11-2015
 Description: Using status array to implent GPU version of bfs.
    Calculate the shortest distance from 0 to others
**/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

//Using arrays to implement queue
/**char filein[] = "/home/yuede/dataset/kron_16_16.dat";// no need
char fileout[] = "/home/yuede/dataset/kron_16_16.gpu.as.result";
char file_v_e[] = "/home/yuede/dataset/kron_16_16.v_e";
char file_beg_pos[] = "/home/yuede/dataset/kron_16_16.beg.pos";
char file_csr[] = "/home/yuede/dataset/kron_16_16.csr";
**/
char filein[] = "/home/yuede/dataset/kron_10_4.dat";// no need
char fileout[] = "/home/yuede/dataset/kron_10_4.gpu.as.result";
char file_v_e[] = "/home/yuede/dataset/kron_10_4.v_e";
char file_beg_pos[] = "/home/yuede/dataset/kron_10_4.beg.pos";
char file_csr[] = "/home/yuede/dataset/kron_10_4.csr";


const int v_num = 1024;
const int e_num = 8193;
const int INF = 0x7FFFFFFF;
const int threads_num = 32;

int beg_pos[v_num+1];
int csr[e_num];
int sa[v_num];
//load from .dat files, and store in array csr[N*N], beg_pos[N]

int csr_begin(int v, int e);
void bfs_sa(int root, int v, int e);
__global__ void traverse_one(int level, int * dev_sa, int * dev_beg_pos, int * dev_csr, int dev_flag)
{
    int id = threadIdx.x + blockIdx.x * blockDim.x;
    if(dev_sa[id] == level)///node i belongs to current level
    {
        //int j = dev_beg_pos[id];
        for(int j=dev_beg_pos[id]; j<dev_beg_pos[id+1]; ++j)
        {
            if(dev_sa[dev_csr[j]] > level + 1)
            {  
                printf("dev_csr[%d] = %d\n", j, dev_csr[j]);
                dev_sa[dev_csr[j]] = level + 1;
                if(!dev_flag)
                    dev_flag = true;
            }
        }                    
    }
}

int main()
{
    csr_begin(v_num, e_num);

    bfs_sa(0, v_num, e_num);

    FILE * fp_out = fopen(fileout, "w");

    for(int i=0; i<v_num; ++i)
        fprintf(fp_out, "%d\n", sa[i]);
    fclose(fp_out);
    
    return 0;
}
void bfs_sa(int root, int v, int e)
{
    for(int i=0; i<v; ++i)
        sa[i] = INF;
    int level = 0;
    sa[0] = 0;
    bool flag = true; //flag whether current level has nodes
    
    int *dev_sa;
    int *dev_beg_pos;
    int *dev_csr;

    for(int i=0; i<10; ++i)
        printf("csr[%d] = %d\n", i, csr[i]);

    cudaMalloc( (void **) &dev_sa, v*sizeof(int));
    cudaMalloc( (void **) &dev_beg_pos, (v+1)*sizeof(int));
    cudaMalloc( (void **) &dev_csr, e*sizeof(int));

    cudaMemcpy(dev_sa, sa, v*sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(dev_beg_pos, beg_pos, (v+1)*sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(dev_csr, csr, e*sizeof(int), cudaMemcpyHostToDevice);
    
    bool dev_flag;
    cudaMalloc( (void **) &dev_flag, sizeof(bool));

    while(flag)
    {
        flag = false;
        cudaMemcpy(&dev_flag, &flag, sizeof(bool), cudaMemcpyHostToDevice);
        traverse_one<<<threads_num, threads_num>>>(level, dev_sa, dev_beg_pos, dev_csr, dev_flag);
        cudaMemcpy(&flag, &dev_flag, sizeof(bool), cudaMemcpyDeviceToHost);
        ++level;
    }
    cudaMemcpy(sa, dev_sa, v*sizeof(int), cudaMemcpyDeviceToHost);

    cudaFree(dev_sa);
    cudaFree(dev_beg_pos);
    cudaFree(dev_csr);

}

int csr_begin(int v, int e)
{
    FILE * fp_beg = fopen(file_beg_pos, "r");
    int i = 0;
    int p;
    while(fscanf(fp_beg, "%d", &p) != EOF)
    {
        beg_pos[i] = p;
        ++i;
    }
    fclose(fp_beg);

    i = 0;
    FILE * fp_csr = fopen(file_csr, "r");
    while(fscanf(fp_csr, "%d", &p) != EOF)
    {
        csr[i] = p;
        ++i;
    }
    fclose(fp_csr);
    return v;
}
