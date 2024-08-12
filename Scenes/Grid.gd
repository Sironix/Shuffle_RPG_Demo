extends Node2D

signal match_of_3(placement)
signal match_of_4(placement)
signal match_of_5(placement)
signal match_of_6(placement)
signal match_of_7(placement)
signal match_of_8(placement)


signal player_piece_swap_finished

#init vars
export(int) var width
export(int) var height
export(int) var x_start = 0
export(int) var y_start = 0
export(int) var offset

#posibles pieces currently being used
var references=[
	preload("res://Scenes/Monstruos/Blue Piece.tscn"),
	preload("res://Scenes/Monstruos/Green Piece.tscn"),
	preload("res://Scenes/Monstruos/Orange Piece.tscn"),
	preload("res://Scenes/Monstruos/Pink Piece.tscn"),
	preload("res://Scenes/Monstruos/Yellow Piece.tscn")
]

#current pieces in the scene
var pieces := []

#touch variables
var control_allowed := true
var touch_start := Vector2(-1,-1)
var touch_release := Vector2(-1,-1)
var piece_selected :=false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process(delta: float) -> void:
	touch_input()

############################################################################################
####  INIT LOGIC
############################################################################################

func create_grid_array() -> Array:
	var array = []
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null)
	return array

func array_to_grid(column:int=0,row:int=0) -> Vector2:
	var new_x = x_start + offset * column
	var new_y = y_start - offset * row
	return Vector2(new_x, new_y)

func grid_to_array(pos:Vector2=Vector2(0,0)) -> Vector2:
	var column:int = round(pos.x / offset)
	var row :int = round(pos.y / -offset)
	var grid_space : Vector2 = Vector2(column,row)
	return grid_space

func is_in_grid(grid_space:Vector2=Vector2(0,0)) -> bool:
	if grid_space.x >=0 and grid_space.x < width:
		if grid_space.y >=0 and grid_space.y < height:
			return true
	return false

func spawn_pieces() -> void:
	for i in width:
		for j in height:
			#choose random piece
			var rand = randi() % references.size()
			var piece = references[rand].instance()
			#loop counter to prevent issues
			var loops = 0
			while(is_match(i, j, piece.id) == true && loops < 100):
				rand = randi() % references.size()
				piece = references[rand].instance()
				loops += 1
			if loops ==100:
				print("limit at ",i,j)

			#instance it
			add_child(piece)
			piece._init(self)
			piece.position= array_to_grid(i,j)
			pieces[i][j] = piece

func is_match(column:int=0,row:int=0,id:String="") -> bool:
	var match_made = false
	if column > 1:
		if pieces[column - 1][row] != null && pieces[column - 2][row] != null:
			if pieces[column - 1][row].id == id && pieces[column -2][row].id == id:
				## later return the match vectors
				match_made = true
	if row > 1:
		if pieces[column][row - 1] != null && pieces[column][row - 2] != null:
			if pieces[column][row - 1].id == id && pieces[column][row - 2].id == id:
				## later return the match vectors
				match_made = true
	return match_made

##############################################################################################
#### MATCHING LOGIC
##############################################################################################

###find different types of matches
func find_all_matches():
	find_horizontal_match(8)
	find_vertical_match(8)

	find_horizontal_match(7)
	find_vertical_match(7)

	find_horizontal_match(6)
	find_vertical_match(6)

	find_horizontal_match(5)
	find_vertical_match(5)

	find_horizontal_match(4)
	find_vertical_match(4)

	find_horizontal_match(3)
	find_vertical_match(3)


func find_horizontal_match(_pieces_to_match:int=3):
	var pieces_to_match := _pieces_to_match
	if pieces_to_match > width:
		push_error("trying to find too big matches")
		pieces_to_match= width
	for i in width-(pieces_to_match-1):
		for j in height:
			##early return pattern
			if pieces[i][j] == null:
#				push_warning(str("pieza vacia",i,j))
				continue

			##piece already matched in a similar way so we skip it.
			elif pieces[i][j].matched_h == true:
#				push_warning(str("already matched H ",i,j))
				continue

#			elif pieces[i + 1][j] == null or pieces[i+2][j]== null:
##				push_warning(str("piezas a la derecha vacias",i,j))
#				continue

			##actual logic
			var matched_pieces = []
			for num in pieces_to_match:
				matched_pieces.append(pieces[i+num][j])
			if is_matching(matched_pieces) == false:
				matched_pieces = []

			else:
				for piece in matched_pieces:
					piece.matched_h = true
					piece.dim()
				match pieces_to_match:
					3:
						emit_signal("match_of_3",Vector2(i,j))
					4:
						emit_signal("match_of_4",Vector2(i,j))
					5:
						emit_signal("match_of_5",Vector2(i,j))
					6:
						emit_signal("match_of_6",Vector2(i,j))
					7:
						emit_signal("match_of_7",Vector2(i,j))
					8:
						emit_signal("match_of_8",Vector2(i,j))

				print("H match of ",pieces_to_match," at ",i,j)


func find_vertical_match(_pieces_to_match:int=3):
	var pieces_to_match := _pieces_to_match
	if pieces_to_match > height:
		push_error("trying to find too big matches")
		pieces_to_match= height
	for i in width:
		for j in height-(pieces_to_match-1):
			##early return pattern
			if pieces[i][j] == null:
#				push_warning(str("pieza vacia",i,j))
				continue

			##piece already matched in a similar way so we skip it.
			elif pieces[i][j].matched_v == true:
#				push_warning(str("already matched H ",i,j))
				continue

#			elif pieces[i + 1][j] == null or pieces[i+2][j]== null:
##				push_warning(str("piezas a la derecha vacias",i,j))
#				continue

			##actual logic
			var matched_pieces = []
			for num in pieces_to_match:
				matched_pieces.append(pieces[i][j+num])
			if is_matching(matched_pieces) == false:
				matched_pieces = []
			else:
				for piece in matched_pieces:
					piece.matched_v = true
					piece.dim()
				match pieces_to_match:
					3:
						emit_signal("match_of_3",Vector2(i,j))
					4:
						emit_signal("match_of_4",Vector2(i,j))
					5:
						emit_signal("match_of_5",Vector2(i,j))
					6:
						emit_signal("match_of_6",Vector2(i,j))
					7:
						emit_signal("match_of_7",Vector2(i,j))
					8:
						emit_signal("match_of_8",Vector2(i,j))
				print("V match of ",pieces_to_match," at ",i,j)


###checks if given array of pieces all have the same id
func is_matching(array_pieces:Array=[]):
	var pieces_to_match = array_pieces
	if pieces_to_match.size()== 0:
		return false
	print(pieces_to_match[0]," also ",pieces_to_match[0].id)
	var id = pieces_to_match[0].id
	var matching =true
	for piece in pieces_to_match.size():
		if pieces_to_match[piece].id != id:
			matching = false
	return matching

####
#mandar matches a un array o diccionario para guardarlos y computarlos.
#hacer los matches hacia la derecha y hacia abajo en vez de empezar desde el centro.
#para agilizar.
#agregar variable "matched_v" y "matched_h" para hacer que se saltee a esa pieza si ya hizo un match
#de ese tipo (tipo ya hizo un match 4 horizontal, entonces no se puede hacer otro match 3 horizontal
#con esa pieza.


################################################################################################
#######    INPUT
################################################################################################

func touch_input() -> void:
	if control_allowed == true:

		if Input.is_action_just_pressed("ui_touch"):
			var input_start_pos = get_local_mouse_position()
			var grid_start_pos = grid_to_array(input_start_pos)
			if  is_in_grid(grid_start_pos)== true:
				touch_start= grid_start_pos
				piece_selected = true
				print(touch_start)

		if Input.is_action_just_released("ui_touch") && piece_selected:
			var input_end_pos = get_local_mouse_position()
			var grid_end_pos = grid_to_array(input_end_pos)
			if  is_in_grid(grid_end_pos)== true and touch_start != grid_end_pos:
				touch_release= grid_end_pos
				##start the swapping
				swap_pieces(touch_start,touch_release)
				piece_selected = false
				print(touch_start,grid_end_pos)
				print(touch_release)
			else:
				piece_selected = false
				touch_release = Vector2(-1,-2)


func swap_pieces(piece_1, piece_2) -> void:
	control_allowed = false
	var first_piece = pieces[piece_1.x][piece_1.y]
	var second_piece = pieces[piece_2.x][piece_2.y]
	print(first_piece)
	var first_pos = first_piece.position
	var second_pos = second_piece.position
	pieces[piece_1.x][piece_1.y]= second_piece
	pieces[piece_2.x][piece_2.y]= first_piece
	first_piece.move(second_pos)
	second_piece.move(first_pos)
	### DEBUG
	find_all_matches()

func when_piece_movement_finished():
	if not control_allowed:
		control_allowed = true
