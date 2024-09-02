extends Resource
class_name Move_Type
signal movement_started
signal movement_finished

### Probably add a new var to move() to know if the movement should activate extra effects or not.
var parent:IPiece

var Name: String= "" :set = name_set
func name_set(new_name: String) -> void:
	Name = new_name


func _init(parent_ref:IPiece) -> void:
	if parent_ref ==null:
		push_error("Parent is Null")
	parent = parent_ref
	movement_finished.connect(parent.move_finish)
	pass


func movement_start() -> void:
	movement_started.emit()


func move(target_pos:Vector2=Vector2(0,0)) -> void:
	movement_finished.emit()
