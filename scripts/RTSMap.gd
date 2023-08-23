class_name RTSMap extends TileMap

@export var fog_of_war: bool = true
@export var fog_color: Color = Color(Color.BLACK, 0.8)
@export var limit_camera: bool = true
@export var world_boundary: bool = true

func create_world_boundary():
	var boundary = get_used_rect()
	var static_body = StaticBody2D.new()
	var collision_shape_right = CollisionShape2D.new()
	var world_boundary_right = WorldBoundaryShape2D.new()
	collision_shape_right.name = "WorldBoundaryRight"
	world_boundary_right.normal = Vector2.RIGHT
	world_boundary_right.distance = boundary.position.x * tile_set.tile_size.x
	collision_shape_right.shape = world_boundary_right
	var collision_shape_down = CollisionShape2D.new()
	var world_boundary_down = WorldBoundaryShape2D.new()
	collision_shape_down.name = "WorldBoundaryDown"
	world_boundary_down.normal = Vector2.DOWN
	world_boundary_down.distance = boundary.position.y * tile_set.tile_size.y
	collision_shape_down.shape = world_boundary_down
	var collision_shape_left = CollisionShape2D.new()
	var world_boundary_left = WorldBoundaryShape2D.new()
	collision_shape_left.name = "WorldBoundaryLeft"
	world_boundary_left.normal = Vector2.LEFT
	world_boundary_left.distance = -boundary.end.x * tile_set.tile_size.x
	collision_shape_left.shape = world_boundary_left
	var collision_shape_up = CollisionShape2D.new()
	var world_boundary_up = WorldBoundaryShape2D.new()
	collision_shape_up.name = "WorldBoundaryUp"
	world_boundary_up.normal = Vector2.UP
	world_boundary_up.distance = -boundary.end.y * tile_set.tile_size.y
	collision_shape_up.shape = world_boundary_up
	static_body.add_child(collision_shape_right)
	static_body.add_child(collision_shape_down)
	static_body.add_child(collision_shape_left)
	static_body.add_child(collision_shape_up)
	static_body.name = "WorldBoundary"
	add_child(static_body)

@onready var fog_image: Image
@onready var fog_sprite: Sprite2D
func create_fog():
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 2
	canvas_layer.follow_viewport_enabled = true
	fog_sprite = Sprite2D.new()
	fog_sprite.name = "FogOfWar"
	fog_sprite.centered = false
	fog_sprite.position = Vector2(get_used_rect().position * tile_set.tile_size)
	var image_size = get_used_rect().size * tile_set.tile_size
	fog_image = Image.create(image_size.x, image_size.y, false, Image.FORMAT_RGBA8)
	fog_image.fill(fog_color)
	var image_texture = ImageTexture.create_from_image(fog_image)
	fog_sprite.texture = image_texture
	canvas_layer.add_child(fog_sprite)
	add_child(canvas_layer)

func limit_camera_to_map():
	var cameras = $"..".find_children("*","Camera2D", false)
	var boundary = get_used_rect()
	for camera in cameras:
		camera.limit_left = boundary.position.x * tile_set.tile_size.x
		camera.limit_top = boundary.position.y * tile_set.tile_size.y
		camera.limit_right = boundary.end.x * tile_set.tile_size.x
		camera.limit_bottom = boundary.end.y * tile_set.tile_size.y
		camera.limit_smoothed = true

func _ready():
	if world_boundary:
		create_world_boundary()
	if fog_of_war:
		create_fog()
	if limit_camera:
		var cameras = $"..".find_children("*","Camera2D", false)
		var boundary = get_used_rect()
		for camera in cameras:
			camera.limit_left = boundary.position.x * tile_set.tile_size.x
			camera.limit_top = boundary.position.y * tile_set.tile_size.y
			camera.limit_right = boundary.end.x * tile_set.tile_size.x
			camera.limit_bottom = boundary.end.y * tile_set.tile_size.y
			camera.limit_smoothed = true

func _process(delta):
	if fog_of_war:
		fog_sprite.texture = ImageTexture.create_from_image(fog_image)
		
