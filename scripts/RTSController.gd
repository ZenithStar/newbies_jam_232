class_name RTSController extends Camera2D

@export var scroll_speed: float = 400
func _ready():
	get_window().focus_exited.connect(PauseMenu.pause)
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



@export_category("Zoom")
@export var zoom_speed: float = 2.0 ** (1.0 / 20.0)
@export var zoom_ease_duration = 0.25
@export var zoom_clamp_min: float = 1.0/3.0
@export var zoom_clamp_max: float = 3.0
@onready var zoom_setpoint: Vector2 = zoom:
	get:
		return zoom_setpoint
	set(value):
		zoom_setpoint = value
		create_tween().tween_property(self, "zoom", zoom_setpoint, zoom_ease_duration)
# apply zoom to the camera, keeping get_global_mouse_position() constant
func zoom_to_mouse(zoom_change: float):
	var old_offset = global_position - get_global_mouse_position()
	var old_zoom = zoom_setpoint
	zoom_setpoint *= zoom_change
	zoom_setpoint = zoom_setpoint.clamp(Vector2.ONE * zoom_clamp_min, Vector2.ONE * zoom_clamp_max)
	var new_offset = old_offset * zoom_setpoint / old_zoom
	var offset_diff = old_offset - new_offset
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
	calculate_formation()
@onready var formation: Dictionary = {}
enum Formation {
	USE_CURRENT,
	CIRCLE,
	LINE,
	HEX_FILL
}
@export var formation_style: Formation = Formation.CIRCLE
@export var formation_unit_seperation: float = 50.0
func calculate_formation():
	formation = {}
	if active_selection.size() == 0: return
	var center: Vector2 = selection_center(active_selection)
	
	match formation_style:
		Formation.USE_CURRENT:
			for body in active_selection:
				formation[body] = body.global_position - center
		
		Formation.CIRCLE:
			var circleSize = active_selection.size() * 13
			var offsetPerBody = 360 / active_selection.size()
			var offsetFromCenter = Vector2.UP * circleSize 
			for body in active_selection:
				formation[body] = offsetFromCenter #body.global_position - (center )
				offsetFromCenter = offsetFromCenter.rotated(deg_to_rad(offsetPerBody))
			
			
		
		Formation.LINE: # TODO
			pass

func selection_center(unit_selection:Array[Node2D])->Vector2:
	var selectionCenter:Vector2 = Vector2.ZERO
	for body in unit_selection:
		selectionCenter += body.global_position
	selectionCenter /= unit_selection.size()
	
	return selectionCenter


@onready var active_command: String = ""

func placeholder_rmb_behavior():
	for body in formation:
		var command: DirectMoveCommand = body.find_child("DirectMoveCommand")
		if command:
			command.pass_data(get_global_mouse_position()+formation[body])
			command.start()


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
					if active_selection_box:
						complete_selection()
				get_viewport().set_input_as_handled()
			MOUSE_BUTTON_RIGHT:
				if event.pressed:
					placeholder_rmb_behavior()
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
