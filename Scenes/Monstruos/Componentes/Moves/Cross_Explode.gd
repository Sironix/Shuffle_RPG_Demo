extends Move_Type

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	name_set("Cross Explosion")
	pass # Replace with function body.

func _init(parent_ref:IPiece) -> void:
	super._init(parent_ref)
	parent_ref.horizontal_matched.connect(extra_effect)

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
	print("CROSS EXPLOSION")
	super.move(target_pos)


func extra_effect(center:=true,size:=3) -> void:
	if center:
		print("I'm gonna explode!!")
