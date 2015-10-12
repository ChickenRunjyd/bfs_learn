/**
 File name: bfs_cpu_status_array.cu
 Author: Yuede Ji
 Last update: 11:00 10-09-2015
 Description: Using status array to implent CPU version of bfs.
    Calculate the shortest distance from 0 to others
**/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

//Using arrays to implement queue
char filein[] = "/home/yuede/dataset/kron_16_16.dat";// no need
char fileout[] = "/home/yuede/dataset/kron_16_16.cpu.as.result";
char file_v_e[] = "/home/yuede/dataset/kron_16_16.v_e";
char file_beg_pos[] = "/home/yuede/dataset/kron_16_16.beg.pos";
char file_csr[] = "/home/yuede/dataset/kron_16_16.csr";

/**int *beg_pos;
int *csr;
int *sa;
**/
const int v_num = 65535;
const int e_num = 2097152;
const int INF = 0x7FFFFFFF; 
int beg_pos[v_num+1];
int csr[e_num];
int sa[v_num];
//load from .dat files, and store in array csr[N*N], beg_pos[N]
int csr_begin(int v, int e)
{
    /**
    int v, e;
    FILE * fp_v_e = fopen(file_v_e, "r");
    fscanf(fp_v_e, "%d%d", &v, &e);
    fclose(fp_v_e);

    beg_pos = (int *) malloc(v+1);
    csr = (int *) malloc(e);
    **/   
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
    printf("i=%d\n", i);
    return v;
}
void bfs_sa(int root, int v)
{
    for(int i=0; i<v; ++i)
        sa[i] = INF;
    int count = 1;
    int level = 0;
    sa[0] = 0;
    bool flag; //flag whether current level has nodes
    while(count < v)
    {
        flag = false;
        for(int i=0; i<v; ++i)
        {
            if(sa[i] == level)///node i belongs to current level
            {
                if(!flag)
                    flag = true;
                for(int j=beg_pos[i]; j<beg_pos[i+1]; ++j)
                {
                    if(sa[csr[j]] <= level + 1)
                        continue;
                    sa[csr[j]] = level + 1;
                    ++count;
                    //printf("count = %d\n", count);
                }                    
            }
        }
        ++level;
        //printf("level = %d\n", level);
        if(!flag)//indicates current level has no vertex
            break;
    }
}
int main()
{
    csr_begin(v_num, e_num);

    bfs_sa(0, v_num);

    FILE * fp_out = fopen(fileout, "w");

    for(int i=0; i<v_num; ++i)
        fprintf(fp_out, "%d\n", sa[i]);
    fclose(fp_out);
    
    return 0;
}

