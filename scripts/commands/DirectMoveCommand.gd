@tool
class_name DirectMoveCommand extends GroundedCommandComponent

func _get_configuration_warnings():
	if get_parent().find_child("MovementController"):
		return ""
	else:
		return "This component depends on a MovementController sibling"
@export var tolerance: float = 10.0
@onready var controller: MovementController = get_parent().find_child("MovementController")
func _run(_delta):
	var offset = ground_target - get_parent().global_position
	if offset.length() <= tolerance:
		controller.velocity_command = Vector2.ZERO
		state = CommandComponentState.INACTIVE
		result = CommandComponentResult.SUCCESS
	else:
		controller.velocity_command = offset.normalized()
