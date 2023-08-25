@tool
class_name MovementController extends Node

func _get_configuration_warnings():
	if get_parent() is CharacterBody2D:
		return ""
	else:
		return "This component depends on a CharacterBody2D parent"

@export var max_linear_velocity: float = 100.0
@onready var velocity_command: Vector2 = Vector2.ZERO ## a vector with a maximum length of 1.0
@onready var velocity_reaction: Vector2 = Vector2.ZERO

func _physics_process(_delta):
	if get_parent() is CharacterBody2D:
		if velocity_command.length() > 1.0:
			velocity_command = velocity_command.normalized()
		get_parent().velocity = velocity_command * max_linear_velocity + velocity_reaction
		get_parent().move_and_slide()
