extends Node
class_name Health_Component

signal health_empty
signal health_updated(value:int)
signal health_full
signal health_over_max


@export var debug_mode :bool = false
var initalized :bool = false
@export var health_bar :ProgressBar

var max_health :int
var health :int
var regen :Dictionary ={"flat" :0,"porcentile" :0}
#input needs inner_took_damage event. activates the take damage method
@export var input_connection:Node
#output needs health,max_health variables and die method and took_damage & restart event.
@export var output_connection:Node

func _ready() -> void:
	await get_tree().create_timer(1).timeout
	initialize()

func initialize() -> void:
	if output_connection and input_connection:
		input_connection.inner_took_damage.connect(take_damage)
		if output_connection.has_method("die"):
			health_empty.connect(output_connection.die)
		else:
			push_error("object ",output_connection.name,"doesn't have the die function.")
		if "max_health" in output_connection:
			max_health = output_connection.max_health
		else:
			push_error("object ",output_connection.name,"doesn't have the max_health variable.")
		if "health" in output_connection:
			health = output_connection.health
		else:
			push_error("object ",output_connection.name,"doesn't have the health variable.")
	if output_connection is IEnemy:
		output_connection.enemy_restarted.connect(full_heal)

	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = health
		health_updated.connect(update_bar_value)

	initalized = true


func update_bar_value(value) -> void:
	print(value," Health Component line 53")
	if health_bar:
		health_bar.value = value

func activate_regen() -> void:
	if regen["porcentile"] >0:
		heal(regen["porcentile"] * max_health)
	if regen["flat"]:
		heal(regen["flat"])

func over_heal(amount:int=0)-> void:
	if amount > 0:
		health = health + amount
		health_updated.emit(health)

func heal(amount:int=0) -> void:
	if amount > 0:
		health = min(health + amount, max_health)
		health_updated.emit(health)

func full_heal() -> void:
	health = max_health
	health_updated.emit(health)

func take_damage(amount:int=0) -> void:
	if amount > 0:
		health = health - amount
		health_updated.emit(health)
		if health <= 0:
			health_empty.emit()
		if output_connection:
			output_connection.took_damage.emit(amount)
