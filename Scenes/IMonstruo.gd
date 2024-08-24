extends Node2D
class_name IMonstruo

signal vertical_matched(center:bool,size:int)
signal horizontal_matched(center:bool,size:int)
signal special_matched(center:bool,type:MATCH_TYPES)

enum MATCH_TYPES{None,Cross,L,Square}
@onready var destroy_timer: Timer = $Destroy_Timer

@export var id: String = "": get = id_get, set = id_set
var damage : int = 0
var icon
var matched_h := false
var matched_v := false
var matched_special := false
var matched_special_type = MATCH_TYPES.None
var GRID_REF

@export_category("movement")
@export var _move_type:GDScript
var move_type:Move_Type
@export var _displace_type:GDScript
var displace_type:Move_Type
@export var _collapse_type:GDScript
var collapse_type:Move_Type
@export var _spawn_type:GDScript
var spawn_type:Move_Type
@export var _destroy_type:GDScript
var destroy_type:Destroy_Type

func id_set(value:String):
	if value !=null and value != "":
		if id != "":
			push_error(str(id," trying to be changed to ", value))
		else:
			id = value

func id_get():
	return id

func _init(_GRID_REF=null):
	GRID_REF = _GRID_REF

func _ready():
	if _move_type:
		move_type = _move_type.new(self)

	if _displace_type:
		displace_type = _displace_type.new(self)
	elif _move_type:
		displace_type = _move_type.new(self)

	if _collapse_type:
		collapse_type = _collapse_type.new(self)
	elif _move_type:
		collapse_type = _move_type.new(self)

	if _spawn_type:
		spawn_type = _spawn_type.new(self)
	elif _move_type:
		spawn_type = _move_type.new(self)

	if _destroy_type:
		destroy_type = _destroy_type.new(self)

#I should make this an interface. like "Imove"
#have the move version (triggers when you pick this piece and move it somewhere
#have the displace version (triggers when this piece is the 2nd piece in a piece swap input
#have the collapse version (triggers with the collapse columns function.

func spawn(target_pos:Vector2=Vector2(0,0)) -> void:
	if not target_pos:
		push_error("Target position is null")
	spawn_type.move(target_pos)

func move(target_pos:Vector2=Vector2(0,0)) -> void:
	if not target_pos:
		push_error("Target position is null")
	move_type.move(target_pos)

func displace(target_pos:Vector2=Vector2(0,0)) -> void:
	if not target_pos:
		push_error("Target position is null")
	displace_type.move(target_pos)

func collapse(target_pos:Vector2=Vector2(0,0)) -> void:
	if not target_pos:
		push_error("Target position is null")
	collapse_type.move(target_pos)

func move_finish() -> void:
	if GRID_REF:
		GRID_REF.emit_signal("player_piece_swap_finished")

func destroy(target_pos:Vector2=Vector2(0,0)) -> void:
	if not target_pos:
		push_error("Target position is null")
	destroy_type.move(target_pos)

func inflict_damage():
	print(damage)
	pass

func check_connections():
	pass

func match_animation():
	dim()
	destroy_timer.start()

func dim():
	var dim_tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)
	dim_tween.tween_property(self,"modulate:a",0.3,0.4)
	dim_tween.tween_property(self,"modulate:a",1,0.2)

func _on_destroy_timer_timeout() -> void:
	if destroy_type:
		destroy_type.destroy()
	else:
		queue_free()


func match_3():
	pass

func match_4():
	pass

func match_5():
	pass

func match_6():
	pass

func match_7():
	pass

func match_8():
	pass

func match_special():
	pass

