class_name CommandComponent extends Node

enum CommandComponentState {
	RUNNING,
	INACTIVE
}
enum CommandComponentResult {
	SUCCESS,
	FAILURE
}
@export var affordance: bool = false ## If this is a command for acting upon this entity, rather than by this entity 
@onready var state: CommandComponentState = CommandComponentState.INACTIVE
@onready var result: CommandComponentResult = CommandComponentResult.SUCCESS

func start():
	state = CommandComponentState.RUNNING

func _run(delta):
	pass ## pure virtual

func stop():
	state = CommandComponentState.INACTIVE

func _physics_process(delta):
	match state:
		CommandComponentState.RUNNING:
			_run(delta)
