/* 
 * trans.c - Matrix transpose B = A^T
 *
 * Each transpose function must have a prototype of the form:
 * void trans(int M, int N, int A[N][M], int B[M][N]);
 *
 * A transpose function is evaluated by counting the number of misses
 * on a 1KB direct mapped cache with a block size of 32 bytes.
 */ 
#include <stdio.h>
#include "cachelab.h"
// #define DEBUG_ON
#define min(x,y) ((x)>(y)?(y):(x))

int is_transpose(int M, int N, int A[N][M], int B[M][N]);
void transpose_submit1(int M, int N, int A[N][M], int B[M][N]);

/* 
 * transpose_submit - This is the solution transpose function that you
 *     will be graded on for Part B of the assignment. Do not change
 *     the description string "Transpose submission", as the driver
 *     searches for that string to identify the transpose function to
 *     be graded. 
 */
char transpose_submit_desc[] = "Transpose submission";
void transpose_submit(int M, int N, int A[N][M], int B[M][N])
{
    int BLK = (M==64)?4:(M==61)? 16 : 8;
    int tmp, index;

    for (int xs=0; xs < N; xs+=BLK) {
        for (int ys=0; ys<M; ys+=BLK) {
            int xu = min(xs+BLK,N);
            int yu = min(ys+BLK,M);
            for (int i=xs; i<xu; i++) {
                for (int j=ys; j<yu; j++){
                    if (i!=j)
                        B[j][i] = A[i][j];
                    else
                        tmp = A[i][j], index = i;
                }
                if (xs == ys) {
                    B[index][index] = tmp;
                }
            }
        }
    }
#ifdef DEBUG_ON
    if (is_transpose(M,N,A,B))
        printf("ok\n");
    else
        printf("Wrong transport!\n");
#endif
}

/* 
 * You can define additional transpose functions below. We've defined
 * a simple one below to help you get started. 
 */ 
char transpose_submit1_desc[] = "Transpose submission1";
void transpose_submit1(int M, int N, int A[N][M], int B[M][N])
{
    int BLK = 4;
    int r1, r2, r3, r4;
    for (int xs=0; xs < N; xs+=BLK) {
        for (int ys=0; ys<M; ys+=BLK) {
            int xu = min(xs+BLK,N);
            int yu = min(ys+BLK,M);
            for (int i=xs; i<xu; i+=2) {
                if ( i+1 < xu) {
                    r1 = A[i+1][ys];
                    r2 = A[i+1][ys+1];
                    r3 = A[i+1][ys+2];
                    r4 = A[i+1][ys+3];
                }
                for (int j=ys; j<yu; j++){
                    B[j][i] = A[i][j];
                }
                if ( i+1 < xu) {
                    B[ys][i+1] = r1;
                    B[ys+1][i+1] = r2;
                    B[ys+2][i+1] = r3;
                    B[ys+3][i+1] = r4;
                }
            }
        }
    }
}
/* 
 * trans - A simple baseline transpose function, not optimized for the cache.
 */
char trans_desc[] = "Simple row-wise scan transpose";
void trans(int M, int N, int A[N][M], int B[M][N])
{
    int i, j, tmp;

    for (i = 0; i < N; i++) {
        for (j = 0; j < M; j++) {
            tmp = A[i][j];
            B[j][i] = tmp;
        }
    }    

}

/*
 * registerFunctions - This function registers your transpose
 *     functions with the driver.  At runtime, the driver will
 *     evaluate each of the registered functions and summarize their
 *     performance. This is a handy way to experiment with different
 *     transpose strategies.
 */
void registerFunctions()
{
    /* Register your solution function */
    registerTransFunction(transpose_submit, transpose_submit_desc); 
    registerTransFunction(transpose_submit1, transpose_submit1_desc);
    /* Register any additional transpose functions */
    registerTransFunction(trans, trans_desc); 

}

/* 
 * is_transpose - This helper function checks if B is the transpose of
 *     A. You can check the correctness of your transpose by calling
 *     it before returning from the transpose function.
 */
int is_transpose(int M, int N, int A[N][M], int B[M][N])
{
    int i, j;

    for (i = 0; i < N; i++) {
        for (j = 0; j < M; ++j) {
            if (A[i][j] != B[j][i]) {
                return 0;
            }
        }
    }
    return 1;
}

