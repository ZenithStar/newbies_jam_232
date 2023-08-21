class_name GroundedCommandComponent extends CommandComponent
var ground_target: Vector2
func start(value: Vector2):
	ground_target = value
	state = CommandComponentState.RUNNING
