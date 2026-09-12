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

Como valores de primeira classe, eles podem ser:
* Atribuídos a identificadores via `let var`;
* Passados como argumentos e retornados por funções de alta ordem;
* Estruturados em listas e processados concorrentemente/funcionalmente por meio de compreenções de listas.

---

## 2. Elementos Adicionados

### 2.1 Novas Estruturas e Tipos
* **`ValorComplexo`**: subclasse de `ValorConcreto` que armazena dois valores numéricos (`real` e `imaginario`).
* **`TipoComplexo`**: implementação da interface `Tipo` utilizada pelo ambiente de compilação para validação e checagem estática de tipos.
* **Literal `complex(e1, e2)`**: construção sintática primária para instanciação de números complexos a partir de duas expressões inteiras.

### 2.2 Operadores Unários
* **`re(e)`**: retorna o `ValorInteiro` referente à parte real de $z$.
* **`im(e)`**: retorna o `ValorInteiro` referente à parte imaginária de $z$.
* **`abs(e)`**: calcula o módulo/norma $\Vert{}z\Vert{} = \sqrt{a^2 + b^2}$ (retorna `ValorInteiro` truncado/aproximado).
* **`conj(e)`**: retorna o conjugado complexo $\bar{z} = a - bi$.

### 2.3 Operadores Binários e Promoção de Tipos
Os operadores aritméticos (`+`, `-`, `*`, `/`) e a comparação de igualdade (`==`) foram sobrecarregados para aceitar operandos do tipo `TipoComplexo`.

Para manter a ergonomia da linguagem, foi implementada uma regra de **coerção/promoção estática de tipos**:

| Operando Esquerdo | Operando Direito | Tipo Resultante | Ação de Promoção |
| :--- | :--- | :--- | :--- |
| `INTEIRO` | `INTEIRO` | `INTEIRO` | Nenhuma (operação nativa) |
| `COMPLEXO` | `COMPLEXO` | `COMPLEXO` | Nenhuma |
| `INTEIRO` | `COMPLEXO` | `COMPLEXO` | Promove $a \to complex(a, 0)$ |
| `COMPLEXO` | `INTEIRO` | `COMPLEXO` | Promove $a \to complex(a, 0)$ |

---

## 3. Exemplos de Código

### 3.1 Definição, Extração e Promoção de Tipos

```sml
// Construtor do número complexo
fun complex(r: real, i: real) : Complex =
    { re = r, im = i }

// Promoção implícita: Converte real/inteiro para Complex
fun toComplex(n: real) : Complex =
    { re = n, im = 0.0 }

// Funções Extratoras
fun re(z: Complex) : real = z.re
fun im(z: Complex) : real = z.im

// Operações Aritméticas Básicas
fun somar(z1: Complex, z2: Complex) : Complex =
    complex(z1.re + z2.re, z1.im + z2.im)

fun multiplicar(z1: Complex, z2: Complex) : Complex =
    complex(z1.re * z2.re - z1.im * z2.im, z1.re * z2.im + z1.im * z2.re)

// Conjugado e Módulo (Norma)
fun conj(z: Complex) : Complex =
    complex(z.re, ~ (z.im))

fun abs(z: Complex) : real =
    Math.sqrt(z.re * z.re + z.im * z.im)

// Definição da estrutura de Lista encadeada
datatype 'a list = Nil | Cons of 'a * 'a list

// Função de alta ordem: Map (para transformar elementos)
fun map f Nil = Nil
  | map f (Cons(x, xs)) = Cons(f x, map f xs)

// Função de alta ordem: Filter (para filtrar elementos)
fun filter pred Nil = Nil
  | filter pred (Cons(x, xs)) = 
        if pred x then Cons(x, filter pred xs)
        else filter pred xs
```

### 3.2 Operações Aritméticas e Conjugado

```sml
let
    var z1 = complex(1.0, 2.0)
    var z2 = complex(3.0, ~4.0)
    var resultado3_2 = conj(multiplicar(z1, z2))
in
    resultado3_2
end;
```

### 3.3 Uso de Números Complexos com Filtro/Transformação em Lista

```sml
let
    fun norma(z: Complex) = abs(z)
    var lista = Cons(complex(1.0, 1.0), Cons(complex(3.0, 4.0), Cons(complex(0.0, 2.0), Nil)))
    var filtrados = filter (fn z => abs(z) > 2.0) lista
    var resultado3_3 = map norma filtrados
in
    resultado3_3
end;
```

### 3.4 Funções de Alta Ordem com Complexos

```sml
let
    fun transformar(f, z: Complex) = f(z)
    var resultado3_4 = transformar(fn z => somar(conj(z), complex(1.0, 1.0)), complex(2.0, 3.0))
in
    resultado3_4
end
```

## 4. Gramática

Programa ::= Expressao

Expressao ::= Valor
           | ExpUnaria
           | ExpBinaria
           | ExpDeclaracao
           | Id
           | Aplicacao
           | IfThenElse

Valor ::= ValorConcreto
        | ValorAbstrato

ValorAbstrato ::= ValorFuncao

ValorConcreto ::= ValorInteiro
                | ValorBooleano
                | ValorString
                | ValorLista
                | ValorComplexo

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
