extends CanvasLayer

signal paused(bool)
func _ready():
	unpause()

func pause():
	visible = true
	get_tree().paused = true
	paused.emit(true)
	
func unpause():
	visible = false
	get_tree().paused = false
	paused.emit(false)

func _unhandled_input(event):
	if event.is_action("toggle_pause"):
		if event.is_pressed():
			if get_tree().paused:
				unpause()
			else:
				pause()

func _on_button_pressed():
	unpause()

func _on_volume_value_changed(value):
	var bus = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus, value-30.0 )
	if value <= 0:
		AudioServer.set_bus_mute(bus, true)
	else:
		AudioServer.set_bus_mute(bus, false)
		
