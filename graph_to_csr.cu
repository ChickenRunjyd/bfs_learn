/**
 File name: graph_to_csr.cu
 Author: Yuede Ji
 Last update: 15:52 10-09-2015
 Description: convert current normal graph file to scr and begin position stored file
**/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define N 65536 // vertex number
//Using arrays to implement queue
/**
char filein[] = "/home/yuede/dataset/kron_16_16.dat";
char fileout[] = "/home/yuede/dataset/kron_16_16.cpu.as.result";
char file_beg_pos[] = "/home/yuede/dataset/kron_16_16.beg.pos";
char file_csr[] = "/home/yuede/dataset/kron_16_16.csr";
char file_v_e[] = "/home/yuede/dataset/kron_16_16.v_e";
**/
char filein[] = "/home/yuede/dataset/kron_10_4.dat";
char fileout[] = "/home/yuede/dataset/kron_10_4.cpu.as.result";
char file_beg_pos[] = "/home/yuede/dataset/kron_10_4.beg.pos";
char file_csr[] = "/home/yuede/dataset/kron_10_4.csr";
char file_v_e[] = "/home/yuede/dataset/kron_10_4.v_e";

const int INF = 0x7FFFFFFF; 

int v_num = 0;
int e_num = 0;
void empty_file(char * filename)
{
    FILE * fp = fopen(filename, "w");
    fclose(fp);
}
//load from .dat files, and store in array csr[N*N], beg_pos[N]
void csr_begin(char *filename)
{
    empty_file(file_beg_pos);
    empty_file(file_csr);
    FILE * fp_in = fopen(filein, "r");
    FILE * fp_csr = fopen(file_csr, "a");
    FILE * fp_beg_pos = fopen(file_beg_pos, "a");
    int v, n;//v denotes current vertex, n denotes no. of adjacent node
    int j = 0;// j denotes the index in csr[N*N];
    int begin = 0;

    fprintf(fp_beg_pos, "%d\n", begin);
    while(fscanf(fp_in, "%d%d", &v, &n)!=EOF)
    {
        //printf("%d %d\n", v, n);
        begin += n;
        fprintf(fp_beg_pos, "%d\n", begin);
        for(int i=0; i<n; ++i)
        {
            fscanf(fp_in, "%d", &j);
            fprintf(fp_csr, "%d\n", j);
        }
    }
    fclose(fp_beg_pos);
    fclose(fp_csr);
    e_num = begin+1;
    v_num = v+1;
    printf("v_num = %d, e_num = %d\n", v_num, e_num);
    FILE *fp_v_e = fopen(file_v_e, "w");
    fprintf(fp_v_e, "%d %d\n", v_num, e_num);
    fclose(fp_v_e);
}
int main()
{
    csr_begin(filein);
    return 0;
}

