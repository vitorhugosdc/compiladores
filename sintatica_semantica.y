%{
    #include<stdio.h>
    #include<stdlib.h>
    #include<string.h>    
    #include<ctype.h>
    #include"lex.yy.c"
    
    void yyerror(const char *s);    
    void add(char);
    void insert_type();
    int search(const char *);
    void printInorder(struct node *tree);
    void printPreorder(struct node *tree);
    void print_tree(struct node *);
    void check_type(const char *);
    void check_declaration(const char *, int type);
    void check_return();
    struct node* mknode(struct node *left, struct node *right, char *token);
    int search_attribute(const char *name);
    int count=0;
    int q;
    int object_index = -1;
    char type[5];
    int count_line;
    struct node *head;
    int count_errors=0;
    char errors[100][100];
    int current_scope = 0;
    int class_scope_level = 0;
    char class_name[20];
    char current_file_name[20];
    char attribute_name[20];

    struct datatype {
            int line;
            char * name;
            char * data_type;
            char * type;
            int scope;
            int scope_class;
            char * name_class;   
    } symbol_table[100];
    
    struct node { 
        struct node *left; 
        struct node *right; 
        char *token; 
    };
    
%}
%union {
    struct node_type { 
        char name[50]; 
        struct node* nd;
        char type[5];
    } node_struct; 
}

%token <node_struct> TK_INT TK_FLOAT TK_NUMBER TK_FLOAT_NUMBER 
TK_CHAR TK_STRING TK_CH TK_STR 
TK_TRUE TK_FALSE 
TK_IF TK_ELSE 
TK_FOR 
TK_GREATER TK_GREATER_EQUAL TK_LESS TK_LESS_EQUAL TK_NOT_EQUAL 
TK_PLUS TK_MINUS TK_MULTIPLY TK_DIVISION 
TK_AND TK_OR 
TK_INCLUDE TK_ID 
TK_SCANF TK_PRINTF 
TK_RETURN TK_VOID 
TK_CLASS TK_CLASS_NAME 
TK_EQUAL 
TK_MAIN TK_MAIN_METHOD 
TK_VECTOR


%type <node_struct> program 
headers header_program header_class_main 
method class class_definition class_atributes class_body class_body_main class_operations 
method_params 
statement statement_atributes body body_statement declaration assignment 
expression value relational_operators logical_operation 
condition else 
return 
type 
io 
data_access 

%%

program: header_program {$$.nd = mknode($1.nd, NULL, "program"); head = $$.nd;}
| class {$$.nd = mknode($1.nd, NULL, "program"); head = $$.nd;}
| header_class_main {$$.nd = $1.nd; head = $$.nd;}
| {$$.nd = NULL;}
;

header_program: headers program {$$.nd = mknode($1.nd, $2.nd, "program");}
;

header_class_main: headers TK_MAIN {add('s');} '{' class_body_main '}' {
  $2.nd = mknode($5.nd, NULL, "program");
  $$.nd = mknode($1.nd, $2.nd, "program");
}
;

headers: TK_INCLUDE {add('h');} headers {$$.nd = mknode($3.nd, NULL, "include");}
|{$$.nd = NULL;}
;

class_body_main: TK_MAIN_METHOD {add('m');} '(' method_params ')' '{' body '}' {$$.nd = mknode($4.nd, $7.nd, "class_main");};

class: class_definition '{' class_body '}' {
    $$.nd = mknode($3.nd, NULL, "class");
}
;

class_definition: TK_CLASS TK_CLASS_NAME { add('s'); } { 
    $$.nd = mknode(NULL, NULL, $2.name);
}
;

class_body: class_atributes class_body {$$.nd = mknode($1.nd, $2.nd, "attribute");}
|  method '(' method_params ')' '{' body return '}' class_body{
   $$.nd = mknode($6.nd, $7.nd, "method");
}
|  {$$.nd = NULL;}
;

class_atributes: statement_atributes ';' {$$.nd = mknode($1.nd, NULL, "attributes_declaration");}
;


statement_atributes: TK_CLASS_NAME { strcpy(class_name, yylval.node_struct.name);} TK_ID {add('t'); $$.nd = mknode($1.nd, $3.nd, "class_var_declaration");}
| type TK_ID {add('a');} {$$.nd = mknode($1.nd, NULL, "declaration");}
| type TK_VECTOR TK_ID {add('a'); $$.nd = mknode($1.nd, NULL, "declaration"); } 
;

method: type TK_ID {add('m');} {$$.nd = mknode($1.nd, NULL, "method");}
;

method_params: type TK_ID {add('p');} ',' method_params {$$.nd = mknode($1.nd, $5.nd, "method_params");}
| type TK_ID {add('p'); $$.nd = mknode($1.nd, NULL, "method_params");}
| {$$.nd = NULL;}
;

body: body_statement body {$$.nd = mknode($1.nd, $2.nd, "body");}
| {
  $$.nd = NULL;
}

body_statement: TK_FOR {add('k');} '(' statement ';' condition ';' statement ')' '{' body '}'{
  struct node *aux = mknode($6.nd, $8.nd, "statement_for"); 
  $$.nd = mknode(mknode($4.nd, aux, "condition_for"), $11.nd, "for"); 
}
| statement ';' {$$.nd = mknode($1.nd, NULL, "statement");}
| TK_IF {add('k');} '(' condition ')' '{' body '}' {$$.nd = mknode($4.nd, $7.nd, "if");}
| else {  $$.nd = mknode($1.nd, NULL, "else");}
| io { $$.nd = $1.nd; }
| TK_CLASS_NAME {strcpy(class_name, yylval.node_struct.name);} TK_ID {add('o');} ';' {$$.nd = mknode(NULL, NULL, "object");}
;

io: TK_PRINTF {add('k');} '(' TK_STR ')' ';' {$$.nd = mknode(NULL, NULL, "printf");}
| TK_SCANF {add('k');} '(' TK_STR ',' '&' TK_ID ')' ';' {$$.nd = mknode(NULL, NULL, "scanf");} 
;

else: TK_ELSE {add('k');} '{' body '}' {$$.nd = mknode($4.nd, NULL, "else");}
| {$$.nd = NULL;}
;

statement: declaration
| assignment
| logical_operation
| data_access
;

declaration: type TK_ID {add('v');} {$$.nd = mknode($1.nd, NULL, "statement_id");}
| type TK_VECTOR TK_ID {add('v');} {$$.nd = mknode($1.nd, NULL, "statement_array"); } 
;

assignment: type TK_ID  {add('v');} '=' expression  {$$.nd = mknode($1.nd, $5.nd, "attribuition_id"); check_type($2.name);}
| type TK_VECTOR TK_ID {add('v');} '=' expression {$$.nd = mknode($1.nd, $6.nd, "attribuition_array"); } 
| TK_ID {check_declaration($1.name,0);} '=' expression {$$.nd = mknode($4.nd, NULL, "attribuition_id"); check_type($1.name);}
;

logical_operation: TK_ID {check_declaration($1.name,0);} relational_operators expression {$$.nd = mknode($3.nd, $4.nd, "expression_logic");}
;

data_access: TK_ID {check_declaration($1.name,0);} '[' TK_NUMBER ']' '=' expression {
    $$.nd = mknode($4.nd, NULL, "attribuition_array");
  }
| TK_ID { check_declaration($1.name,0); } '.' TK_ID {check_declaration($4.name,1); strcpy(attribute_name, $4.name);} class_operations {$$.nd = mknode($6.nd, NULL, "acess_object");}
| {$$.nd = NULL;}
;

class_operations: '=' expression { $$.nd = mknode($2.nd, NULL, "attribuition_object"); check_type(attribute_name); }
|'(' method_params ')'  {$$.nd = mknode($2.nd, NULL, "acess_method_object");}
| relational_operators expression  {$$.nd = mknode($1.nd, $2.nd, "expression_logic_object");}
|'(' method_params ')' relational_operators expression {
  struct node *aux = mknode($2.nd, $5.nd, "expression_logic"); 
  $$.nd = mknode(aux, $4.nd, "expression_logic_object");
}
| {$$.nd = NULL;}
;

type: TK_INT {insert_type();}
| TK_FLOAT {insert_type();} 
| TK_CHAR {insert_type();} 
| TK_STRING {insert_type();} 
| TK_VOID {insert_type();} 
;

condition: value relational_operators value  {
  $$.nd = mknode($1.nd, $3.nd, "expression_condition");
}
| TK_TRUE {add('k'); $$.nd = NULL;}
| TK_FALSE {add('k'); $$.nd = NULL;}
| expression TK_EQUAL expression {$$.nd = mknode($1.nd, $3.nd, "condition_equal");}
;

expression: expression TK_PLUS expression {
    $$.nd = mknode($1.nd, mknode($2.nd, $3.nd, "expression_arithmetic"), "expression_soma");
  }
| expression TK_MINUS expression {
    $$.nd = mknode($1.nd, mknode($2.nd, $3.nd, "expression_arithmetic"), "expression_subtracao");
  }
| expression TK_MULTIPLY expression {
    $$.nd = mknode($1.nd, mknode($2.nd, $3.nd, "expression_arithmetic"), "expression_multiplicacao");
  }
| expression TK_DIVISION expression {
    $$.nd = mknode($1.nd, mknode($2.nd, $3.nd, "expression_arithmetic"), "expression_divisao");
  }
| '(' expression TK_PLUS expression ')' {
    $$.nd = mknode($2.nd, mknode($3.nd, $4.nd, "expression_arithmetic"), "expression_soma_parenthesis");
  }
| '(' expression TK_MINUS expression ')' {
    $$.nd = mknode($2.nd, mknode($3.nd, $4.nd, "expression_arithmetic"), "expression_subtracao_parenthesis");
  }
| '(' expression TK_MULTIPLY expression ')' {
    $$.nd = mknode($2.nd, mknode($3.nd, $4.nd, "expression_arithmetic"), "expression_multiplicacao_parenthesis");
  }
| '(' expression TK_DIVISION expression ')' {
    $$.nd = mknode($2.nd, mknode($3.nd, $4.nd, "expression_arithmetic"), "expression_divisao_parenthesis");
  }
| value {
    $$.nd = mknode($1.nd, NULL, "value");
  }
| '(' value ')' {
    $$.nd = mknode($2.nd, NULL, "value");
  }
| expression TK_AND expression {
    $$.nd = mknode($1.nd, $3.nd, "expression_and");
  }
| expression TK_OR expression {
    $$.nd = mknode($1.nd, $3.nd, "expression_or");
  }
;

relational_operators: TK_GREATER 
| TK_GREATER_EQUAL 
| TK_LESS 
| TK_LESS_EQUAL 
| TK_EQUAL
| TK_NOT_EQUAL 
;

value: TK_NUMBER {
  add('c');} {$$.nd = mknode(NULL, NULL, "value_int");
}
| TK_FLOAT_NUMBER {add('c');} {
  $$.nd = mknode(NULL, NULL, "value_float");
}
| TK_CH {add('c');} {
  $$.nd = mknode(NULL, NULL, "value_char");
}
| TK_STR {add('c');} {
  $$.nd = mknode(NULL, NULL, "value_string");
}
| TK_ID {check_declaration($1.name,0);} 
;

return: TK_RETURN {add('k');} value ';' {$$.nd = mknode($3.nd, NULL, "return"); check_return();}
| {$$.nd = NULL;}
;

%%

int main(int argc, char **argv) {
    int i;
    for (i = 1; i < argc; i++) {
        strcpy(current_file_name, argv[i]);
        FILE *fp = fopen(argv[i], "r");
        count_line=1;
        if (fp == NULL) {
            printf("Error: could not open file %s\n", argv[i]);
            return 1;
          }
        yyin = fp;
        yyparse();
        fclose(fp);
        printf("\n\n");
        printf("-*-*-*-*-*-* Arvore sintatica - %s -*-*-*-*-**-*-*--*-\n\n", argv[i]);
        print_tree(head);
        printf("\n\n");
    }  
    printf("-*-*-*-*-*-* Tabela de simbolos -*-*-*-*-**-*-*--*-\n");
    for(int i=0; i<count; i++) {
      printf("%-30s\t%-10s\t%-10s\t%-10d\t%-10d\t%-10d\t%-30s\t\n", symbol_table[i].name, symbol_table[i].data_type, symbol_table[i].type, symbol_table[i].scope, symbol_table[i].scope_class, symbol_table[i].line, symbol_table[i].name_class);
    }
    for(int i=0;i<count;i++) {
      free(symbol_table[i].name);
      free(symbol_table[i].type);
    }
   
    printf("Quantidade de erros:%d\n",count_errors);
    for(int i=0; i<count_errors; i++) {
      printf("%s\n",errors[i]);
    }   
  }

void check_declaration(const char *c, int type) {
    int index = (type == 0) ? search(c) : search_attribute(c);
    
    if (index == -1) {
        if (type == 0) {
            sprintf(errors[count_errors], "File %s - Line %d: Variable %s was not declared\n", current_file_name, count_line, c);
        } else {
            sprintf(errors[count_errors], "File %s - Line %d: Variable %s was not declared\n", current_file_name, count_line, c);
        }
        count_errors++;
    } else {
        if (type == 0 && strcmp(symbol_table[index].type, "object") == 0) {
            object_index = index;
        }
    }
}

int check_value(const char *c) {
    if (c[0] == '\'') {
        return 0;
    } else if (c[0] == '"') {
        return 1;
    }

    if (strchr(c, '.') != NULL) {
        return 2;
    }
    return 3;
}

void check_type(const char *c1) {
    int var_index = -1;
    for (int i = count - 1; i >= 0; i--) {
        if (strcmp(symbol_table[i].name, c1) == 0) {
            var_index = i;
        }
    }
    if (var_index != -1 && strcmp(symbol_table[var_index].data_type, symbol_table[count - 1].data_type) != 0) {
        sprintf(errors[count_errors], "File %s - Line %d: The structure %s of type %s receives a value of type %s\n",
                current_file_name, count_line, symbol_table[var_index].name, symbol_table[var_index].data_type, symbol_table[count - 1].data_type);
        count_errors++;
    }
}

int check_class() {
  for (int i = count - 1; i >= 0; i--) {
      if (strcmp(symbol_table[i].name, class_name) == 0) {
          return i;
      }
  }
  sprintf(errors[count_errors], "File %s - Line %d: Class does not exist\n", current_file_name, count_line);    
  count_errors++;  

  return -1;
}


int search(const char *name) {
	int i;
	for(i=count-1; i>=0; i--) {
		if(strcmp(symbol_table[i].name, name)==0) {
      if(symbol_table[i].scope == current_scope || strcmp(symbol_table[i].type, "attribute") == 0){
			  return i;
			  break;
		}
    } 
	}
	return -1;
} 

int search_attribute(const char *name) {
  int index_class = -1;
  if (object_index != -1) {
      const char* class_name = symbol_table[object_index].name_class;
      for (int i = count - 1; i >= 0 && index_class == -1; i--) {
          if (strcmp(symbol_table[i].name, class_name) == 0) {
              index_class = i;
          }
      }
  }
  if (index_class == -1) return -1;
  for (int j = count - 1; j >= 0; j--) {
      if (strcmp(symbol_table[j].name, name) == 0 &&
          (strcmp(symbol_table[j].type, "attribute") == 0 || strcmp(symbol_table[j].type, "method") == 0) &&
          symbol_table[index_class].scope_class == symbol_table[j].scope_class) {
          return j;
      }
  }
  return -1;
}

 
int check_scope(const char *name) {
  for (int i = count - 1; i >= 0; i--) {
      if (strcmp(symbol_table[i].name, name) == 0) {
          if ((strcmp(symbol_table[i].type, "class") == 0) || 
              (symbol_table[i].scope == current_scope) || 
              ((strcmp(symbol_table[i].type, "attribute") == 0) && (symbol_table[i].scope_class == class_scope_level))) {
              return -1;
          }
          break;
      }
  }
  return 0;
}

void check_return() {
  int method_index = -1;
  for (int i = count - 1; i >= 0; i--) {
      if (strcmp(symbol_table[i].type, "method") == 0) {
          method_index = i;
          break;
      }
  }
  if (method_index != -1 && strcmp(symbol_table[method_index].data_type, "empty") != 0 && 
      strcmp(symbol_table[count - 1].data_type, symbol_table[method_index].data_type) != 0) {
      sprintf(errors[count_errors], "File %s - Line %d: The function %s of type %s returns a value of type %s\n", 
              current_file_name, count_line, symbol_table[method_index].name, 
              symbol_table[method_index].data_type, symbol_table[count - 1].data_type);
      count_errors++;
  }
}

void add(char c) {
      int q = check_scope(yylval.node_struct.name);
      if(!q){
        if(c == 'h') {
          symbol_table[count].name=strdup(yylval.node_struct.name);
          symbol_table[count].data_type=strdup(type);
          symbol_table[count].line=count_line;
          symbol_table[count].type=strdup("header");
          count++;
        }
        else if(c == 'k') {
          symbol_table[count].name=strdup(yylval.node_struct.name);
          symbol_table[count].data_type=strdup("N/A");
          symbol_table[count].line=count_line;
          symbol_table[count].type=strdup("keyword\t");
          count++;
        }
        else if(c == 'v') {
          symbol_table[count].name=strdup(yylval.node_struct.name);
          symbol_table[count].data_type=strdup(type);
          symbol_table[count].line=count_line;
          symbol_table[count].type=strdup("variable");
          symbol_table[count].scope=current_scope;
          count++;
        }
        else if(c == 'c') {
          char *v = strdup(yylval.node_struct.name);
          int q = check_value(v);
          if(q == 0){
            symbol_table[count].name=strdup(yylval.node_struct.name);
            symbol_table[count].data_type=strdup("char");
            symbol_table[count].line=count_line;
            symbol_table[count].type=strdup("constant");
            count++;

          }
          else if(q == 1){
            symbol_table[count].name=strdup(yylval.node_struct.name);
            symbol_table[count].data_type=strdup("string");
            symbol_table[count].line=count_line;
            symbol_table[count].type=strdup("constant");
            count++;

          }

          else if(q == 2){
            symbol_table[count].name=strdup(yylval.node_struct.name);
            symbol_table[count].data_type=strdup("float");
            symbol_table[count].line=count_line;
            symbol_table[count].type=strdup("constant");
            count++;
            
          }

          else if(q == 3){
            symbol_table[count].name=strdup(yylval.node_struct.name);
            symbol_table[count].data_type=strdup("integer");
            symbol_table[count].line=count_line;
            symbol_table[count].type=strdup("constant");
            count++;
            
          }
        }
        else if(c == 'm') {
          symbol_table[count].name=strdup(yylval.node_struct.name);
          symbol_table[count].data_type=strdup(type);
          symbol_table[count].line=count_line;
          symbol_table[count].type=strdup("method");
          symbol_table[count].scope=current_scope+1;
          symbol_table[count].scope_class=class_scope_level;
          current_scope++;
          count++;

        }
        else if(c == 's') {
          symbol_table[count].name=strdup(yylval.node_struct.name);
          symbol_table[count].data_type=strdup(type);
          symbol_table[count].line=count_line;
          symbol_table[count].type=strdup("class");
          symbol_table[count].scope_class=class_scope_level+1;
          count++;
          class_scope_level++;
        }

        else if(c == 'a') {
          symbol_table[count].name=strdup(yylval.node_struct.name);
          symbol_table[count].data_type=strdup(type);
          symbol_table[count].line=count_line;
          symbol_table[count].type=strdup("attribute");
          symbol_table[count].scope=current_scope;
          symbol_table[count].scope_class=class_scope_level;
          count++;
          }
        else if(c == 'p') {
          symbol_table[count].name=strdup(yylval.node_struct.name);
          symbol_table[count].data_type=strdup(type);
          symbol_table[count].line=count_line;
          symbol_table[count].type=strdup("parameter");
          symbol_table[count].scope=current_scope;
          count++;
        }
        else if(c == 'o') {
          int q = check_class();
          if(q!=-1){
            symbol_table[count].name=strdup(yylval.node_struct.name);
            symbol_table[count].data_type=strdup("N/A");
            symbol_table[count].line=count_line;
            symbol_table[count].type=strdup("object");
            symbol_table[count].scope=current_scope;
            symbol_table[count].scope_class=class_scope_level;
            symbol_table[count].name_class=class_name;
            count++;
           }
        }

        else if(c == 't') {
          int q = check_class();
          if(q!=-1){
            symbol_table[count].name=strdup(yylval.node_struct.name);
            symbol_table[count].data_type=strdup("N/A");
            symbol_table[count].line=count_line;
            symbol_table[count].type=strdup("attribute");
            symbol_table[count].scope=current_scope;
            symbol_table[count].scope_class=class_scope_level;
            symbol_table[count].name_class=class_name;
            count++;
           }
        }
        
      
      }
    
      else{
        sprintf(errors[count_errors], "File %s - Line %d: Structure %s already declared\n", current_file_name,count_line, yylval.node_struct.name);
		    count_errors++;
    }
}      
    
void insert_type() {
      strcpy(type, yylval.node_struct.name);
}

void print_tree(struct node *tree) {
  printf("\nInorder:\n\n");
  printInorder(tree);
  printf("\n\nPreorder:\n\n");
  printPreorder(tree);
}

void printInorder(struct node *tree) {
    if (tree->left) {
        printInorder(tree->left); 
    } 
    printf("%s, ", tree->token); 
    if (tree->right) {  
        printInorder(tree->right); 
    }
}

void printPreorder(struct node *tree) {
    printf("%s, ", tree->token); 
    if (tree->left) {
        printPreorder(tree->left); 
    } 
    if (tree->right) {  
        printPreorder(tree->right); 
    }
}

struct node* mknode(struct node *left, struct node *right, char *token) {	
	struct node *newnode = (struct node *)malloc(sizeof(struct node));
	char *newstr = (char *)malloc(strlen(token)+1);
	strcpy(newstr, token);
	newnode->left = left;
	newnode->right = right;
	newnode->token = newstr;
	return(newnode);
}

void yyerror(const char* msg) {
        fprintf(stderr, "%s\n", msg);
}