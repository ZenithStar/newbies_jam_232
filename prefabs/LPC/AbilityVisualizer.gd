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
	get_parent().get_parent().get_parent().find_child("AbilityVisulizatonLayer").get_child(0).add_child(abilityVisualizationContainer)
	abilityVisualizationContainer.anchors_preset = VBoxContainer.PRESET_CENTER_TOP
	abilityVisualizationContainer.size = Vector2(80,32)
	abilityVisualizationContainer.position = Vector2(-40,16)
	
	abilityVisualizationContainer.add_child(Control.new())
	
	var colorRect:ColorRect = ColorRect.new()
	abilityVisualizationContainer.get_child(0).add_child(colorRect)
	colorRect.size = Vector2(98,110)
	
	var headOverlay:Sprite2D = get_parent().find_child("LPCSprite2D").duplicate(1)
	headOverlay.set_script(null)
	abilityVisualizationContainer.get_child(0).add_child(headOverlay)
	headOverlay.vframes = headOverlay.vframes*2
	headOverlay.frame_coords = Vector2i(0,20)
	headOverlay.position = Vector2(45,-51)
	headOverlay.scale = Vector2(3,3)
	
	for ability in abilityManager.managedAbilities:
		var abilityButton:Button = Button.new()
		abilityButton.text = ability.abilityName
		abilityVisualizationContainer.add_child(abilityButton)

func stop():
	state = CommandComponentState.INACTIVE
	abilityVisualizationContainer.queue_free()

func _run(_delta):
	for abilityButton in abilityVisualizationContainer.get_children():
		if abilityButton is Button:
			if abilityButton.button_pressed and Input.is_action_just_pressed("LeftMouseInput") :
				var abilityIndex = abilityVisualizationContainer.get_children().find(abilityButton)
				abilityManager.managedAbilities[abilityIndex-1].start()

func _physics_process(delta):
	match [state,selectable.selected]:
		[CommandComponentState.INACTIVE,true]:
			start()
		[CommandComponentState.RUNNING,false]:
			stop()
		[CommandComponentState.RUNNING,true]:
			_run(delta)
