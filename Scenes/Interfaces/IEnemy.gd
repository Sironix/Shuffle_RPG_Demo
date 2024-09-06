extends Node2D
class_name IEnemy

signal enemy_ready
signal enemy_died

signal enemy_atacked(amount:int,type)
signal enemy_spawned
signal enemy_restarted

signal enemy_turn(amount:int)
signal enemy_turn_tick()

signal inner_took_damage(amount:int)
signal took_damage(amount:int)

var initialized: bool = false
var turn_passed :int = 0

@export var Attack_Cooldown_Label: Label

@export_category("Stats")

@export_group("Health")
@export var health :int = 1
@export var max_health :int = 100

@export_group("Attack")
@export var cooldown: int =1
@export var cooldown_timer: int =1
@export var damage: int =0
@export_subgroup("Variance")
@export_range(-1,0,0.05) var dmg_var_min :float = 0
@export_range(0,1,0.05) var dmg_var_max :float = 0



func init(reference_to_grid:Node):
	if reference_to_grid:
		reference_to_grid.connect("player_turn_finished",activate_turn)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(0.2).timeout
	cooldown_timer = cooldown
	initialized=true



func activate_turn() -> void:
	if cooldown_timer <=0:
		attack()
	else:
		count_down_turn()
	update_atk_label()


func attack() -> void:
	print("I'm attacking!")
	cooldown_timer = cooldown
	pass

func count_down_turn() -> void:
	print(cooldown_timer, " turns till my next attack!")
	cooldown_timer -= 1

func restart() -> void:
	await get_tree().create_timer(0.5).timeout

	cooldown_timer = cooldown
	turn_passed = 0
	enemy_restarted.emit()

func die() -> void:
	print("I died oh no!")
	restart()
	pass

func update_atk_label():
	Attack_Cooldown_Label.text=str(cooldown_timer)

func take_damage(damage) -> void:
	inner_took_damage.emit(damage)
