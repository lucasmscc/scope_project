# Linguagem Funcional 3 com Suporte a Números Complexos (Funcional 3C)

Universidade Federal de Pernambuco - Centro de Informática
IN1007 - Paradigmas de Linguagens de Programação

## Equipe

* Dayane Lira
* Lucas Mascena

---

## 1. Escopo e Motivação

Este projeto estende a linguagem **Funcional 3** (caracterizada por transparência referencial, funções de primeira classe, recursão, listas e compreensão de listas) introduzindo suporte nativo ao tipo de dado **Número Complexo** e aritmética no plano complexo.

Na matemática e em engenharia, números complexos possuem a forma $z = a + bi$, em que $a \in \mathbb{Z}$ representa a parte real e $b \in \mathbb{Z}$ a parte imaginária. Na **Funcional 3C**, números complexos são tratados como valores imutáveis e de primeira classe (`ValorConcreto`).

Como valores de primeira classe, números complexos podem:

* Ser atribuídos a identificadores por meio de `let`/`var`;
* Ser passados como argumentos para funções;
* Ser retornados por funções;
* Ser utilizados por funções de alta ordem;
* Ser armazenados em listas;
* Ser processados por meio de compreensão de listas;
* Participar de expressões aritméticas simbólicas.

O principal objetivo da extensão é permitir que as **quatro operações aritméticas básicas** (`+`, `-`, `*`, `/`) sejam realizadas diretamente sobre números complexos, sem a necessidade de decompor manualmente suas partes real e imaginária.

---

## 2. Elementos Adicionados

### 2.1 Novas Estruturas e Tipos

* **`ValorComplexo` / `ExpComplexa`** : Estrutura interna que armazena dois nós de expressão simbólica (`real` e `imaginario`).
* **`TipoComplexo`** : Interface de tipo para validação e checagem estática/dinâmica.
* **Literal / Construtor `complex(e1, e2)`** : Criação de um número complexo onde `e1` e `e2` podem ser inteiros, reais ou expressões algébricas simbólicas contendo identificadores.
* **Símbolo `sym("x")` / Variável Simbólica** : Expressão que representa uma incógnita não avaliada.

### 2.2 Operadores Unários

* **`re(e)`**: retorna o `ValorInteiro` referente à parte real de $z$.
* **`im(e)`**: retorna o `ValorInteiro` referente à parte imaginária de $z$.
* **`abs(e)`**: calcula o módulo/norma $\Vert{}z\Vert{} = \sqrt{a^2 + b^2}$ (retorna `ValorInteiro` truncado/aproximado).
* **`conj(e)`**: retorna o conjugado complexo $\bar{z} = a - bi$.
* **`simplify(e)`** : Simplifica algebricamente a expressão complexa resultante das operações simbólicas.

### 2.3 Operadores Binários e Promoção de Tipos

Os quatro operadores binários fundamentais (`+`, `-`, `*`, `/`) aplicados a números complexos simbólicos **$z_1 = a + bi$** e **$z_2 = c + di$** seguem as regras algébricas expandidas simbolicamente:

1. **Adição (`+`)** : **$(a + c) + (b + d)i$**
2. **Subtração (`-`)** : **$(a - c) + (b - d)i$**
3. **Multiplicação (`*`)** : **$(ac - bd) + (ad + bc)i$**
4. **Divisão (`/`)** : **$\left(\frac{ac + bd}{c^2 + d^2}\right) + \left(\frac{bc - ad}{c^2 + d^2}\right)i$**

Para manter a ergonomia da linguagem, foi implementada uma regra de **coerção/promoção estática de tipos**:

| Operando Esquerdo | Operando Direito | Tipo Resultante | Ação de Promoção           |
| :---------------- | :--------------- | :-------------- | :----------------------------- |
| `INTEIRO`       | `INTEIRO`      | `INTEIRO`     | Nenhuma (operação nativa)    |
| `COMPLEXO`      | `COMPLEXO`     | `COMPLEXO`    | Nenhuma                        |
| `INTEIRO`       | `COMPLEXO`     | `COMPLEXO`    | Promove$a \to complex(a, 0)$ |
| `COMPLEXO`      | `INTEIRO`      | `COMPLEXO`    | Promove$a \to complex(a, 0)$ |


## 3. Exemplos de Código

### 3.1 Instanciação SImbólica e Operações Básicas

```sml
let
    // Criando números complexos simbólicos: z1 = x + 2i, z2 = 3 + yi
    var z1 = complex(sym("x"), 2)
    var z2 = complex(3, sym("y"))
  
    // Adição simbólica: (x + 3) + (2 + y)i
    var soma = z1 + z2
  
    // Conjugado simbólico: x - 2i
    var z1_conj = conj(z1)
in
    soma
end;
```

### 3.2 Operações SImbólicas

```sml
let
    var z1 = complex(sym("a"), sym("b"))
    var z2 = complex(sym("c"), sym("d"))

    var s = z1 + z2  // Resulta: complex(a + c, b + d)
    var sub = z1 - z2 // Resulta: complex(a - c, b - d)
    var m = z1 * z2  // Resulta: complex(a*c - b*d, a*d + b*c)
    var d = z1 / z2  // Resulta: complex((a*c + b*d)/(c^2 + d^2), (b*c - a*d)/(c^2 + d^2))
in
    d
end;
```

### 3.3 Promoção de Tipos e Simplificação

```sml
let
    var z = complex(sym("x"), 4)
    // Promoção implícita do inteiro 5 para complex(5, 0) na multiplicação simbólica
    var expr = simplify(z * 5)
in
    expr // Resulta em: complex(5*x, 20)
end;
```

### 3.4 Avaliação (Substituição de Símbolos)

```sml
let
    var z_simbolico = complex(sym("x"), sym("y")) * complex(2, 1)
    // Avalia substituindo x=1 e y=3 na expressão simbólica gerada
    var z_avaliado = eval(z_simbolico, [("x", 1), ("y", 3)])
in
    z_avaliado
end;
```

## 4. Gramática




```ebnf
Programa ::= Expressao

Expressao ::= Valor
           | ExpUnaria
           | ExpBinaria
           | ExpDeclaracao
           | Id
           | Aplicacao
           | IfThenElse

Valor ::= ValorConcreto
        | ValorSimbolico
        | ValorAbstrato

ValorAbstrato ::= ValorFuncao

ValorConcreto ::= ValorInteiro
                | ValorBooleano
                | ValorString
                | ValorLista
                | ValorComplexo

ValorSimbolico ::= "sym" "(" StringLiteral ")"

ValorFuncao ::= "fn" Id Id "." Expressao

ValorComplexo ::= "complex" "(" Expressao "," Expressao ")"

ExpUnaria ::= "-" Expressao
            | "not" Expressao
            | "length" Expressao
            | "head" "(" Expressao ")"
            | "tail" "(" Expressao ")"
            | "re" "(" Expressao ")"
            | "im" "(" Expressao ")"
            | "abs" "(" Expressao ")"
            | "conj" "(" Expressao ")"
            | "simplify" "(" Expressao ")"
            | ExpCompreensaoLista

ExpCompreensaoLista ::= Expressao Gerador
                      | Expressao Gerador Filtro

Gerador ::= "for" Id "in" Expressao
          | "for" Id "in" Expressao "," Gerador

Filtro ::= "if" Expressao

ExpBinaria ::= Expressao "+" Expressao
             | Expressao "-" Expressao
             | Expressao "*" Expressao
             | Expressao "/" Expressao
             | Expressao ">" Expressao
             | Expressao "<" Expressao
             | Expressao "and" Expressao
             | Expressao "or" Expressao
             | Expressao "==" Expressao
             | Expressao "++" Expressao
             | Expressao ".." Expressao
             | Expressao ":" Expressao
             | Expressao "^^" Expressao
             | "eval" "(" Expressao "," ListaPares Substituicao ")"

ListaParesSubstituicao ::= "[" ParSubstituicao "]"
                         | "[" ParSubstituicao ("," ParSubstituicao)* "]"

ParSubstituicao ::= "(" StringLiteral "," Expressao ")"

ExpDeclaracao ::= "let" DeclaracaoFuncional "in" Expressao

DeclaracaoFuncional ::= DecVariavel
                      | DecFuncao
                      | DecComposta

DecVariavel ::= "var" Id "=" Expressao

DecFuncao ::= "fun" ListId "=" Expressao

DecComposta ::= DeclaracaoFuncional "," DeclaracaoFuncional

ListId ::= Id
        | Id "," ListId

Aplicacao ::= Expressao "(" ListExp ")"

ListExp ::= Expressao
        | Expressao "," ListExp
```
