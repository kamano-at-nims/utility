#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define SIZE_MRNA 6
#define SIZE_JOIN 5
#define SIZE_COMPLEMENT 11
#define MRNA " mRNA "
#define JOIN "join("
#define COMPLEMENT "complement("

static int in_cds = 0;
static char *bf_mRNA = NULL;
static char *bf_join = NULL;
static char *bf_complement = NULL;

int main(int argc, char **argv){
	int i = 0;
	signed char c;
	FILE *IN = NULL;
	bf_mRNA = calloc(SIZE_MRNA+1,sizeof(char));
	bf_join = calloc(SIZE_JOIN+1,sizeof(char));
	bf_complement = calloc(SIZE_COMPLEMENT+1,sizeof(char));
	if(argc == 1){
		while((c = fgetc(stdin)) != EOF){
			for(i=0;i<SIZE_JOIN-1;i++){
				*(bf_join+i) = *(bf_join+i+1);
			}
			*(bf_join+SIZE_JOIN-1) = c;
			*(bf_join+SIZE_JOIN) = 0;
			for(i=0;i<SIZE_COMPLEMENT-1;i++){
				*(bf_complement+i) = *(bf_complement+i+1);
			}
			*(bf_complement+SIZE_COMPLEMENT-1) = c;
			*(bf_complement+SIZE_COMPLEMENT) = 0;
			for(i=0;i<SIZE_MRNA-1;i++){
				*(bf_mRNA+i) = *(bf_mRNA+i+1);
			}
			*(bf_mRNA+SIZE_MRNA-1) = c;
			*(bf_mRNA+SIZE_MRNA) = 0;
			if(strcmp(bf_mRNA,MRNA) == 0){
				//printf("\n");
			}
			if(strncmp(bf_join,JOIN,SIZE_JOIN) == 0){
				printf("\n");
				in_cds++;
			}
			if(strncmp(bf_complement,COMPLEMENT,SIZE_COMPLEMENT) == 0){
				printf("\n");
				in_cds++;
			}
			if((c == ')')&&(in_cds > 0)){
				in_cds--;
			}
			if(in_cds > 0){
				if(((48<=c)&&(c<=57))||c=='.'||c==','){
					printf("%c",c);
				}
			}
		}
	}else if(argc == 2){
		if((IN = fopen(argv[1],"r")) == NULL){
			perror(argv[1]);
			exit(1);
		}
		while((c = fgetc(IN)) != EOF){
			for(i=0;i<SIZE_JOIN-1;i++){
				*(bf_join+i) = *(bf_join+i+1);
			}
			*(bf_join+SIZE_JOIN-1) = c;
			*(bf_join+SIZE_JOIN) = 0;
			for(i=0;i<SIZE_COMPLEMENT-1;i++){
				*(bf_complement+i) = *(bf_complement+i+1);
			}
			*(bf_complement+SIZE_COMPLEMENT-1) = c;
			*(bf_complement+SIZE_COMPLEMENT) = 0;
			for(i=0;i<SIZE_MRNA-1;i++){
				*(bf_mRNA+i) = *(bf_mRNA+i+1);
			}
			*(bf_mRNA+SIZE_MRNA-1) = c;
			*(bf_mRNA+SIZE_MRNA) = 0;
			if(strcmp(bf_mRNA,MRNA) == 0){
				//printf("\n");
			}
			if(strncmp(bf_join,JOIN,SIZE_JOIN) == 0){
				printf("\n");
				in_cds++;
			}
			if(strncmp(bf_complement,COMPLEMENT,SIZE_COMPLEMENT) == 0){
				printf("\n");
				in_cds++;
			}
			if((c == ')')&&(in_cds > 0)){
				in_cds--;
			}
			if(in_cds > 0){
				if(((48<=c)&&(c<=57))||c=='.'||c==','){
					printf("%c",c);
				}
			}
		}

		fclose(IN);
	}
	return(0);
}
