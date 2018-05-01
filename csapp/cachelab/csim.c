/* 
 * csim.c - A cache simulator that can replay traces from Valgrind
 *     and output statistics such as number of hits, misses, and
 *     evictions.  The replacement policy is LRU.
 *
 * Implementation and assumptions:
 *  1. Each load/store can cause at most one cache miss. (I examined the trace,
 *  the largest request I saw was for 8 bytes).
 *  2. Instruction loads (I) are ignored, since we are interested in evaluating
 *  trans.c in terms of its data cache performance.
 *  3. data modify (M) is treated as a load followed by a store to the same
 *  address. Hence, an M operation can result in two cache hits, or a miss and a
 *  hit plus an possible eviction.
 *
 * The function printSummary() is given to print output.
 * Please use this function to print the number of hits, misses and evictions.
 * This is crucial for the driver to evaluate your work. 
 */
#include <getopt.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <assert.h>
#include <math.h>
#include <limits.h>
#include <string.h>
#include <errno.h>
#include "cachelab.h"
#include <stdbool.h>

// #define DEBUG_ON 
#define ADDRESS_LENGTH 64

/* Type: Memory address */
typedef unsigned long long int mem_addr_t;

/* Type: Cache line
   LRU is a counter used to implement LRU replacement policy  */
typedef struct cache_line {
    char valid;
    mem_addr_t tag;
    unsigned long long int lru; //4 bytes
} cache_line_t;

typedef cache_line_t* cache_set_t;
typedef cache_set_t* cache_t;

/* Globals set by command line args */
int verbosity = 0; /* print trace if set */
int s = 0; /* set index bits */
int b = 0; /* block offset bits */
int E = 0; /* associativity */
char* trace_file = NULL;

/* Derived from command line args */
int S; /* number of sets */
int B; /* block size (bytes) */

/* Counters used to record cache statistics */
int miss_count = 0;
int hit_count = 0;
int eviction_count = 0;
unsigned long long int lru_counter = 1;

/* The cache we are simulating */
cache_t cache;  
mem_addr_t set_index_mask;

/* 
 * initCache - Allocate memory, write 0's for valid and tag and LRU
 * also computes the set_index_mask
 * s组E行
 */
void initCache()
{
    int i,j;
    cache = (cache_set_t*) malloc(sizeof(cache_set_t) * S);
    // printf("mallocing %lx\n",(unsigned long)cache);
    for (i=0; i<S; i++){
        cache[i]=(cache_line_t*) malloc(sizeof(cache_line_t) * E);
        // printf("mallocing %lx\n",(unsigned long)(cache[i]));
        for (j=0; j<E; j++){
            cache[i][j].valid = 0;
            cache[i][j].tag = 0;
            cache[i][j].lru = 0;
        }
    }

    /* Computes set index mask */
    set_index_mask = (mem_addr_t) (pow(2, s) - 1);
}


/* TODO
 * freeCache - free allocated memory
 */
void freeCache()
{
    for (int i=0; i<S; i++){
        free(cache[i]);
    }
    free(cache);
}


void inc()
{
    int i,j;
    for (i=0; i<S; i++){
        for (j=0; j<E; j++){
            if (cache[i][j].valid)
                cache[i][j].lru++;
        }
    }
}

/*
    return 1 for a evition
*/
bool lru_insert( mem_addr_t tag, cache_set_t cache_set) {
    bool has_empty = false;
    mem_addr_t insert_index = -1;
    for (int i = 0; i < E; i++) {
        if (cache_set[i].valid == 0){
            has_empty = true;
            insert_index = i;
            break;
        }
    }
    if (has_empty) {
        cache_set[insert_index].tag = tag;
        cache_set[insert_index].lru = 0;
        cache_set[insert_index].valid = 1;
        return false;
    }
    else {
        unsigned long long max_lru = 0;
        mem_addr_t max_lru_index = 0;
        for (int i = 0; i < E; i++) {
            if (cache_set[i].lru >= max_lru){
                max_lru_index = i;
                max_lru = cache_set[i].lru;
            }
        }
        #ifdef DEBUG_ON
            printf("replace %llx, with tag %llx, lru value %llu:\n",\
                max_lru_index, cache_set[max_lru_index].tag, cache_set[max_lru_index].lru);
        #endif
        cache_set[max_lru_index].tag = tag;
        cache_set[max_lru_index].lru = 0;
        cache_set[max_lru_index].valid = 1;
        return true;
    }
}

/* TODO:
 * accessData - Access data at memory address addr.
 *   If it is already in cache, increast hit_count
 *   If it is not in cache, bring it in cache, increase miss count.
 *   Also increase eviction_count if a line is evicted.
 *   mode 0:r/s 1:m
 */
void accessData(mem_addr_t addr, int mode, bool *has_evition, bool *hit)
{
    // int i;
    // unsigned long long int eviction_lru = ULONG_MAX;
    // unsigned int eviction_line = 0;
    mem_addr_t set_index = (addr >> b) & set_index_mask;
    mem_addr_t tag = addr >> (s+b);
    cache_set_t cache_set = cache[set_index];

#ifdef DEBUG_ON
    printf("set_index: %llu  tag: %llu\n",set_index ,tag);
#endif

    *hit = false;
    *has_evition = false;
    for (int i=0; i<E; i++) {
        if (cache_set[i].valid && cache_set[i].tag == tag){
            *hit = true;
            cache_set[i].lru = 0;
            break;
        }
    }
    if ((*hit) == true)
        return;
    else {
        *has_evition = lru_insert(tag, cache_set);
        return;
    }

}


/* TODO:
 * replayTrace - replays the given trace file against the cache 
 */
void replayTrace(char* trace_fn)
{
    char op[10];
    mem_addr_t addr=0;
    unsigned int len=0;
    FILE* trace_fp = fopen(trace_fn, "r");
    while ( fscanf(trace_fp, "%s", op) != EOF ) {
        fscanf(trace_fp, "%llx,%u", &addr, &len );

        printf("%s %llx,%u ", op, addr, len);

        bool eviction, hit;
        switch( op[0] ) {
            case 'M':
                accessData(addr, 1, &eviction, &hit);
                break;
            case 'L':
                accessData(addr, 0, &eviction, &hit);
                break;
            case 'S':
                accessData(addr, 0, &eviction, &hit);
                break;
            case 'I':
                continue;
            default:
                printf("Trace file format error\n");
                exit(0);
        }
        if (hit) {
            hit_count++;
            printf("hit ");
        }
        else {
            miss_count++;
            printf("miss ");
        }
        if (eviction) {
            eviction_count++;
            printf("eviction ");
        }
        if (op[0]== 'M') {
            hit_count++;
            printf("hit");
        }
        printf("\n");
        inc();
    }

    fclose(trace_fp);
}

/*
 * printUsage - Print usage info
 */
void printUsage(char* argv[])
{
    printf("Usage: %s [-hv] -s <num> -E <num> -b <num> -t <file>\n", argv[0]);
    printf("Options:\n");
    printf("  -h         Print this help message.\n");
    printf("  -v         Optional verbose flag.\n");
    printf("  -s <num>   Number of set index bits.\n");
    printf("  -E <num>   Number of lines per set.\n");
    printf("  -b <num>   Number of block offset bits.\n");
    printf("  -t <file>  Trace file.\n");
    printf("\nExamples:\n");
    printf("  linux>  %s -s 4 -E 1 -b 4 -t traces/yi.trace\n", argv[0]);
    printf("  linux>  %s -v -s 8 -E 2 -b 4 -t traces/yi.trace\n", argv[0]);
    exit(0);
}

/*
 * main - Main routine 
 */
int main(int argc, char* argv[])
{
    char c;

    while( (c=getopt(argc,argv,"s:E:b:t:vh")) != -1){
        switch(c){
        case 's':
            s = atoi(optarg);
            break;
        case 'E':
            E = atoi(optarg);
            break;
        case 'b':
            b = atoi(optarg);
            break;
        case 't':
            trace_file = optarg;
            break;
        case 'v':
            verbosity = 1;
            break;
        case 'h':
            printUsage(argv);
            exit(0);
        default:
            printUsage(argv);
            exit(1);
        }
    }

    /* Make sure that all required command line args were specified */
    if (s == 0 || E == 0 || b == 0 || trace_file == NULL) {
        printf("%s: Missing required command line argument\n", argv[0]);
        printUsage(argv);
        exit(1);
    }

    /* Compute S, E and B from command line args */
    S = (unsigned int) pow(2, s);
    B = (unsigned int) pow(2, b);
 
    /* Initialize cache */
    initCache();

#ifdef DEBUG_ON
    printf("DEBUG: S:%u E:%u B:%u trace:%s\n", S, E, B, trace_file);
    printf("DEBUG: set_index_mask: %llu\n", set_index_mask);
#endif
 
    replayTrace(trace_file);

    /* Free allocated memory */
    freeCache();

    /* Output the hit and miss statistics for the autograder */
    printSummary(hit_count, miss_count, eviction_count);
    return 0;
}
