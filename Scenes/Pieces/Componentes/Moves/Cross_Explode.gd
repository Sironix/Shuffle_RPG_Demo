extends Move_Type

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	name_set("Cross Explosion")
	pass # Replace with function body.

func _init(parent_ref:IPiece) -> void:
	super._init(parent_ref)
	parent_ref.horizontal_matched.connect(extra_effect)
	parent_ref.vertical_matched.connect(extra_effect)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#if parent.matched_special_type== parent.MATCH_TYPES.Cross:
	#pass

func move(target_pos:Vector2=Vector2(0,0)) -> void:
	movement_start()
	###Movement code here.
	var move_tween= parent.create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	move_tween.tween_property(parent,"position",target_pos,0.5)
	move_tween.parallel().tween_property(parent,"rotation_degrees",parent.rotation_degrees+180,0.5)
	await move_tween.finished
	super.move(target_pos)





func extra_effect(center:=false,size:=3) -> void:
	if center and parent.movements_active[parent.MOVE_TYPES.displaced]:
		print("CROSS EXPLOSION")
		var pos_in_board = PosAdapter.pixel_to_board(parent.position)
		#BoardEffects.destroy_cell(pos_in_board+Vector2i(0,1))
		BoardEffects.destroy_cells_around(pos_in_board)
