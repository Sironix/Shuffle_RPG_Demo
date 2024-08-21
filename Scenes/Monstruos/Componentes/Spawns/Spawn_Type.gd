extends Move_Type


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	name_set("Spawn")
	pass # Replace with function body.

func _init(parent_ref:IMonstruo) -> void:
	super._init(parent_ref)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func move(target_pos:Vector2=Vector2(0,0)) -> void:
	movement_start()
	parent.position = Vector2( target_pos.x,target_pos.y  - PosAdapter.offset * 4)
	var move_tween= parent.create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	move_tween.tween_property(parent,"position",target_pos,0.5)
	super.move(target_pos)
