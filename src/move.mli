open Board

(* the following type tells one step during one game*)
type step={start:position; destination: position; piece_captured: piece}

module type Move_Info:
sig  
  type board

  val check_valid: board->step->bool

  val update: board->board option

  val generate_piece_move: board->piece->step list option
end 
