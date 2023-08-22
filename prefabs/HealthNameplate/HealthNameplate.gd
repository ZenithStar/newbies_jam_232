@tool
class_name HealthPlate extends ProgressBar

func _get_configuration_warnings():
	if get_parent().find_child("HealthComponent"):
		return ""
	else:
		return "This component depends on a HealthComponent sibling"
@onready var health_component: HealthComponent = get_parent().find_child("HealthComponent")
func _ready():
	health_component.changed.connect(update)
	visible = false
func update():
	max_value = health_component.max_health
	value = health_component.current_health
	visible = value < max_value
