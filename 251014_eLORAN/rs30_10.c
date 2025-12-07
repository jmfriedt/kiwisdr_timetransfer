// https://github.com/quiet/libfec -> rstest.c: {7, 0x89, 1, 1, 10, 10 },

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <fec.h>

// see https://github.com/quiet/libfec/blob/main/rs.c: if MM==7 /* 1 + x^3 + x^7 */
/*
0015 data 00110010110101101110000111001101101001101010111110010110 CRC 11011101100000 RS 10111100101010010010001111001101000001000001101100011101000000011011000111101101011001110011010111011111111101100110001011110011101111011110
0225 data 00000011011000000000000111001110011010111110001000100110 CRC 00010001001111 RS 00110001101001000000010011011001110111100011110011111001000101000101110110101010111011010100011001011111010100110100111011111111110111110010

0015 data  19 35 5C 1C 6D 1A 5F 16 CRC  6E 60 RS  5E 2A 24 3C 68 10 36 1D 00 6C 3D 56 39 57 3F 76 31 3C 77 5E
0225 data  01 58 00 1C 73 2F 44 26 CRC  08 4F RS  18 69 00 4D 4E 78 79 79 0A 17 35 2E 6A 19 3E 53 27 3F 7B 72
*/

#define K 10
#define N 30

struct etab {
  int symsize;
  int genpoly;
  int fcs;
  int prim;
  int nroots;
} Tab[] = {{7, 0x89, 1, 1, N-K},};

int exercise_char(struct etab *e){
//  unsigned char data[K] = {0x19,0x35,0x5C,0x1C,0x6D,0x1A,0x5F,0x16,0x6E,0x60};
  unsigned char data[K] = {0x03,0x3B,0x34,0x7D,0x2C,0x5B,0x1C,0x1D,0x56,0x4C};
  int nn = (1<<e->symsize) - 1;
  unsigned char codeword[N-K];
  int i;
  int kk;
  void *rs;

  /* Compute code parameters */
  kk=nn-e->nroots;
  printf("K=%d kk=%d nn=%d\n",K,kk,nn);
  rs=init_rs_char(7, 0x89, 1, 1, N-K, nn-N);
  if(rs == NULL){
    printf("init_rs_char failed!\n");
    return -1;
  }
  for(i=0;i<N-K;i++) codeword[i] = 0;
  encode_rs_char(rs,data,codeword);
  for (i=0;i<N-K;i++) printf("%02hhX ", codeword[i]);
      printf("\n\n");
  free_rs_char(rs);
  return 0;
}

int main(){
  exercise_char(&Tab[0]);
}

