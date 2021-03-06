#include <stdio.h>
#include <stdlib.h>
#include "/home/pub/include/alloc.c"
#ifndef max
#define max(a,b) (((a)>(b))?(a):(b))
#endif
#ifndef min
#define min(a,b) (((a)<(b))?(a):(b))
#endif
#define X 100000
#define Y 10000
#define SUM 1000

void f_read_from_stdin(float **mat, int *dimensions){
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
			sscanf(num_str,"%f",&mat[i][j]);
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
			sscanf(num_str,"%f",&mat[i][j]);
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

void f_read_from_file(FILE *fp, float **mat, int *dimensions){
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
			sscanf(num_str,"%f",&mat[i][j]);
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
			sscanf(num_str,"%f",&mat[i][j]);
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



float add_list(int len, float *list){
	int i;
	float sigma=0;
	for(i=0;i<len;i++){
		sigma = sigma + list[i];
	}
	return(sigma);
}

int main(int argc, char **argv){
	FILE *in;
	int i;
	int j;
	int dims[2];
	float **imat;
	float *sig;
	if(argc == 1){
		imat = f_calloc_mat(X,Y);
		f_read_from_stdin(imat,dims);
	}else if(argc == 2){
		imat = f_calloc_mat(X,Y);
		if((in = fopen(argv[1],"r")) == NULL){
			perror(argv[1]);
			exit(1);
		}
		f_read_from_file(in,imat,dims);
		fclose(in);
	}
	sig = f_alloc_vec(dims[0]);
	for(i=0;i<dims[0];i++){
		sig[i] = add_list(dims[1],imat[i]);
	}
	for(i=0;i<dims[0];i++){
		printf("%f",((float)imat[i][0]*dims[1])/(float)sig[i]);
		//printf("%f",((float)imat[i][0]*SUM)/(float)sig[i]);
		for(j=1;j<dims[1];j++){
			printf(" %f",((float)imat[i][j]*dims[1])/(float)sig[i]);
			//printf(" %f",((float)imat[i][j]*SUM)/(float)sig[i]);
		}
		printf("\n");
	}
	return(0);
}
