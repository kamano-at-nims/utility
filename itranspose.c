#include <stdio.h>
#include <stdlib.h>
#include "/home/pub/include/dim_alloc.c"
#ifndef max
#define max(a,b) (((a)>(b))?(a):(b))
#endif
#ifndef min
#define min(a,b) (((a)<(b))?(a):(b))
#endif
#define X 4000
#define Y 4000

void i_read_from_stdin(int **mat, int *dimensions){
	int i = 0;
	int j = 0;
	int j_max = 0;
	int k = 0;
	int prev_sep_i = 0;
	int prev_sep_j = 0;
	char c;
	char num_str[128];
	num_str[0] = '\0';
	while(scanf("%c",&c) != EOF){
		if(c == '\n'){
			num_str[k] = '\0';
			sscanf(num_str,"%d",&mat[i][j]);
			if(prev_sep_j == 0){
				j++;
			}
			if(prev_sep_i == 0){
				i++;
			}
			j_max = max(j,j_max);
			j = 0;
			k = 0;
			prev_sep_i = 1;
		}else if((c == ' ')||(c == ',')){
			num_str[k] = '\0';
			sscanf(num_str,"%d",&mat[i][j]);
			if(prev_sep_j == 0){
				j++;
			}
			k = 0;
			prev_sep_j = 1;
		}else{
			num_str[k] = c;
			k++;
			prev_sep_i = 0;
			prev_sep_j = 0;
		}
	}
	dimensions[0] = i;
	dimensions[1] = j_max;
}

void i_read_from_file(FILE *fp, int **mat, int *dimensions){
	int i = 0;
	int j = 0;
	int j_max = 0;
	int k = 0;
	int prev_sep_i = 0;
	int prev_sep_j = 0;
	char c;
	char num_str[128];
	num_str[0] = '\0';
	while((c = fgetc(fp)) != EOF){
		if(c == '\n'){
			num_str[k] = '\0';
			sscanf(num_str,"%d",&mat[i][j]);
			if(prev_sep_j == 0){
				j++;
			}
			if(prev_sep_i == 0){
				i++;
			}
			j_max = max(j,j_max);
			j = 0;
			k = 0;
			prev_sep_i = 1;
		}else if((c == ' ')||(c == ',')){
			num_str[k] = '\0';
			sscanf(num_str,"%d",&mat[i][j]);
			if(prev_sep_j == 0){
				j++;
			}
			k = 0;
			prev_sep_j = 1;
		}else{
			num_str[k] = c;
			k++;
			prev_sep_i = 0;
			prev_sep_j = 0;
		}
	}
	dimensions[0] = i;
	dimensions[1] = j_max;
}

int main(int argc, char **argv){
	FILE *in;
	int i;
	int j;
	int dims[2];
	int **imat;
	//float **fmat;
	imat = i_clear_alloc_matrix(X,Y);
	if(argc == 1){
		i_read_from_stdin(imat,dims);
	}else if(argc == 2){
		if((in = fopen(argv[1],"r")) == NULL){
			perror(argv[1]);
			exit(1);
		}
		i_read_from_file(in,imat,dims);
		fclose(in);
	}
	//printf("%d %d\n",dims[0],dims[1]);
	/*
	for(i=0;i<dims[0];i++){
		for(j=0;j<dims[1];j++){
			printf("%d ",imat[i][j]);
		}
		printf("\n");
	}
	*/
	for(j=0;j<dims[1];j++){
		printf("%d",imat[0][j]);
		for(i=1;i<dims[0];i++){
			printf(" %d",imat[i][j]);
		}
		printf("\n");
	}
	return(1);
}