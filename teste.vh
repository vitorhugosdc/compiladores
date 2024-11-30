Class Teste{
    integer var1;
    integer var2;
    Teste var3;
    Auxiliar var4; //(erro)
    integer funcao(integer p){
        p=0;//paramatro passado para a funcao
        integer var1; // declarando uma variavel com o mesmo nome de um atributo da classe(erro)
        p=2.0; // (erro)
        integer t;
        float v = "erro"; // (erro)
        float v2 = 3.0;
        integer a = 0;
        integer a = 1; //ja foi declarada(erro)
        b=0; // nao foi declarada(erro)
        integer c;
        c='c'; // (erro)
        
        integer vect vetor;
        vetor[0]=0;
        
        for(integer d=0; d>20; d=d+1){
            print("teste for");
        }
        if(t==0){
            print("teste if");
        }
        else{
            print("teste else");
            scan("",&t);

        } 
        
        return "erro"; // (erro)
    }

    integer funcao2(){
        integer t;
        a=0; // nao foi declarado, teste do novo check_declaration (erro)
        var1=20;
        return 0;
        
    }

    integer funcao2(){ // metodo ja declarado(erro)
        integer t;
        a=0; // nao foi declarado, teste do novo check_declaration (erro)
        
        return 0;
    }
}
