#include <stdio.h>
#include <string.h>

int total_lines = 0;
int total_chars = 0;

int count_chars = 0;
int count_lines = 0;
const int count =200;


void process(char* pt) {
	printf("inside process\n");
}

int charCount(char* buffer) {
	return sizeof(buffer) ;
}


int  lineCount() {
	return 1;
}

int main(int argc, char** argv){
	if(argc == 1){
		printf("Please specify count line and chars\n");
	} else if (argc ==2){
		if (!strcmp(argv[1], "-c")){
			count_chars = 1;
			//printf("word count is enabled\n");
		}else if (!strcmp(argv[1], "-l")){
			count_lines = 1;
			//printf("line count is enabled\n");
		}
	}
	//printf("Integer Constant: %d\n", count); 

	
	while (1) {
	  char buffer[1024];
	  // FIXME: it will read only the first 1024 bytes from a line
	  char* res = fgets(buffer, sizeof(buffer), stdin);

	  if (!res && feof(stdin)) {
	    break;
	  }
	  
	  if (count_chars) {
	    printf("You should see this message \n");
	    char *c = &buffer[0];
	    while (*c != '\n') {
	      total_chars++;
	      c++;
	    }
	  }
	  
	  if (count_lines) {
	    printf("You should NOT see this message \n");	    
	    total_lines += lineCount();
	  }
	  
	  if (feof(stdin)) {
	    // end of file
	    break;
	  }
	}
	if (count_chars)
		printf("Count chars is:: %d\n", total_chars);
	if (count_lines)
		printf("Count Lines is:: %d\n", total_lines);
	return 0;
}
