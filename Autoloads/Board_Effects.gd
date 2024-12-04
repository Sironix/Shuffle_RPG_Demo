extends Node

func destroy_cell(board_position:Vector2i) -> void:
	var avaliable = PosAdapter.find_avaliable_cell(board_position)
	var cell :IPiece
	if not avaliable:
		return
	cell = MatchFinder.get_cell_ref(avaliable)
	cell.match_animation()


func destroy_cells_around(board_position:Vector2i) -> void:
	for i in range(-1,2):
		for j in range(-1,2):
			if !j and !i:
				continue
			var avaliable = PosAdapter.find_avaliable_cell(board_position+Vector2i(i,j))
			var cell :IPiece
			if not avaliable:
				continue
			cell = MatchFinder.get_cell_ref(avaliable)
			if cell:
				cell.match_animation()

