class_name FogRevealComponent extends Node2D

@export var radius: float = 128.0
@export_range(0.0, 1.0) var intensity: float = 0.0
var maps: Array[RTSMap] = []
var gradient: GradientTexture2D
var light_image: Image
var light_rect: Rect2
var light_offset: Vector2

func compile_gradient():
	gradient = GradientTexture2D.new()
	gradient.gradient = Gradient.new()
	gradient.gradient.offsets[0] = intensity
	gradient.gradient.colors[0] = Color.WHITE
	gradient.gradient.colors[1] = Color.TRANSPARENT
	gradient.width = radius * 2
	gradient.height = radius * 2
	gradient.fill = GradientTexture2D.FILL_RADIAL
	gradient.fill_from = Vector2(0.5, 0.5)
	gradient.fill_to = Vector2(0.5, 0.0)
	
	_finish.call_deferred()

func _ready():
	compile_gradient()
	
func _finish():
	light_image = gradient.get_image()
	light_rect = Rect2(Vector2.ZERO, light_image.get_size())
	light_offset = -light_image.get_size()/2
	for map in get_tree().root.find_children("*","RTSMap",true,false):
		maps.append(map)
func _physics_process(delta):
	for map in maps:
		if map.fog_of_war:
			map.fog_image.blend_rect(light_image, light_rect,  global_position - map.fog_sprite.global_position + light_offset)
		
