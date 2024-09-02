extends Move_Type

func _ready() -> void:
	name_set("Ascend Spawn")
	pass # Replace with function body.

func _init(parent_ref:IPiece) -> void:
	super._init(parent_ref)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func move(target_pos:Vector2=Vector2(0,0)) -> void:
	movement_start()
	parent.position = Vector2( target_pos.x,target_pos.y  + PosAdapter.offset * 1)
	parent.set_modulate(Color(1,1,1,0))
	var move_tween= parent.create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	move_tween.tween_property(parent,"position",target_pos,0.5)
	move_tween.parallel().tween_property(parent,"modulate",Color(1,1,1,1),0.5)

	super.move(target_pos)
