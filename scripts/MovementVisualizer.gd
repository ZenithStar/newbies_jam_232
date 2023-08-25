class_name MovementVisualizer extends CommandComponent

func _get_configuration_warnings():
	var output: String = ""
	if not get_parent() is CharacterBody2D:
		output += "This component depends on a CharacterBody2D parent. "
	if not get_parent().find_child("DirectMoveCommand"):
		output += "This component depends on a DirectMoveCommand sibling. "
	return output

@onready var controller: MovementController = get_parent().find_child("MovementController")
@onready var directMoveComand: DirectMoveCommand = get_parent().find_child("DirectMoveCommand")
var ghostCharacter:Node2D

func start():
	state = CommandComponentState.RUNNING
	ghostCharacter = Node2D.new()
	ghostCharacter.modulate = Color(1, 1, 1, 0.314)
	add_child(ghostCharacter)
	
	ghostCharacter.global_position = directMoveComand.ground_target
	
	for child in get_parent().get_children():
		if child is Node2D and not child is CollisionObject2D:
			ghostCharacter.add_child(child.duplicate(1))

func stop():
	state = CommandComponentState.INACTIVE
	for child in get_children():
		child.queue_free()

func _run(_delta):
	ghostCharacter.global_position = directMoveComand.ground_target

func _physics_process(delta):
	match [state,directMoveComand.state]:
		[CommandComponentState.INACTIVE,CommandComponentState.RUNNING]:
			start()
		[CommandComponentState.RUNNING,CommandComponentState.INACTIVE]:
			stop()
		[CommandComponentState.RUNNING,CommandComponentState.RUNNING]:
			_run(delta)

