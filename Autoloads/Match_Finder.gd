extends Node

var grid_ref

#func is_matching():
#			var id_of_match = pieces[i][j].id
#			if pieces[i][j+1].id == id_of_match and pieces[i][j+2].id == id_of_match:
#				pieces[i][j].matched_v = true
#				pieces[i][j+1].matched_v = true
#				pieces[i][j+2].matched_v = true
#				pieces[i][j].dim()
#				pieces[i][j+1].dim()
#				pieces[i][j+2].dim()
#				emit_signal("match_of_3",Vector2(i,j))
#				print("match_at",i,j)

func is_matching(array_pieces):
	if array_pieces.size()== 0:
		return false

	var id = array_pieces[0].id
	var matching =true
	for piece in array_pieces:
		if piece.id != id:
			matching = false
	return matching

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

