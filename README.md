# Problem

Suppose one has matrix  

![](https://latex.codecogs.com/gif.latex?%5Cbegin%7Bpmatrix%7D%20a%20%26%20%26%20b%5C%5C%20%26%20e%20%26%20%5C%5C%20c%20%26%20%26%20d%20%5Cend%7Bpmatrix%7D)

The problem is to find number e if two pairs of numbers (a,b,c,d) is given (using only simple arithmetic operations (+, -, /, *)(brackets are allowed)).  

# Example of problem

For two given matrices

![](https://latex.codecogs.com/gif.latex?%5Cbegin%7Bpmatrix%7D%203%20%26%20%26%2022%5C%5C%20%26%204%20%26%20%5C%5C%2014%20%26%20%26%205%20%5Cend%7Bpmatrix%7D) ![](https://latex.codecogs.com/gif.latex?%5Cbegin%7Bpmatrix%7D%2012%20%26%20%26%2011%5C%5C%20%26%2028%20%26%20%5C%5C%2032%20%26%20%26%205%20%5Cend%7Bpmatrix%7D)

Find e using only simple arithmetic operations (+, -, /, *) (brackets are allowed).

![](https://latex.codecogs.com/gif.latex?%5Cbegin%7Bpmatrix%7D%2013%20%26%20%26%206%5C%5C%20%26%20%7B%5Ccolor%7BRed%7D%20e%7D%20%26%20%5C%5C%208%20%26%20%26%2023%20%5Cend%7Bpmatrix%7D)

e = 106 (one can run MathPuzzle.sql to check this c*d - a*b).

# Main Idea

1. Generate all possible combination of 4 letters expressions (using reverse polish notation).  
2. Replace 4 letters with given numbers.  
3. Use Dijkstra's Two-Stack Algorithm to calculate the final value.  
4. Find solution to the problem by SQL query.  

# Solution

1. Stack.typ is ordinary stack structure implimented in PL/SQL.  
2. MathPuzzle.pck this file contains declaration and body which allow to solve current problem  
  >* function is_operand(x varchar2) return boolean  
  >  Function returns True if current element of the string is operand  
  >* function get_infix_from_postfix(string_ varchar2) return varchar2  
  >  Function return infix notation from postfix  
  >  723*- --> 7 - 2*3.  
  >* function can_add_operator(string_ varchar2) return boolean  
  >  The function returns True if we can add operator to current expression:  
  >    we scan the list and add +1 to counter when we meet a letter  
  >    and we add -1 when we meet an operator (it reduces  
  >    last two letters into 1 (say ab+ <--> a + b)  
  >* function concat (ilist1 as_array, ilist2 as_array) return as_array  
  >  Function returns two concatinated collections  
  >* function possible_elements(items as_array, string_ varchar2) return as_array  
  >  The function returns a list, that contains operators and  
  >    letters, one of which we can add to the current expression.  
  >* procedure rec(exp varchar2)  
  >  Main procedure that generates all possible 4 letters expressions and writes them into table.  
  >* function calculator (in_string varchar2 default '(1+((2+3)*(4*5)))') return number  
  >  Function returns evaluation of expression using Dijkstra's Two-Stack Algorithm 
  >* function substitute_letter_to_numbers(in_str varchar2, a number, b number,c number, d number) return varchar2   
  >  Function returns numerical expression  
  >   (((b+a)*c)+d) --> (((1+2)*3)+4) if a=1, b=2, c=3, d=4  
3. MathPuzzle.sql is the example of usage

# Installation 

1. Run Stack.typ
2. Run MathPuzzle.pck
3. Run "begin MathPuzzle.rec(''); end;" to fill main table
4. One can run queries agains filled table rpn_combinations
