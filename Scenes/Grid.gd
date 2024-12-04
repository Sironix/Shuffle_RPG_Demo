extends Node2D
class_name Grid

signal match_of_3(placement:Vector2i)
signal match_of_4(placement:Vector2i)
signal match_of_5(placement:Vector2i)
signal match_of_6(placement:Vector2i)
signal match_of_7(placement:Vector2i)
signal match_of_8(placement:Vector2i)

signal player_turn_finished
signal player_piece_swap_finished

signal attacked_the_enemy(damage:int)
#State Machine
signal grid_state_changed(state:GRID_STATE)

enum GRID_STATE {busy,awaiting_input,spawning,matching,destroying,collapsing}
var state:GRID_STATE=GRID_STATE.busy :set = _set_state


func _set_state(value:GRID_STATE=GRID_STATE.busy):
	if value != null:
		state = value
		grid_state_changed.emit(state)
		if value == GRID_STATE.awaiting_input and initialized:
			player_turn_finished.emit()


#init vars
@export_group("Grid Info")
@export var width: int
@export var height: int
@export var x_start: int = 0
@export var y_start: int = 0
@export var offset: int

@onready var collapse_timer: Timer = $CollapseTimer
@onready var refill_timer: Timer = $RefillTimer
@onready var match_finder_timer: Timer = $MatchFinderTimer
var initialized :bool = false

#posibles pieces currently being used
var references=[
	preload("res://Scenes/Pieces/Blue Piece.tscn"),
	preload("res://Scenes/Pieces/Green Piece.tscn"),
	preload("res://Scenes/Pieces/Orange Piece.tscn"),
	preload("res://Scenes/Pieces/Pink Piece.tscn"),
	preload("res://Scenes/Pieces/Yellow Piece.tscn")
]

#obstacle stuff
@export_group("Empty Spaces")
@export var empty_spaces:Array[Vector2i]

#current pieces in the scene
var board := []

var matches_in_board:=[]

#touch variables
var control_allowed := true
var touch_start := Vector2i(-1,-1)
var touch_release := Vector2i(-1,-1)
var piece_selected :=false

# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().create_timer(2.5).timeout
	PosAdapter.x_start =x_start
	PosAdapter.y_start =y_start
	PosAdapter.offset = offset
	board = create_board_array()
	await spawn_pieces_without_matches()
	player_piece_swap_finished.connect(when_piece_movement_finished)
	state =GRID_STATE.awaiting_input
	initialized = true

func _process(delta: float) -> void:
	if state== GRID_STATE.awaiting_input:
		touch_input()

####################################################################################################
####  INIT LOGIC
####################################################################################################
#region Init

func create_board_array() -> Array:
	var array = []
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null)
	return array

func is_in_grid(grid_space:Vector2i=Vector2i(0,0)) -> bool:
	if grid_space.x >=0 and grid_space.x < width:
		if grid_space.y >=0 and grid_space.y < height:
			return true
	return false


## Used for the initial board setup.
func spawn_pieces_without_matches() -> void:
	for row in width:
		for column in height:
			#if it is an obstacle, skip the current for loop
			if MatchFinder._is_obstacle(Vector2i(row, column)):
				continue

			#choose random piece
			var rand = randi() % references.size()
			var piece = references[rand].instantiate()
			#loop counter to prevent issues
			var loops = 0
			while(_is_match(row, column, piece.id) == true && loops < 100):
				rand = randi() % references.size()
				piece = references[rand].instantiate()
				loops += 1
			if loops ==100:
				push_warning(str("limit at ",row, column))

			#instance it
			spawn_piece_to_board(piece,row,column)
			await get_tree().create_timer(0.1).timeout



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



#endregion


####################################################################################################
#### GAME LOOP
####################################################################################################
#region Game Loop
func spawn_piece_to_board(piece:IPiece=null,row:int=0,column:int=0) -> void:
	if piece:
		add_child(piece)
		piece._init(self)
		piece.spawn(PosAdapter.board_to_pixel(row,column))
		board[row][column] = piece


#this could probably be abstracted a bit to make it less ugly, but it works so be it.
func find_all_matches():
	collapse_timer.stop()
	var match_happened:=false
	if MatchFinder.find_horizontal_match(8):
		match_happened=true
	if MatchFinder.find_vertical_match(8):
		match_happened=true
	if MatchFinder.find_horizontal_match(7):
		match_happened=true
	if MatchFinder.find_vertical_match(7):
		match_happened=true
	if MatchFinder.find_horizontal_match(6):
		match_happened=true
	if MatchFinder.find_vertical_match(6):
		match_happened=true
	if MatchFinder.find_horizontal_match(5):
		match_happened=true
	if MatchFinder.find_vertical_match(5):
		match_happened=true
	if MatchFinder.find_horizontal_match(4):
		match_happened=true
	if MatchFinder.find_vertical_match(4):
		match_happened=true
	if MatchFinder.find_horizontal_match(3):
		match_happened=true
	if MatchFinder.find_vertical_match(3):
		match_happened=true

	if match_happened:
		collapse_timer.start()
	else:
		state = GRID_STATE.awaiting_input



func collapse_columns():
	refill_timer.stop()
	var activate_timer = false
	for row in width:
		for column in height:
			if board[row][column] != null:
				#skips the current for cycle
				continue
			#if it is an obstacle, skip the current for loop
			if MatchFinder._is_obstacle(Vector2i(row,column)):
				continue

			if not activate_timer:
				activate_timer = true
			#finds the first non empty slot in the column down to up.
			for j in range(column +1 , height):
				if board[row][j] == null:
					#same
					continue

				board[row][j].collapse(PosAdapter.board_to_pixel(row,column))
				board[row][column]= board[row][j]
				board[row][j]= null
				#await get_tree().create_timer(0.01).timeout
				#once the first empty slot is dealed with, the loop breaks.
				break
		#await get_tree().create_timer(0.02).timeout
	if activate_timer:
		state = GRID_STATE.spawning
		refill_timer.start()
	else:
		state = GRID_STATE.awaiting_input

func refill_board():
	match_finder_timer.stop()
	var activate_timer = false
	var y_offset :int = 2
	for row in width:
		for column in height:
			if board[row][column] !=null:
				continue

			#if it is an obstacle, skip the current for loop
			if MatchFinder._is_obstacle(Vector2i(row,column)):
				continue

			if not activate_timer:
				activate_timer = true
			var rand = randi() % references.size()
			var piece :IPiece= references[rand].instantiate()
			spawn_piece_to_board(piece,row,column)
			await get_tree().create_timer(0.1).timeout
		await get_tree().create_timer(0.1).timeout
	if activate_timer:
		state = GRID_STATE.matching
		match_finder_timer.start()
	else:
		state = GRID_STATE.awaiting_input




#TODO
#mandar matches a un array o diccionario para guardarlos y computarlos.


#endregion

####################################################################################################
#### HELPER FUNCTIONS
####################################################################################################
#region Helper Functions


#endregion


####################################################################################################
#######    INPUT
####################################################################################################
#region Input
func touch_input() -> void:
	if control_allowed == false:
		return

	if Input.is_action_just_pressed("ui_touch"):
		var input_start_pos = get_local_mouse_position()
		var grid_start_pos = PosAdapter.pixel_to_board(input_start_pos)
		#print(touch_start,"  ",input_start_pos)

		if  is_in_grid(grid_start_pos) == false:
			return
		if MatchFinder._is_obstacle(grid_start_pos):
			return
		touch_start= grid_start_pos
		piece_selected = true

	if Input.is_action_just_released("ui_touch") && piece_selected:
		var input_end_pos = get_local_mouse_position()
		var grid_end_pos = PosAdapter.pixel_to_board(input_end_pos)
		#print(touch_release,"  ",input_end_pos)
		if not is_in_grid(grid_end_pos) or touch_start == grid_end_pos or MatchFinder._is_obstacle(grid_end_pos):
			piece_selected = false
			touch_release = Vector2i(-1,-1)
			return
		touch_release= grid_end_pos

		##start the swapping
		swap_pieces(touch_start,touch_release)
		piece_selected = false


func swap_pieces(piece_1, piece_2) -> void:
	state = GRID_STATE.busy
	control_allowed = false
	var first_piece :IPiece= board[piece_1.x][piece_1.y]
	var second_piece :IPiece= board[piece_2.x][piece_2.y]
	var first_pos
	var second_pos
	if first_piece == null:
		return

	first_pos = first_piece.position
	if second_piece == null:
		second_pos= PosAdapter.board_to_pixel(piece_2.x,piece_2.y)
	else:
		second_pos = second_piece.position
		second_piece.displace(first_pos)

	board[piece_1.x][piece_1.y]= second_piece
	board[piece_2.x][piece_2.y]= first_piece
	first_piece.move(second_pos)
	state = GRID_STATE.matching
	match_finder_timer.start()


func when_piece_movement_finished():
	if not control_allowed:
		control_allowed = true


#endregion


####################################################################################################
###TIMERS
####################################################################################################
#region Timers



func _on_collapse_timer_timeout() -> void:
	print("Collapse Timer Timeout")
	collapse_columns()


func _on_refill_timer_timeout() -> void:
	print("Refill Timer Timeout")
	refill_board()


func _on_match_finder_timer_timeout() -> void:
	print("Match Finder Timer Timeout")
	find_all_matches()


#endregion
