extends Node

var x_start: int = 0
var y_start: int = 0
var offset: int

func board_to_pixel(column:int=0,row:int=0) -> Vector2i:
	var new_x = x_start + offset * column
	var new_y = y_start - offset * row
	return Vector2i(new_x, new_y)

func pixel_to_board(pos:Vector2i=Vector2i(0,0)) -> Vector2i:
	var column:int = round((pos.x+ offset/2 ) / offset)
	var row :int = round((pos.y - offset/2 )/ -offset)
	var grid_space : Vector2i = Vector2i(column,row)
	return grid_space
