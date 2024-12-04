extends Resource
class_name Destroy_Type

var Name: String= "" :set = name_set
func name_set(new_name: String) -> void:
	Name = new_name

var parent:IPiece

func _init(parent_ref:IPiece) -> void:
	if parent_ref ==null:
		push_error("Parent is Null")
	parent = parent_ref


func _ready() -> void:
	name_set("Destroy_Type")
	pass # Replace with function body.

func destroy() -> void:
	#var destroy_tween= parent.create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	#destroy_tween.tween_property(parent,"rotation_degrees",parent.rotation_degrees+480,0.5)
	#await destroy_tween.finished
	parent.queue_free()
