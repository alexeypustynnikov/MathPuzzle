create table rpn_combinations (exp varchar2(500));
/
                                            
create or replace package MathPuzzle is

type as_array is table of varchar2(4000);

function is_operand(x varchar2) return boolean;
function get_infix_from_postfix(string_ varchar2) return varchar2;
function can_add_operator(string_ varchar2) return boolean;
function concat (ilist1 as_array, ilist2 as_array) return as_array;
function possible_elements(items as_array, string_ varchar2) return as_array;
procedure rec(exp varchar2);
function calculator (in_string varchar2 default '(1+((2+3)*(4*5)))') return number;
function substitute_letter_to_numbers(in_str varchar2, a number, b number,c number, d number) return varchar2;

end MathPuzzle;
/
create or replace package body MathPuzzle is


-------------------------------------------------------------------
--Function returns True if current element of the string is operand
-------------------------------------------------------------------
function is_operand(x varchar2) return boolean is
  begin
    --dbms_output.put_line(x);
    if x <> '+' and x <> '-' and x <> '*' and x <> '/'
      then
        return True;
      else
        return False;
    end if;
  end;


--Function return infix notation from postfix
-- 723*- --> 7 - 2*3.
function get_infix_from_postfix(string_ varchar2) return varchar2 is 
  v_stack stack := stack();
  v_length number;
  letter varchar2(500);
  prev_letter  varchar2(500);
  prev_prev_letter  varchar2(500);
  str_to_push varchar2(500);
  begin
    v_length := length(string_);
    for i in 1..v_length
    loop
      letter := substr(string_,i,1) ;
      if is_operand(letter) 
        then
          v_stack.push(letter);
        else 
          prev_letter := v_stack.pop();
          prev_prev_letter := v_stack.pop();
          str_to_push := '(' || prev_prev_letter || letter || prev_letter || ')';
          v_stack.push(str_to_push);
        end if;
    end loop;
    return v_stack.pop();
  end;  

/*The function returns True if we can add operator to current expression:
we scan the list and add +1 to counter when we meet a letter
and we add -1 when we meet an operator (it reduces
last two letters into 1 (say ab+ <--> a + b)*/

function can_add_operator(string_ varchar2) return boolean is 
  n number;
  v_length number;
  letter varchar2(500);
  begin
    n := 0;
    v_length := length(string_);
    for i in 1..v_length
    loop
      letter := substr(string_,i,1);
      if letter <> '+' and letter <> '-' and letter <> '*' and letter <> '/'
        then 
          n := n + 1;
        else 
          n := n - 1;
      end if;
    end loop;
    return n > 1;
  end;


--Function returns two concatinated collections
function concat (ilist1 as_array, ilist2 as_array) 
return as_array is
 lconcat as_array;
begin
    lconcat := ilist1 multiset union  ilist2;
    return lconcat;
end concat;

/*The function returns a list, that contains operators and
letters, one of which we can add to the current expression.
*/

function possible_elements(items as_array, string_ varchar2) return as_array is
  v_length number;
  letter varchar2(500);
  str_col as_array := as_array();
  result as_array := as_array();
  op_array as_array := as_array('+', '-', '*', '/');
  begin
    v_length := length(string_);
    --17.09.2019
    if v_length is null then
      result := items;
    else 
      for i in 1..v_length
        loop
          letter := substr(string_,i,1);
          str_col.EXTEND(1);
          str_col(str_col.COUNT) := letter;
        end loop;
     result := items multiset except str_col;
     if can_add_operator(string_) 
     then
       result := concat(op_array, result);
     end if;
    end if;
   
  return result;
  end;

--#exp -- current expression, base of recursion is exp = ''
procedure rec(exp varchar2) is
  elements_to_try as_array := as_array();
  letters as_array := as_array('a', 'b', 'c', 'd');
  begin
    elements_to_try := possible_elements(letters, exp);
    for i in 1..elements_to_try.count
      loop
        if possible_elements(letters, exp || elements_to_try(i)).count = 0
          then 
            insert into rpn_combinations values (exp || elements_to_try(i));
            commit;
          else 
            rec(exp || elements_to_try(i));
        end if;
      end loop;
  end;

--Function returns numerical expression
--(((b+a)*c)+d) --> (((1+2)*3)+4) if a=1, b=2, c=3, d=4
function substitute_letter_to_numbers(in_str varchar2, a number, b number,c number, d number) return varchar2 is
  out_str varchar2(500);
  begin 
    out_str := replace(in_str, 'a', a);
    out_str := replace(out_str, 'b', b);
    out_str := replace(out_str, 'c', c);
    out_str := replace(out_str, 'd', d);
    return out_str;
  end; 

--Funstion that checks if given symbol is a number or not
function is_number(p_str varchar2)
  return boolean
is
  l_num number;
begin
  l_num := to_number( p_str );
  return True;
exception
  when value_error then
    return False;
end;

--Function that gets number from string                                      
function f_get_whole_number(p_str varchar2)
  return varchar2
is
  indx number := 1;
  output varchar2(100);
begin
  while is_number(substr(p_str,indx,1)) or substr(p_str,indx,1) in ('.',',')
  loop
    output := output || substr(p_str,indx,1);
    indx := indx + 1;
  end loop;
  return output;
end;

--Function that creates iterator for calculator function
function create_iterator_from_str(in_str varchar2) return as_array is 
  out_arr as_array := as_array();
  char_indx number := 1;
  whole_number varchar2(100);
begin 
  while char_indx <= length(in_str) loop
     out_arr.extend(1);
     if is_number(substr(in_str,char_indx,1)) then
       whole_number := f_get_whole_number(substr(in_str,char_indx));
       out_arr(out_arr.last) := whole_number;
       char_indx := char_indx + length(whole_number);
       continue;
     else 
       out_arr(out_arr.last) := substr(in_str,char_indx,1);
     end if;
     
     char_indx := char_indx + 1;
  end loop;
  
  return out_arr;
end;                         
 
--Function returns evaluation of expression using Dijkstra Two-stack Algorithm
function calculator (in_string varchar2 default '(1+((2+3)*(4*5)))') return number is
  ops stack := stack();
  vals stack := stack();
  v_length number(10);
  v_out varchar2(1000);
  op varchar2(1000);
  v varchar2(1000);
  iterator as_array := create_iterator_from_str(in_string);
  begin
  --v_length := length(in_string);
  v_length := iterator.last;
  for i in 1..v_length
  loop
   --v_out  := substr(in_string,i,1);
   v_out := iterator(i);                                        
   if v_out = '(' then null;
   elsif v_out = '+' then ops.push(v_out);
   elsif v_out = '-' then ops.push(v_out);
   elsif v_out = '*' then ops.push(v_out);
   elsif v_out = '/' then ops.push(v_out);
   elsif v_out = ')' then
    op := ops.pop();
    v := to_number(vals.pop());
    if op = '+' then v := to_number(vals.pop()) + v;
    elsif op = '-' then v := to_number(vals.pop()) - v;
    elsif op = '*' then v := to_number(vals.pop()) * v;
    elsif op = '/' then v := to_number(vals.pop()) / v;
    end if;
    vals.push(to_char(v));
   else vals.push(v_out);
   end if;
  end loop;
  --dbms_output.put_line(vals.pop());
  return to_number(vals.pop());
  exception
  when others then
    return null;
  end;

end MathPuzzle;
/
