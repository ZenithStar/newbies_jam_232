class_name TargettedCommandComponent extends CommandComponent
var target: Node2D

func pass_data(value: Node2D):
	target = value
	
func start():
	state = CommandComponentState.RUNNING
