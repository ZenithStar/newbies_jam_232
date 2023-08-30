class_name Hittable extends Node


func _get_configuration_warnings():
	if get_parent() is CharacterBody2D:
		pass
	else:
		return "This component depends on a CharacterBody2D parent"

signal hit_taken

func hit(damage: float, knockback: Vector2):
	hit_taken.emit()
	var health_component: HealthComponent = get_parent().find_child("HealthComponent")
	var movement_controller: MovementController = get_parent().find_child("MovementController")
	if health_component:
		health_component.current_health -= damage
	if movement_controller:
		movement_controller.apply_reaction(knockback)
