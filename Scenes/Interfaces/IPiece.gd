extends Node2D
class_name IPiece

signal vertical_matched(center:bool,size:int)
signal horizontal_matched(center:bool,size:int)
signal special_matched(center:bool,type:MATCH_TYPES)

##movement signals.
signal moved
signal displaced
signal spawned
signal matched
signal collapsed
signal destroyed


enum MOVE_TYPES{moved,displaced,spawned,matched,collapsed,destroyed}
enum MATCH_TYPES{None,Cross,L,Square}
@onready var destroy_timer: Timer = $Destroy_Timer

@export var id: String = "": get = id_get, set = id_set
@export var damage : int = 0
var icon
var matched_h := false
var matched_v := false
var matched_special := false
var matched_special_type = MATCH_TYPES.None
#the types of movements the piece did during the current turn.
var movements_active :Dictionary= {
	MOVE_TYPES.moved:false,
	MOVE_TYPES.displaced:false,
	MOVE_TYPES.spawned:false,
	MOVE_TYPES.matched:false,
	MOVE_TYPES.collapsed:false,
	MOVE_TYPES.destroyed:false
	}
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

func id_set(value:String) -> void:
	if value !=null and value != "":
		if id != "":
			push_error(str(id," trying to be changed to ", value))
		else:
			id = value

func id_get() -> String:
	return id

func _init(_GRID_REF=null) -> void:
	if _GRID_REF:
		GRID_REF = _GRID_REF
		GRID_REF.player_turn_finished.connect(on_player_turn_finish)

func _ready():
	vertical_matched.connect(match_3)
	horizontal_matched.connect(match_3)
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

func on_player_turn_finish() -> void:
	movements_active[MOVE_TYPES.spawned] = false
	movements_active[MOVE_TYPES.moved]= false
	movements_active[MOVE_TYPES.displaced]= false
	movements_active[MOVE_TYPES.collapsed] = false
	movements_active[MOVE_TYPES.matched]=false

func spawn(target_pos:Vector2=Vector2(0,0)) -> void:
	if not target_pos:
		push_error("Target position is null")
	spawn_type.move(target_pos)
	movements_active[MOVE_TYPES.spawned] = true

func move(target_pos:Vector2=Vector2(0,0)) -> void:
	if not target_pos:
		push_error("Target position is null")
	move_type.move(target_pos)
	movements_active[MOVE_TYPES.moved]= true


func displace(target_pos:Vector2=Vector2(0,0)) -> void:
	if not target_pos:
		push_error("Target position is null")
	displace_type.move(target_pos)
	movements_active[MOVE_TYPES.displaced]= true

#maybe an await or something.

func collapse(target_pos:Vector2=Vector2(0,0)) -> void:
	if not target_pos:
		push_error("Target position is null")
	collapse_type.move(target_pos)
	movements_active[MOVE_TYPES.collapsed] = true

func move_finish() -> void:
	if GRID_REF:
		GRID_REF.emit_signal("player_piece_swap_finished")

func destroy() -> void:
	destroy_type.destroy()
	movements_active[MOVE_TYPES.destroyed] = true


func inflict_damage(_damage:int=damage) -> void:
	print(_damage , "damage: IPiece line 109")
	GRID_REF.attacked_the_enemy.emit(_damage)
	pass

func check_connections() -> void:
	pass

func match_animation() -> void:
	dim()
	destroy_timer.start()

func dim() -> void:
	var dim_tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)
	dim_tween.tween_property(self,"modulate:a",0.3,0.4)
	dim_tween.tween_property(self,"modulate:a",1,0.2)


func _on_destroy_timer_timeout() -> void:
	if destroy_type:
		destroy_type.destroy()
	else:
		queue_free()



#TODO Abstract this shit into a match_type interface
func match_3(center:bool= false,amount:int=1):
	movements_active[MOVE_TYPES.matched]=true
	if center:
		inflict_damage(damage*amount)


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

