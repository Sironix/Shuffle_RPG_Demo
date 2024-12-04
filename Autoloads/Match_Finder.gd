extends Node

var grid_ref:Grid


###checks if given array of pieces all have the same id

func get_cell_ref(position:Vector2i=Vector2i(-99,99)) -> IPiece:
	if position == Vector2i(-99,99):
		push_error("position is null")
	if _is_obstacle(position):
		return null
	return grid_ref.board[position.x][position.y]

func _is_obstacle(place:Vector2i=Vector2i(0,0)) -> bool:
	for index in grid_ref.empty_spaces.size():
		var obstacle : Vector2i = grid_ref.empty_spaces[index]
		if grid_ref.empty_spaces[index] == place:
			return true
	return false

#region H/V Find Match Logic
## these two functions could be merged
func find_horizontal_match(_pieces_to_match:int=3) -> bool:
	var pieces_to_match := _pieces_to_match
	var match_happened := false
	if pieces_to_match > grid_ref.width:
		push_error("trying to find matches bigger than the board.")
		pieces_to_match= grid_ref.width
	for i in grid_ref.width-(pieces_to_match-1):
		for j in grid_ref.height:
			##early return pattern
			if grid_ref.board[i][j] == null:

#				push_warning(str("pieza vacia",i,j))
				continue

			##piece already matched in a similar way so we skip it.
			elif grid_ref.board[i][j].matched_h == true:
#				push_warning(str("already matched H ",i,j))
				continue

			var null_pieces_in_match: bool = false
			for k in pieces_to_match:
				if grid_ref.board[i+k][j] == null:
					null_pieces_in_match = true
			if null_pieces_in_match:
				continue

			##actual logic
			var matched_pieces :Array[IPiece]= []
			for num in pieces_to_match:
				if grid_ref.board[i+num] ==null:
					return match_happened
				matched_pieces.append(grid_ref.board[i+num][j])
			var match_results :Dictionary= is_matching(matched_pieces)
			if match_results.matched == false:
				matched_pieces = []
				continue
			var middle_piece :int= matched_pieces.size()/2
			var center_position :Vector2i= PosAdapter.pixel_to_board(matched_pieces[middle_piece].position)
			match_happened = true
			for piece in matched_pieces:
				piece.matched_h = true
				piece.match_animation()
				if piece == matched_pieces[middle_piece]:
					matched_pieces[middle_piece].horizontal_matched.emit(true,pieces_to_match)

				else:
					matched_pieces[middle_piece].horizontal_matched.emit(false,pieces_to_match)
			match pieces_to_match:
				3:
					grid_ref.emit_signal("match_of_3",center_position)
				4:
					grid_ref.emit_signal("match_of_4",Vector2i(i,j))
				5:
					grid_ref.emit_signal("match_of_5",Vector2i(i,j))
				6:
					grid_ref.emit_signal("match_of_6",Vector2i(i,j))
				7:
					grid_ref.emit_signal("match_of_7",Vector2i(i,j))
				8:
					grid_ref.emit_signal("match_of_8",Vector2i(i,j))

			print(match_results.id, " H match of ", pieces_to_match, " at ", center_position.x, " ", center_position.y)
	return match_happened

func find_vertical_match(_pieces_to_match:int=3) -> bool:
	var pieces_to_match := _pieces_to_match
	var match_happened := false
	if pieces_to_match > grid_ref.height:
		push_error("trying to find matches bigger than the board.")
		pieces_to_match= grid_ref.height
	for i in grid_ref.width:
		for j in grid_ref.height-(pieces_to_match-1):
			##early return pattern
			if grid_ref.board[i][j] == null:
#				push_warning(str("pieza vacia",i,j))
				continue

			##piece already matched in a similar way so we skip it.
			elif grid_ref.board[i][j].matched_v == true:
#				push_warning(str("already matched H ",i,j))
				continue

			var null_pieces_in_match: bool = false
			for k in pieces_to_match:
				if grid_ref.board[i][j+k] == null:
					null_pieces_in_match = true
			if null_pieces_in_match:
				continue

			##actual logic
			var matched_pieces = []
			for num in pieces_to_match:
				matched_pieces.append(grid_ref.board[i][j+num])
			var match_results :Dictionary= is_matching(matched_pieces)
			if match_results.matched == false:
				matched_pieces = []
				continue
			var middle_piece :int= matched_pieces.size()/2
			var center_position :Vector2i= PosAdapter.pixel_to_board(matched_pieces[middle_piece].position)
			match_happened = true
			for piece in matched_pieces:
				piece.matched_v = true
				piece.match_animation()
				if piece == matched_pieces[middle_piece]:
					matched_pieces[middle_piece].vertical_matched.emit(true,pieces_to_match)
				else:
					matched_pieces[middle_piece].vertical_matched.emit(false,pieces_to_match)

			match pieces_to_match:
				3:
					grid_ref.emit_signal("match_of_3",Vector2i(i,j))
				4:
					grid_ref.emit_signal("match_of_4",Vector2i(i,j))
				5:
					grid_ref.emit_signal("match_of_5",Vector2i(i,j))
				6:
					grid_ref.emit_signal("match_of_6",Vector2i(i,j))
				7:
					grid_ref.emit_signal("match_of_7",Vector2i(i,j))
				8:
					grid_ref.emit_signal("match_of_8",Vector2i(i,j))
			print(match_results.id, " V match of ", pieces_to_match, " at ", i, " ", j)
	return match_happened
#endregion

func is_matching(array_pieces:Array=[]):
	var pieces_to_match = array_pieces
	if pieces_to_match.size()== 0:
		return false
	var id = pieces_to_match[0].id
	var matching =true
	for piece in pieces_to_match.size():
		if pieces_to_match[piece] == null:
			return false
		if pieces_to_match[piece].id != id:
			matching = false
	return {"matched":matching,"id":id}
