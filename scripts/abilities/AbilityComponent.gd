class_name AbilityComponent extends CommandComponent

var abilityName = "Base Ability"

func _get_configuration_warnings():
	if get_parent() is CharacterBody2D:
		pass
	else:
		return "This component depends on a CharacterBody2D parent"
	
	if get_parent().find_child("AbilityManager"):
		pass
	else:
		return "This component depends on a AbilityManager sibling"

# Called when the node enters the scene tree for the first time.
func _ready():
	get_parent().find_child("AbilityManager").managedAbilities.append(self)

func start():
	state = CommandComponentState.RUNNING
	print("Ability Used!")
	stop()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
