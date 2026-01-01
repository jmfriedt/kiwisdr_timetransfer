#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "fec.h"

#include "char.h"
#include "rs-common.h"

// see https://github.com/quiet/libfec/blob/main/rs.c: if MM==7 /* 1 + x^3 + x^7 */
/*
0015 flip  03 3B 19 35 5C 1C 6D 1A 5F 16 RS 3D 77 1E 46 37 7E 75 4E 35 5E 1B 00 5C 36 04 0B 1E 12 2A 3D
CASE 1     79 08 01 58 00 1C 73 2F 44 26    3D 77 1E 46 37 7E 75 4E 35 5E 1B 00 5C 36 04 0B 1E 12 2A 3D 
0225 flip  79 08 01 58 00 1C 73 2F 44 26 RS 27 6F 7E 72 65 3E 4C 2B 3A 56 74 28 4F 4F 0F 39 59 00 4B 0C
CASE 2     79 14 19 35 5C 1C 79 44 29 16    27 6F 7E 72 65 3E 4C 2B 3A 56 74 28 4F 4F 0F 39 59 00 4B 0C 
0435 flip  79 14 19 35 5C 1C 79 44 29 16 RS 29 35 43 34 07 67 69 15 54 12 6B 7A 27 4E 1E 2D 37 3E 01 01
CASE 3     24 06 01 58 00 1C 7F 59 0E 26    29 35 43 34 07 67 69 15 54 12 6B 7A 27 4E 1E 2D 37 3E 01 01 
0645 flip  24 06 01 58 00 1C 7F 59 0E 26 RS 1F 79 5B 49 70 42 6A 4C 5E 4E 0C 3F 57 2E 7F 25 55 0E 5B 04
*/

#define K 10  // input symbols
#define N 30  // code correction + symbols
#define S 7   // GF(2^S)

int main(){
#if CASE==1
  unsigned char data[K]={0x79,0x08,0x01,0x58,0x00,0x1c,0x73,0x2f,0x44,0x26}; 
#endif
#if CASE==2
  unsigned char data[K]={0x79,0x14,0x19,0x35,0x5C,0x1C,0x79,0x44,0x29,0x16};
#endif
#if CASE==3
  unsigned char data[K]={0x24,0x06,0x01,0x58,0x00,0x1c,0x7f,0x59,0x0E,0x26};
#endif
  int i;
  void* rs;
  const int codeword_size=(1<<S)-1;         // 2^7-1 for 7-bit
  unsigned char codeword[codeword_size];    // 127 symbols input
  bzero(codeword,codeword_size);
  // printf("codeword_size=%d\n",codeword_size); codeword_size=127
  const int nroots = N - K;
  rs=init_rs_char(7, 0x89, 1, 1, nroots, 0);  // symsize,genpoly,fcs,prim,nroots,padding
  struct rs *r;
  if (rs==NULL) {printf("init_rs_char failed!\n");return -1;}
  r=(struct rs*)rs;
  //printf("index_of: 0->%x\n",r->index_of[0]);//          0->127
  for (i=0;i<sizeof(data);i++) codeword[codeword_size-N+i]=r->alpha_to[data[i]]; // 0->127
  encode_rs_char(rs,codeword,&codeword[codeword_size-nroots]);

i=5;
printf("data[%d] was %02hhx\n",i,data[5]);
data[i]=0x42;
codeword[codeword_size-N+i]=r->alpha_to[data[i]];
int erasures=0,derrors;
int derrlocs[codeword_size];
derrors = decode_rs_char(rs,codeword,derrlocs,erasures);
printf("%d errors @ %d: %02hhx\n",derrors,derrlocs[0],r->index_of[codeword[derrlocs[0]]]);

  for (i=codeword_size-N;i<sizeof(codeword);i++) codeword[i]=r->index_of[codeword[i]];
  for (i=codeword_size-N;i<sizeof(codeword);i++) printf("%02hhX ",codeword[i]);
  printf("\n");
  free_rs_char(rs);
  return 0;
}



