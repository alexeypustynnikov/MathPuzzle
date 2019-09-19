with t as (
           select exp,
                  MathPuzzle.get_infix_from_postfix(exp) formula--,
                  --MathPuzzle.substitute_letter_to_numbers(MathPuzzle.get_infix_from_postfix(exp),3,22,14,5)
           from rpn_combinations t
           where MathPuzzle.calculator(MathPuzzle.substitute_letter_to_numbers(MathPuzzle.get_infix_from_postfix(exp),3,22,14,5)) = 4
           intersect 
           select exp,
                  MathPuzzle.get_infix_from_postfix(exp)--,
                  --MathPuzzle.substitute_letter_to_numbers(MathPuzzle.get_infix_from_postfix(exp),12,11,32,5)
           from rpn_combinations t
           where MathPuzzle.calculator(MathPuzzle.substitute_letter_to_numbers(MathPuzzle.get_infix_from_postfix(exp),12,11,32,5)) = 28
) 
select distinct MathPuzzle.calculator(MathPuzzle.substitute_letter_to_numbers(formula,13,6,8,23)) from t

