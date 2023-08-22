class_name HealthComponent extends Node

@export var max_health: float = 100.0
signal changed
@export var current_health: float = max_health:
	get:
		return current_health
	set(value):
		current_health = value
		changed.emit()
