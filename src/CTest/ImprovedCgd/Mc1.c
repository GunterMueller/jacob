typedef struct{
   char b;
   int  bla;
} R;

int a;
R r[10];

/*****************************************************************************/
void P(int *p){
   int b;
} /* P */    

/*****************************************************************************/
void Q(R *r){
} /* Q */

/*****************************************************************************/
void main(){
   P(&(r[a].bla)); 
   Q(&(r[a])); 
} /* main */

