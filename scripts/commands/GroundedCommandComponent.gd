class_name GroundedCommandComponent extends CommandComponent
var ground_target: Vector2

func pass_data(value: Vector2):
	ground_target = value

func start():
	state = CommandComponentState.RUNNING
