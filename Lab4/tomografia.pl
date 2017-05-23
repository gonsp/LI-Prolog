% A matrix which contains zeroes and ones gets "x-rayed" vertically and
% horizontally, giving the total number of ones in each Row and column.
% The problem is to reconstruct the contents of the matrix from this
% information. Sample run:
%
%	?- p.
%	    0 0 7 1 6 3 4 5 2 7 0 0
%	 0                         
%	 0                         
%	 8      * * * * * * * *    
%	 2      *             *    
%	 6      *   * * * *   *    
%	 4      *   *     *   *    
%	 5      *   *   * *   *    
%	 3      *   *         *    
%	 7      *   * * * * * *    
%	 0                         
%	 0                         
%	

:- use_module(library(clpfd)).

ejemplo1( [0,0,8,2,6,4,5,3,7,0,0], [0,0,7,1,6,3,4,5,2,7,0,0] ).
ejemplo2( [10,4,8,5,6], [5,3,4,0,5,0,5,2,2,0,1,5,1] ).
ejemplo3( [11,5,4], [3,2,3,1,1,1,1,2,3,2,1] ).

p :- 
	ejemplo1(Rowsums, ColSums),
	length(Rowsums, NumRows),
	length(ColSums, NumCols),
	NVars is NumRows * NumCols,
	listVars(NVars, L), % generate a list of Prolog vars (their names do not matter)
	L ins 0..1,
	matrixByRows(L, NumCols, MatrixByRows),
	write(MatrixByRows), nl, nl,
	transpose(MatrixByRows, MatrixByColumns),
	declareConstraints(Rowsums, MatrixByRows),
	declareConstraints(ColSums, MatrixByColumns),
	label(L),
	pretty_print(Rowsums, ColSums, MatrixByRows).

listVars(0, []) :- !.
listVars(NVars, [VAR|R]) :-
	N is NVars-1,
	listVars(N, R).

matrixByRows(L, NumCols, [Row|Rows]) :-
	append(Row, Rest, L),
	length(Row, NumCols),
	matrixByRows(Rest, NumCols, Rows).
matrixByRows([], _, []).

transpose2(M, T) :-
	[First|_] = M,
	length(First, Cols),
	Condition = (between(1, Cols, Pos), findall(X, (member(Row, M), nth1(Pos, Row, X)), RowT)),
	findall([RowT], Condition, T).

declareConstraints(Sums, Mat) :-
	length(Sums, Cols),
	between(1, Cols, Pos),
	nth1(Pos, Sums, Sum),
	nth1(Pos, Mat, Row),
	declareConstraint(Sum, Row).
	
declareConstraint(Sum, Row) :-
	expressSum(Row, Expr),
	write(Expr #= Sum), nl.
	
expressSum([V], V) :- !.
expressSum([V|Values], V + Expr) :-
	expressSum(Values, Expr).

pretty_print(_, ColSums, _) :- 
	write('     '), 
	member(S, ColSums), 
	writef('%2r ', [S]), fail.
pretty_print(Rowsums, _, M) :- 
	nl, nth1(N, M, Row), nth1(N, Rowsums, S), 
	nl, writef('%3r   ', [S]), 
	member(B, Row), 
	wbit(B), fail.
pretty_print(_, _, _).

wbit(1) :- write('*  '), !.
wbit(0) :- write('   '), !.


main :- p.