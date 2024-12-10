#include <stdio.h>
#include <stdlib.h>

int main(int argc, char* argv[]) {

  unsigned long int i, bufsize;
  unsigned char *buf;

  FILE *fin, *fout1, *fout2;

    if (argc != 4) {
	  printf("syntax: split-roms [input] [output1] [output2]\n");
	  return(1);
	}

	fin = fopen(argv[1], "rb");
	if (!fin) {
  	  printf("[input] missing!\n");
	  return(1);
	} else {
      // ok
	}

	fout1 = fopen(argv[2], "wb");
	fout2 = fopen(argv[3], "wb");
	if (!fout1||!fout2) {
	  printf("[output] error.\n");
	  return(1);
	} else {
	  printf("creating [output] files.\n");
	}
	
  fseek(fin, 0, SEEK_END);
  bufsize = ftell(fin);
  fseek(fin, 0, SEEK_SET);

  printf("splitting %u bytes.\n", bufsize);
  buf = (unsigned char *)malloc(bufsize);

  fread(&buf[0], bufsize, 1, fin);
  
  for(i=0; i < (bufsize >> 1); i++) {
    fwrite(&buf[(i*2) + 0], 1, 1, fout1);
	fwrite(&buf[(i*2) + 1], 1, 1, fout2);
  }

  free(buf);
 
  fclose(fin);
  fclose(fout1);
  fclose(fout2);
  
}
