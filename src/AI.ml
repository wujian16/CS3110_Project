open Piece
open Board
open Move
open Score
exception TODO

type board_hashcode = string

type search_result = {depth:int; best:step list; conclu:int}

type transposition_table = (string, search_result) Hashtbl.t

type history_table = (string, search_result) Hashtbl.t

let nHistoryTable=Hashtbl.create (90*90)

let ()=
	for i = 1 to 9 do
	  for j=1 to 10 do
			for m=1 to 9 do
				for n=1 to 10 do
					Hashtbl.add nHistoryTable ((i,j),(m,n)) 0
				done
			done
		done
	done

let sort b = raise TODO

(* compare the vals of two steps in history table*)
let compared s1 s2=
	(Hashtbl.find nHistoryTable (s2.start, s2.destination))
	-(Hashtbl.find nHistoryTable (s1.start, s1.destination))

let check_end_game (b:board) (p:prev_step) : bool =
	(generate_all_moves b p true = []) || (generate_all_moves b p false = []) ||
	(not ((check_alive b "GR") && (check_alive b "GB")))

let cnt = ref 0

let rec alphaBeta (alpha:int) (beta:int) (depth_left:int)
	(b:board) (p:prev_step) (ai_col:bool) (curr_rd:bool): int*step list =

	if depth_left = 0 then (cnt := !cnt + 1; (*print_int !cnt; Printf.printf "\n"; *)((eval_board b ai_col),[]))
	else if check_end_game b p then (cnt := !cnt + 1; (*print_int !cnt; Printf.printf "\n";*)((eval_board b ai_col),[]))
	else

		(if curr_rd = ai_col then
			(let result = ref min_int in
			let v = ref alpha in
			let i = ref 0 in
			let best_steps = ref [] in
			begin match (generate_all_moves b p ai_col) with
			(*let h_e = (generate_piece_move b p canR1) in
			begin match h_e with*)
			| [] -> (depth_left - max_int,[])
			| l ->
				List.iter (fun a -> if (in_bound a.start)&&(in_bound a.destination) then ()
					else print_step a) l;
				(*List.iter print_step l;*)
				let sorted_l = List.sort compared l in
				let all_moves = Array.of_list sorted_l in

				while ((!i < (Array.length all_moves)) && (beta <> !result))
				do

					let (updated_b,updated_prev) = update_unmutable all_moves.(!i) b p in
					let (score,new_best_steps) = alphaBeta !v beta (depth_left - 1)
								updated_b updated_prev ai_col (not curr_rd) in
					(*
					Printf.printf "\nIts %d's child has score %d. Its best moves are: \n" !i score;
					List.iter print_step new_best_steps;
					Printf.printf "\nThe current alpha is %d; beta is %d\n" !v beta;*)
          			let flag=ref false in
					(if (score > !v) then
						(
						v:= score;
						(*Printf.printf "Score is greater than current alpha. Alpha is updated: %d\n" !v;*)
 						best_steps:= all_moves.(!i)::new_best_steps;
						flag:=true
						(*Printf.printf "Now the best steps are: \n";
						List.iter print_step !best_steps*)
						)
					else if (score > beta) then
						((*Printf.printf "Score is greater than beta, impossible, break immediately\n";*)
						result := beta;
					  flag:=true
					  )
					else ()(*(Printf.printf "Nothing happens\n")*)
					);

					(if (!flag=true) then
						let new_val=(Hashtbl.find nHistoryTable
						(all_moves.(!i).start,all_moves.(!i).destination))+(depth_left*depth_left)
						in
						(Hashtbl.replace nHistoryTable
						(all_moves.(!i).start,all_moves.(!i).destination)
					  new_val)
          			else ());
					cnt := !cnt + 1;
					i:= !i+1
				done;
				(*print_int !cnt;Printf.printf "\n";*)
				if !result = beta then (*(Printf.printf "Break with beta %d; Best steps are: \n" beta;
										List.iter print_step !best_steps;*) (beta,!best_steps)
				else (*(Printf.printf "Node's value is %d; Best steps are: \n" !v;
					List.iter print_step !best_steps;*) (!v,!best_steps)
			end)

		else
			(
			let result = ref max_int in
			let v = ref beta in
			let i = ref 0 in
			let best_steps = ref [] in
			begin match generate_all_moves b p (not ai_col) with
			(*begin match (generate_piece_move b p canB2) with*)
			| [] -> ((-depth_left) - min_int,[])
			| l ->
				List.iter (fun a -> if (in_bound a.start)&&(in_bound a.destination) then ()
					else print_step a) l;
				let sorted_l = List.sort compared l in
				let all_moves = Array.of_list sorted_l in

				while ((!i < (Array.length all_moves)) && (alpha <> !result))
				do
					(*Printf.printf "This is move: \n";
					print_step all_moves.(!i);*)

					let (updated_b,updated_prev) = update_unmutable all_moves.(!i) b p in
					let (score,new_best_steps) = alphaBeta alpha !v (depth_left - 1)
								updated_b updated_prev ai_col (not curr_rd) in
          (*
					Printf.printf "\nIts %d's child has score %d. Its best moves are: \n" !i score;
					List.iter print_step new_best_steps;
					Printf.printf "\nThe current alpha is %d; beta is %d\n" alpha !v;*)
          			let flag=ref false in
					(
					if (score < !v) then
						(v:= score;
						(*Printf.printf "Score is smaller than current beta. Beta is updated: %d\n" !v;*)
						best_steps:= all_moves.(!i)::new_best_steps;
						flag:=true
						(*Printf.printf "Now the best steps are: \n";
						List.iter print_step !best_steps*)
						)
					else if (score < alpha) then
						(*(Printf.printf "Score is less than alpha, impossible, break immediately\n";*)
						(result := alpha;
					  flag:=true)
					else ()(*(Printf.printf "Nothing happens\n"))*));
					(if (!flag=true) then
						let new_val=(Hashtbl.find nHistoryTable
						(all_moves.(!i).start,all_moves.(!i).destination))+(depth_left*depth_left)
						in
						(Hashtbl.replace nHistoryTable
						(all_moves.(!i).start,all_moves.(!i).destination)
					  new_val)

					else ());
					cnt := !cnt + 1;
					i:= !i+1
				done;
				(*print_int !cnt;Printf.printf "\n";*)
				if !result = alpha then (*
					(Printf.printf "Break with beta %d; Best steps are: \n" alpha;
										List.iter print_step !best_steps;*) (alpha,!best_steps)
				else (*(Printf.printf "Node's value is %d; Best steps are: \n" !v;
					List.iter print_step !best_steps; *)(!v,!best_steps)
			end)
		)


let rec alphaBeta2 (alpha:int) (beta:int) (depth_left:int)
	(b:board) (p:prev_step) (ai_col:bool) (curr_rd:bool): int*step list =

	Printf.printf "\nThe depth is:";
	print_int depth_left;
	if depth_left = 0 then (cnt := !cnt + 1; Printf.printf "I am at depth 0";print_int (eval_board b curr_rd); print_endline " ";
			print_int (eval_board b (not curr_rd)); print_endline " ";(*print_int !cnt; Printf.printf "\n"; *)((eval_board b curr_rd),[]))
	else if check_end_game b p then (cnt := !cnt + 1; (*print_int !cnt; Printf.printf "\n";*)((eval_board b curr_rd),[]))
	else
	(
			let result =
			(if ai_col = curr_rd then ref min_int
			else ref max_int)
			in
			let v = ref alpha in
			let i = ref 0 in
			let best_steps = ref [] in
			(*begin match (generate_all_moves b p curr_rd) with*)
			let h_e = 
			(if ai_col = curr_rd then (generate_piece_move b p canR1)
			else (generate_piece_move b p canB1)
				) in
			begin match h_e with
			| [] -> (depth_left - max_int,[])
			| l ->
				List.iter (fun a -> if (in_bound a.start)&&(in_bound a.destination) then ()
					else print_step a) l;
				(*
				let sorted_l = List.sort compared l in*)
				let all_moves = Array.of_list l in

				while ((!i < (Array.length all_moves)) && (beta <> !result))
				do

					let (updated_b,updated_prev) = update_unmutable all_moves.(!i) b p in
					let (neg_score,new_best_steps) = 
						(alphaBeta2 (-beta) (-(!v)) (depth_left - 1)
						updated_b updated_prev ai_col (not curr_rd)) in
					let score = (-neg_score) in
					
					Printf.printf "\nIts %d's child has score %d. Its best moves are: \n" !i score;
					List.iter print_step new_best_steps;
					Printf.printf "\nThe current alpha is %d; beta is %d\n" !v beta;
          			(*let flag=ref false in*)
					(if (score > !v) then
						(
						v:= score;
						Printf.printf "Score is greater than current alpha. Alpha is updated: %d\n" !v;
 						best_steps:= all_moves.(!i)::new_best_steps;
						(*flag:=true*)
						Printf.printf "Now the best steps are: \n";
						List.iter print_step !best_steps
						)
					else if (score > beta) then
						(Printf.printf "Score is greater than beta, impossible, break immediately\n";
						result := beta
					  (*flag:=true*)
					  )
					else (Printf.printf "Nothing happens\n")
					);
(*
					(if (!flag=true) then
						let new_val=(Hashtbl.find nHistoryTable
						(all_moves.(!i).start,all_moves.(!i).destination))+(depth_left*depth_left)
						in
						(Hashtbl.replace nHistoryTable
						(all_moves.(!i).start,all_moves.(!i).destination)
					  new_val)
          			else ());*)
					cnt := !cnt + 1;
					i:= !i+1
				done;
				(*print_int !cnt;Printf.printf "\n";*)
				if !result = beta then (Printf.printf "Break with beta %d; Best steps are: \n" beta;
										List.iter print_step !best_steps; (beta,!best_steps))
				else (Printf.printf "Node's value is %d; Best steps are: \n" !v;
					List.iter print_step !best_steps; (!v,!best_steps))
			end
)


let best_move_v0 (n:int) (b:board) (p:prev_step) (ai_col:bool): int*step list =
	(* need to modify the alpha beta to keep track of the optimum steps *)
	  (*let t=Unix.gettimeofday () in
		let result=ref (0, []) in
		let i=ref 1 in
		while ((Unix.gettimeofday () -. t)<=300.0 && !i<=n) do*)
			(*result:=*)(alphaBeta2 min_int max_int n b p ai_col ai_col)
			(*i:=!i+1
		done;
		
		!result*)

(*generate the best possible moves for the futural several steps
* int below is how many steps we predict for the future*)
let best_move (n:int) (b:board) (tran:transposition_table) (hist:history_table) : step list =
raise TODO

(*update the historical information*)
let update_AI (b:board) (s:step) (tran:transposition_table) (hist:history_table)
				: transposition_table * history_table =
  raise TODO

let easy_AI (b:board) (p:prev_step) (ai_col:bool): step =

  let (score,pred) = best_move_v0 2 b p ai_col in
  List.hd pred

let hard_AI (b:board) (p:prev_step) (ai_col:bool): step =
let res =
  let (score,pred) = best_move_v0 3 b p ai_col in
  List.hd pred
in let () = print_step res in res
