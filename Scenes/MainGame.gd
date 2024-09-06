extends Control

@export var Grid_Ref:Node2D
@export var Enemy_Holder_Ref:IEnemy

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Enemy_Holder_Ref.init(Grid_Ref)
	Grid_Ref.attacked_the_enemy.connect(Enemy_Holder_Ref.take_damage)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
