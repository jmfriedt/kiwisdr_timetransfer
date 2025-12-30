// https://docs.octave.org/interpreter/Getting-Started-with-Oct_002dFiles.html
#include <octave/oct.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

uint16_t Compute_CRC14_Simple(char *,int );

DEFUN_DLD(crc14_cc, args, nargout, "res=crc14_cc(bytes)")
{int nargin=args.length();
 nargout=1;
 octave_value_list retval(nargout);
 if (nargin != 1) {print_usage();nargout=0;}
 else {NDArray a=args(0).array_value();
       const double *av=a.data();
       int len=(int)a.numel();
       char *d;
       d=(char*)malloc(len);
       for (int k=0;k<a.numel();k++) d[k]=(int)av[k];
    retval(0)=Compute_CRC14_Simple(d, len);
    free(d);
 }
 return retval; 
}

uint16_t Compute_CRC14_Simple(char *bytes,int len)
{const uint16_t poly=0x20B1; // 14 bit divisor, implicit leading 1
 uint16_t crc=0;             // CRC value is 16bit
 int i,k;
 for (k=0;k<len;k++)    // move byte into MSB of 16bit CRC
   {crc^=(uint16_t)(bytes[k]<<6); 
    for (i=0;i<8;i++)   // vv test for MSB = bit 31
      {if ((crc&0x2000)!=0) crc=(uint16_t)((crc<<1)^poly);
       else crc<<=1;
       crc&=0x3fff; // 14 bits
      }
    }
    return (crc);
} 

//int main()
//{char in1[9]={'1','2','3','4','5','6','7','8','9'};
// uint16_t crc;
// crc=Compute_CRC14_Simple(in1,9,0x0000); printf("CKSUM: %04x\n",crc);
//}
