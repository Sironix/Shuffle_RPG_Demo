extends Node2D
class_name IMonstruo

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
	pass # Replace with function body.

func move(target_pos:Vector2=Vector2(0,0)) -> void:
	var move_tween= create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	move_tween.tween_property(self,"position",target_pos,0.5)
	#print(id)
	if GRID_REF:
		GRID_REF.emit_signal("player_piece_swap_finished")
		#print("finished moving")

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

