class_name LPCSprite2D extends Sprite2D

@export var fps: float = 10.0
@onready var frame_time: float = 0.0
func process_frame_coord_y():
	match animation:
		AnimationState.STAND:
			frame_coords.y = direction_offset
		AnimationState.HURT:
			frame_coords.y = animation_offset * 4
		_:
			frame_coords.y = direction_offset + animation_offset * 4
@export var animation_offset: int = -1:
	get:
		return animation_offset
	set(value):
		if animation_offset != value:
			frame_time = 0.0
			animation_offset = value
			process_frame_coord_y()
enum AnimationState {
	CAST = 0,
	STAB = 1,
	WALK = 2,
	SLASH = 3,
	SHOOT = 4,
	HURT = 5,
	STAND = -1
}
@export var animation: AnimationState = AnimationState.STAND:
	get:
		return animation_offset as AnimationState
	set(value):
		animation_offset = value
@export var direction_offset: int = 2:
	get:
		return direction_offset
	set(value):
		direction_offset = value
		process_frame_coord_y()
enum DirectionState {
	UP = 0,
	LEFT = 1,
	DOWN = 2,
	RIGHT = 3
}
@export var direction: DirectionState = DirectionState.DOWN:
	get:
		return direction_offset as DirectionState
	set(value):
		direction_offset = value
var NUM_FRAMES: Dictionary = {
	AnimationState.CAST: 7,
	AnimationState.STAB: 8,
	AnimationState.WALK: 9,
	AnimationState.SLASH: 6,
	AnimationState.SHOOT: 13,
	AnimationState.HURT: 6,
	AnimationState.STAND: 1,
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
	else:
		if animation == AnimationState.WALK:
			animation = AnimationState.STAND

func _process(delta):
	var loop_duration = NUM_FRAMES[animation] / fps
	frame_time += delta
	frame_coords.x = int(frame_time * fps) % NUM_FRAMES[animation]
	frame_time = fmod(frame_time, loop_duration)
