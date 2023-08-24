class_name FogOfWar extends Node2D

@export var size = Vector2.ZERO
@onready var textures: Dictionary = {}
@onready var fog_image: Image
@onready var base_texture: ImageTexture
var invert_material = preload("res://shaders/material_canvas_item_invert.tres")
func _ready():
	fog_image = Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	base_texture = ImageTexture.create_from_image(fog_image)
	material = invert_material
	
func append(node: Node2D, value: Texture2D):
	textures[node] = value
func _draw():
	for node in textures:
		var light_image = textures[node].get_image()
		var light_rect = Rect2(Vector2.ZERO, light_image.get_size())
		fog_image.blend_rect(light_image, light_rect,  node.global_position - global_position)
	base_texture = ImageTexture.create_from_image(fog_image)
	draw_texture(base_texture, Vector2.ZERO)
		
func _process(_delta):
	queue_redraw()
