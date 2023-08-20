class_name RTSController extends Camera2D

@export var scroll_speed: float = 400
func _ready():
	get_window().focus_entered.connect(enable)
	get_window().focus_exited.connect(disable)
	enable()
	PauseMenu.paused.connect(paused_handler)
func paused_handler(pause_state: bool):
	if pause_state:
		disable()
	else:
		enable()
func enable():
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
func disable():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
@export var zoom_speed: float = 2.0 ** (1.0 / 20.0)
@export var zoom_ease_duration = 0.25
@onready var zoom_setpoint: Vector2 = zoom:
	get:
		return zoom_setpoint
	set(value):
		zoom_setpoint = value
		create_tween().tween_property(self, "zoom", zoom_setpoint, zoom_ease_duration)
# apply zoom to the camera, keeping get_global_mouse_position() constant
func zoom_to_mouse(zoom_change: float):
	var old_offset = global_position - get_global_mouse_position()
	var new_offset = old_offset * zoom_change
	var offset_diff = old_offset - new_offset
	zoom_setpoint *= zoom_change
	global_position += offset_diff # Tweening position is unnecessary with position smoothing enabled

var selection_box_class: PackedScene = preload("res://prefabs/selection_box.tscn")
@onready var active_selection_box: SelectionBox = null
@onready var active_selection: Array[Node2D] = []:
	get:
		return active_selection
	set(new_value):
		for body in active_selection:
			if not body in new_value:
				var selectable: Selectable = body.find_child("Selectable")
				if selectable:
					selectable.selected = false
		for body in new_value:
			var selectable: Selectable = body.find_child("Selectable")
			if selectable:
				selectable.selected = true
		active_selection = new_value
@onready var unit_groups: Dictionary = {}
# LMB drag behavior
func init_selection_box(pinned_corner: Vector2 = get_global_mouse_position()):
	var box: SelectionBox = selection_box_class.instantiate()
	box.pinned_corner = pinned_corner 
	add_sibling(box)
	active_selection_box = box
func complete_selection():
	active_selection = active_selection_box.get_overlapping_bodies()
	active_selection_box.queue_free()
	active_selection_box = null
func _unhandled_input(event):
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				zoom_to_mouse(zoom_speed)
			MOUSE_BUTTON_WHEEL_DOWN:
				zoom_to_mouse(1.0/zoom_speed)
			MOUSE_BUTTON_LEFT:
				if event.pressed:
					init_selection_box(get_global_mouse_position())
				else:
					complete_selection()
				get_viewport().set_input_as_handled()
			MOUSE_BUTTON_RIGHT:
				if event.pressed:
					pass
				else:
					pass
	if event is InputEventMouseMotion:
		pass
func _process(delta):
	if get_window().has_focus() && Input.mouse_mode == Input.MOUSE_MODE_CONFINED:
		var mouse_position = get_viewport().get_mouse_position()
		var viewport_limits = get_viewport().size - Vector2i(1,1)
		if mouse_position.x == viewport_limits.x:
			position.x += scroll_speed * delta
		elif mouse_position.x == 0:
			position.x -= scroll_speed * delta
		if mouse_position.y == viewport_limits.y:
			position.y += scroll_speed * delta
		elif mouse_position.y == 0:
			position.y -= scroll_speed * delta
	if active_selection_box:
		active_selection_box.corner = get_global_mouse_position()
