extends Node

var x_start: int = 0
var y_start: int = 0
var offset: int
var grid_ref

func board_to_pixel(column:int=0,row:int=0) -> Vector2i:
	var new_x = x_start + offset * column
	var new_y = y_start - offset * row
	return Vector2i(new_x, new_y)

func pixel_to_board(pos:Vector2i=Vector2i(0,0)) -> Vector2i:
	var column:int = round((pos.x+ offset/2 ) / offset)
	var row :int = round((pos.y - offset/2 )/ -offset)
	var grid_space : Vector2i = Vector2i(column,row)
	return grid_space

#Fix hardcoded values for grid size should be imported from outside.
var columns:int = 8
var rows: int=8


func find_avaliable_cell(origin_point:Vector2i,movement_from_origin:Vector2i=Vector2i(0,0)):
	var final_position := origin_point + movement_from_origin
	if final_position.x > rows-1 or final_position.x < 0:
		return false
	if final_position.y > columns-1 or final_position.y < 0:
		return false
	return final_position

func get_cell_ref(position:Vector2i) -> IPiece:
	return grid_ref.get_cell_ref(position)
