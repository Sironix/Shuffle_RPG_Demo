extends Node2D
class_name Player


signal player_ready
signal player_died

signal player_atacked(amount:int,type)
signal player_spawned
signal player_restarted

signal player_turn(amount:int)
signal player_turn_tick()

signal inner_took_damage(amount:int)
signal took_damage(amount:int)

var initialized: bool = false
var turn_passed :int = 0

@export_category("Stats")

@export_group("Health")
@export var health :int = 1
@export var max_health :int = 100

func _ready() -> void:
	EventBus.attacked_the_player.connect(take_damage)

func take_damage(damage) -> void:
	inner_took_damage.emit(damage)


func die() -> void:
	print("the player died oh no!")
	restart()
	pass

func restart() -> void:
	pass
