class_name AbilityManager extends CommandComponent

var managedAbilities:Array[AbilityComponent] = []

func _get_configuration_warnings():
	if get_parent() is CharacterBody2D:
		pass
	else:
		return "This component depends on a CharacterBody2D parent"
	
