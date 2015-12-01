open Board
open Piece

(* The color of AI's side; Red is true and Black if false *)
val col: bool

(*compute the score based on the current board information*)
val evaluate: board->bool->int
