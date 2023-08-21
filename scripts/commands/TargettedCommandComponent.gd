class_name TargettedCommandComponent extends CommandComponent
var target: Node2D
func start(value: Node2D):
	target = value
	state = CommandComponentState.RUNNING
