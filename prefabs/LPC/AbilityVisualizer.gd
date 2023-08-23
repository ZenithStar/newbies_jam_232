class_name AbilityVisualizer extends CommandComponent

func _get_configuration_warnings():
	if get_parent() is CharacterBody2D:
		pass
	else:
		return "This component depends on a CharacterBody2D parent"
	
	if get_parent().find_child("AbilityManager"):
		pass
	else:
		return "This component depends on a AbilityManager sibling"

@onready var selectable:Selectable = get_parent().find_child("Selectable")
@onready var abilityManager:AbilityManager = get_parent().find_child("AbilityManager")
var abilityVisualizationContainer:VBoxContainer
func start():
	state = CommandComponentState.RUNNING
	
	abilityVisualizationContainer = VBoxContainer.new()
	get_parent().add_child(abilityVisualizationContainer)
	abilityVisualizationContainer.anchors_preset = VBoxContainer.PRESET_CENTER_TOP
	abilityVisualizationContainer.size = Vector2(80,32)
	abilityVisualizationContainer.position = Vector2(-40,16)
	
	
	for ability in abilityManager.managedAbilities:
		var abilityButton:Button = Button.new()
		abilityButton.text = ability.abilityName
		abilityVisualizationContainer.add_child(abilityButton)

func stop():
	state = CommandComponentState.INACTIVE
	abilityVisualizationContainer.queue_free()

func _run(_delta):
	for abilityButton in abilityVisualizationContainer.get_children():
		if abilityButton.button_pressed and InputEvent:
			var abilityIndex = abilityVisualizationContainer.get_children().find(abilityButton)
			abilityManager.managedAbilities[abilityIndex].start()

func _physics_process(delta):
	match [state,selectable.selected]:
		[CommandComponentState.INACTIVE,true]:
			start()
		[CommandComponentState.RUNNING,false]:
			stop()
		[CommandComponentState.RUNNING,true]:
			_run(delta)
