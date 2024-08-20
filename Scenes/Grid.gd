extends Node2D

signal match_of_3(placement)
signal match_of_4(placement)
signal match_of_5(placement)
signal match_of_6(placement)
signal match_of_7(placement)
signal match_of_8(placement)


signal player_piece_swap_finished

#State Machine
enum GRID_STATE {wait,move}
var state:GRID_STATE=GRID_STATE.move
#init vars
@export var width: int
@export var height: int
@export var x_start: int = 0
@export var y_start: int = 0
@export var offset: int

@onready var collapse_timer: Timer = $CollapseTimer
@onready var refill_timer: Timer = $RefillTimer
@onready var match_finder_timer: Timer = $MatchFinderTimer

#posibles pieces currently being used
var references=[
	preload("res://Scenes/Monstruos/Blue Piece.tscn"),
	preload("res://Scenes/Monstruos/Green Piece.tscn"),
	preload("res://Scenes/Monstruos/Orange Piece.tscn"),
	preload("res://Scenes/Monstruos/Pink Piece.tscn"),
	preload("res://Scenes/Monstruos/Yellow Piece.tscn")
]

#obstacle stuff
@export var empty_spaces:Array[Vector2]

#current pieces in the scene
var board := []

var matches_in_board:=[]

#touch variables
var control_allowed := true
var touch_start := Vector2(-1,-1)
var touch_release := Vector2(-1,-1)
var piece_selected :=false

# Called when the node enters the scene tree for the first time.
func _ready():
	board = create_board_array()
	spawn_pieces_without_matches()
	player_piece_swap_finished.connect(when_piece_movement_finished)
	state =GRID_STATE.move

func _process(delta: float) -> void:
	if state== GRID_STATE.move:
		touch_input()

####################################################################################################
####  INIT LOGIC
####################################################################################################

func create_board_array() -> Array:
	var array = []
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null)
	return array

func board_to_pixel(column:int=0,row:int=0) -> Vector2:
	var new_x = x_start + offset * column
	var new_y = y_start - offset * row
	return Vector2(new_x, new_y)

func pixel_to_board(pos:Vector2=Vector2(0,0)) -> Vector2:
	var column:int = round(pos.x / offset)
	var row :int = round(pos.y / -offset)
	var grid_space : Vector2 = Vector2(column,row)
	return grid_space

func is_in_grid(grid_space:Vector2=Vector2(0,0)) -> bool:
	if grid_space.x >=0 and grid_space.x < width:
		if grid_space.y >=0 and grid_space.y < height:
			return true
	return false

func spawn_pieces_without_matches() -> void:
	for i in width:
		for j in height:
			#if it is an obstacle, skip the current for loop
			if _is_obstacle(Vector2(i,j)):
				continue

			#choose random piece
			var rand = randi() % references.size()
			var piece = references[rand].instantiate()
			#loop counter to prevent issues
			var loops = 0
			while(_is_match(i, j, piece.id) == true && loops < 100):
				rand = randi() % references.size()
				piece = references[rand].instantiate()
				loops += 1
			if loops ==100:
				push_warning(str("limit at ",i,j))

			#instance it
			add_child(piece)
			piece._init(self)
			piece.position= board_to_pixel(i,j)
			board[i][j] = piece

##quick 3 match finder for the spawning funcion
func _is_match(column:int=0,row:int=0,id:String="") -> bool:
	var match_made = false
	if column > 1:
		if board[column - 1][row] != null && board[column - 2][row] != null:
			if board[column - 1][row].id == id && board[column -2][row].id == id:
				## later return the match vectors
				match_made = true
	if row > 1:
		if board[column][row - 1] != null && board[column][row - 2] != null:
			if board[column][row - 1].id == id && board[column][row - 2].id == id:
				## later return the match vectors
				match_made = true
	return match_made



func _is_obstacle(place:Vector2=Vector2(0,0)) -> bool:
	for index in empty_spaces.size():
		if empty_spaces[index] == place:
			return true
	return false



####################################################################################################
#### MATCHING LOGIC
####################################################################################################

###find different types of matches
func find_all_matches():
	collapse_timer.stop()
	var match_happened:=false
	if find_horizontal_match(8):
		match_happened=true
	if find_vertical_match(8):
		match_happened=true
	if find_horizontal_match(7):
		match_happened=true
	if find_vertical_match(7):
		match_happened=true
	if find_horizontal_match(6):
		match_happened=true
	if find_vertical_match(6):
		match_happened=true
	if find_horizontal_match(5):
		match_happened=true
	if find_vertical_match(5):
		match_happened=true
	if find_horizontal_match(4):
		match_happened=true
	if find_vertical_match(4):
		match_happened=true
	if find_horizontal_match(3):
		match_happened=true
	if find_vertical_match(3):
		match_happened=true

	if match_happened:
		collapse_timer.start()
	else:
		state = GRID_STATE.move

func find_horizontal_match(_pieces_to_match:int=3) -> bool:
	var pieces_to_match := _pieces_to_match
	var match_happened := false
	if pieces_to_match > width:
		push_error("trying to find matches bigger than the board.")
		pieces_to_match= width
	for i in width-(pieces_to_match-1):
		for j in height:
			##early return pattern
			if board[i][j] == null:

#				push_warning(str("pieza vacia",i,j))
				continue

			##piece already matched in a similar way so we skip it.
			elif board[i][j].matched_h == true:
#				push_warning(str("already matched H ",i,j))
				continue

			var null_pieces_in_match: bool = false
			for k in pieces_to_match:
				if board[i+k][j] == null:
					null_pieces_in_match = true
			if null_pieces_in_match:
				continue

			##actual logic
			var matched_pieces = []
			for num in pieces_to_match:
				if board[i+num] ==null:
					return match_happened
				matched_pieces.append(board[i+num][j])
			var match_results :Dictionary= is_matching(matched_pieces)
			if match_results.matched == false:
				matched_pieces = []
				continue
			var middle_piece :int= matched_pieces.size()/2
			print("Middle_piece indice ", middle_piece)
			var center_position :Vector2= pixel_to_board(matched_pieces[middle_piece].position)
			print("center at ",center_position)
			match_happened = true
			for piece in matched_pieces:
				piece.matched_h = true
				piece.match_animation()
			match pieces_to_match:
				3:
					emit_signal("match_of_3",center_position)
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

			print(match_results.id, " H match of ", pieces_to_match, " at ", center_position.x, " ", center_position.y)
	return match_happened

func find_vertical_match(_pieces_to_match:int=3) -> bool:
	var pieces_to_match := _pieces_to_match
	var match_happened := false
	if pieces_to_match > height:
		push_error("trying to find matches bigger than the board.")
		pieces_to_match= height
	for i in width:
		for j in height-(pieces_to_match-1):
			##early return pattern
			if board[i][j] == null:
#				push_warning(str("pieza vacia",i,j))
				continue

			##piece already matched in a similar way so we skip it.
			elif board[i][j].matched_v == true:
#				push_warning(str("already matched H ",i,j))
				continue

			var null_pieces_in_match: bool = false
			for k in pieces_to_match:
				if board[i][j+k] == null:
					null_pieces_in_match = true
			if null_pieces_in_match:
				continue

			##actual logic
			var matched_pieces = []
			for num in pieces_to_match:
				matched_pieces.append(board[i][j+num])
			var match_results :Dictionary= is_matching(matched_pieces)
			if match_results.matched == false:
				matched_pieces = []
				continue

			match_happened = true
			for piece in matched_pieces:
				piece.matched_v = true
				piece.match_animation()
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
			print(match_results.id, " V match of ", pieces_to_match, " at ", i, " ", j)
	return match_happened

###checks if given array of pieces all have the same id
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

func collapse_columns():
	refill_timer.stop()
	var activate_timer = false
	for row in width:
		for column in height:
			if board[row][column] != null:
				#skips the current for cycle
				continue
			#if it is an obstacle, skip the current for loop
			if _is_obstacle(Vector2(row,column)):
				continue

			if not activate_timer:
				activate_timer = true
			#finds the first non empty slot in the column down to up.
			for j in range(column +1 , height):
				if board[row][j] == null:
					#same
					continue

				board[row][j].move(board_to_pixel(row,column))
				board[row][column]= board[row][j]
				board[row][j]= null
				await get_tree().create_timer(0.01).timeout
				#once the first empty slot is dealed with, the loop breaks.
				break
		await get_tree().create_timer(0.02).timeout
	if activate_timer:
		refill_timer.start()
	else:
		state = GRID_STATE.move

func refill_board():
	match_finder_timer.stop()
	var activate_timer = false
	var y_offset :int = 2
	for row in width:
		for column in height:
			if board[row][column] !=null:
				continue

			#if it is an obstacle, skip the current for loop
			if _is_obstacle(Vector2(row,column)):
				continue

			if not activate_timer:
				activate_timer = true
			var rand = randi() % references.size()
			var piece :IMonstruo= references[rand].instantiate()
			add_child(piece)
			piece._init(self)
			piece.position= board_to_pixel(row,column + y_offset)
			piece.move(board_to_pixel(row,column))
			board[row][column] = piece
			await get_tree().create_timer(0.1).timeout
		await get_tree().create_timer(0.1).timeout
	if activate_timer:
		match_finder_timer.start()
	else:
		state = GRID_STATE.move


#TODO
#mandar matches a un array o diccionario para guardarlos y computarlos.



####################################################################################################
#######    INPUT
####################################################################################################

func touch_input() -> void:
	if control_allowed == false:
		return

	if Input.is_action_just_pressed("ui_touch"):
		var input_start_pos = get_local_mouse_position()
		var grid_start_pos = pixel_to_board(input_start_pos)
		if  is_in_grid(grid_start_pos) == false:
			return
		touch_start= grid_start_pos
		piece_selected = true

	if Input.is_action_just_released("ui_touch") && piece_selected:
		var input_end_pos = get_local_mouse_position()
		var grid_end_pos = pixel_to_board(input_end_pos)
		if not is_in_grid(grid_end_pos) or touch_start == grid_end_pos:
			piece_selected = false
			touch_release = Vector2(-1,-2)
			return
		touch_release= grid_end_pos
		##start the swapping
		swap_pieces(touch_start,touch_release)
		piece_selected = false




func swap_pieces(piece_1, piece_2) -> void:
	state = GRID_STATE.wait
	control_allowed = false
	var first_piece = board[piece_1.x][piece_1.y]
	var second_piece = board[piece_2.x][piece_2.y]
	var first_pos
	var second_pos
	if first_piece == null:
		return

	first_pos = first_piece.position
	if second_piece == null:
		second_pos= board_to_pixel(piece_2.x,piece_2.y)
	else:
		second_pos = second_piece.position
		second_piece.move(first_pos)

	board[piece_1.x][piece_1.y]= second_piece
	board[piece_2.x][piece_2.y]= first_piece
	first_piece.move(second_pos)
	### DEBUG
	match_finder_timer.start()


func when_piece_movement_finished():
	if not control_allowed:
		control_allowed = true

####################################################################################################
###TIMERS
####################################################################################################

func _on_collapse_timer_timeout() -> void:
	print("Collapse Timer Timeout")
	collapse_columns()


func _on_refill_timer_timeout() -> void:
	print("Refill Timer Timeout")
	refill_board()


func _on_match_finder_timer_timeout() -> void:
	print("Match Finder Timer Timeout")
	find_all_matches()

