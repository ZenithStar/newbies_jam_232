@tool
class_name LPCSprite2D extends Sprite2D

@export var fps: float = 10.0
@onready var frame_time: float = 0.0
@export var current_frame: int = 0
@onready var num_extra_animations: int = 0 ## The number extra sets of 128x128px animations

func _ready():
	region_enabled = true
	region_filter_clip_enabled = true
	texture_changed.connect(process_texture_dimensions)
	process_texture_dimensions()
	process_frame_coord()
	
func process_texture_dimensions():
	if texture:
		num_extra_animations = ((texture.get_size().x / 64) - 21 ) / 2
func process_frame_dimensions():
	if animation >= AnimationState.EXTRA_WALK:
		pass
func process_frame_coord():
	match animation:
		AnimationState.EXTRA_WALK, AnimationState.EXTRA_ATTACK:
			region_rect.size = Vector2i(128,128)
			region_rect.position.y = 21*64 + (animation - AnimationState.EXTRA_WALK)*4*128 + direction*128
		AnimationState.EXTRA_STAND:
			region_rect.size = Vector2i(128,128)
			region_rect.position.y = 21*64 + direction*128
		AnimationState.STAND:
			region_rect.size = Vector2i(64,64)
			region_rect.position.y = direction*64
		AnimationState.HURT:
			region_rect.size = Vector2i(64,64)
			region_rect.position.y = animation*64 * 4
		_:
			region_rect.size = Vector2i(64,64)
			region_rect.position.y = direction*64 + animation*64 * 4


enum AnimationState {
	CAST = 0,
	STAB = 1,
	WALK = 2,
	SLASH = 3,
	SHOOT = 4,
	HURT = 5,
	EXTRA_WALK = 6,
	EXTRA_ATTACK = 7,
	STAND = -1,
	EXTRA_STAND = -2
}
@export var animation: AnimationState = AnimationState.STAND:
	get:
		return animation
	set(value):
		if animation != value:
			frame_time = 0.0
			animation = value
			process_frame_coord()
enum DirectionState {
	UP = 0,
	LEFT = 1,
	DOWN = 2,
	RIGHT = 3
}
@export var direction: DirectionState = DirectionState.DOWN:
	get:
		return direction
	set(value):
		direction = value
		process_frame_coord()
var NUM_FRAMES: Dictionary = {
	AnimationState.CAST: 7,
	AnimationState.STAB: 8,
	AnimationState.WALK: 9,
	AnimationState.SLASH: 6,
	AnimationState.SHOOT: 13,
	AnimationState.HURT: 6,
	AnimationState.STAND: 1,
	AnimationState.EXTRA_STAND: 1,
	AnimationState.EXTRA_WALK: 9,
	AnimationState.EXTRA_ATTACK: 6,
}

func _physics_process(_delta):
	var this_velocity = $"..".get_real_velocity()
	if this_velocity.length() > 0:
		var angle = atan2(this_velocity.y, this_velocity.x)
		if abs(angle) < PI/4:
			direction = DirectionState.RIGHT
		elif abs(angle) > PI*3/4:
			direction = DirectionState.LEFT
		elif angle > 0:
			direction = DirectionState.DOWN
		else:
			direction = DirectionState.UP
		if animation == AnimationState.STAND:
			animation = AnimationState.WALK
		elif animation == AnimationState.EXTRA_STAND:
			animation = AnimationState.EXTRA_WALK
	else:
		if animation == AnimationState.WALK:
			animation = AnimationState.STAND
		elif animation == AnimationState.EXTRA_WALK:
			animation = AnimationState.EXTRA_STAND

func _process(delta):
	var loop_duration = NUM_FRAMES[animation] / fps
	frame_time += delta
	region_rect.position.x = (int(frame_time * fps) % NUM_FRAMES[animation]) * region_rect.size.x
	frame_time = fmod(frame_time, loop_duration)
