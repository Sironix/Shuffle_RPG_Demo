extends Node

var x_start: int = 0
var y_start: int = 0
var offset: int

func board_to_pixel(column:int=0,row:int=0) -> Vector2:
	var new_x = x_start + offset * column
	var new_y = y_start - offset * row
	return Vector2(new_x, new_y)

func pixel_to_board(pos:Vector2=Vector2(0,0)) -> Vector2:
	var column:int = round(pos.x / offset)
	var row :int = round(pos.y / -offset)
	var grid_space : Vector2 = Vector2(column,row)
	return grid_space
