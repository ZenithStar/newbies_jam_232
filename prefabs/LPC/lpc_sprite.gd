@tool
class_name LPCSprite2D extends Sprite2D

@export var fps: float = 10.0
@onready var frame_time: float = 0.0
@export var current_frame: int = 0:
	get:
		return current_frame
	set(value):
		current_frame = value
		region_rect.position.x = current_frame * region_rect.size.x
var animation_player: AnimationPlayer
class LPCAnimation:
	var name: String
	var frames: int
	var loop: bool
	func _init(_name, _frames, _loop=false):
		name = _name
		frames = _frames
		loop = _loop
var animation_library_prefix:StringName = "lpc_sprite"
func _ready():
	region_enabled = true
	region_filter_clip_enabled = true
	calculate_available_animations()
	texture_changed.connect(calculate_available_animations)
	process_frame_coord()
	var player = AnimationPlayer.new()
	player.add_animation_library(animation_library_prefix,generate_animation_library())
	animation_player = player
	var old_player = find_child("AnimationPlayer")
	if old_player:
		old_player.queue_free()
	add_child.call_deferred(player)
var num_extra_animations: int = 0
func calculate_available_animations():
	if texture:
		num_extra_animations = ( texture.get_size().y - (21 * 64) ) / 4 / 128
	
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
			match value:
				AnimationState.STAND, AnimationState.EXTRA_STAND:
					animation = AnimationState.EXTRA_STAND if num_extra_animations >= 1 else AnimationState.STAND
				AnimationState.WALK, AnimationState.EXTRA_WALK:
					animation = AnimationState.EXTRA_WALK if num_extra_animations >= 1 else AnimationState.WALK
				AnimationState.STAB, AnimationState.SLASH, AnimationState.SHOOT:
					animation = AnimationState.EXTRA_ATTACK if num_extra_animations >= 2 else value
				_:
					animation = value
			process_frame_coord()
			if animation_player:
				if animation in animation_properties:
					animation_player.play(animation_library_prefix+"/"+animation_properties[animation].name)
				else:
					printerr(get_parent().name," animation set to invalid value: ", animation)
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
var animation_properties: Dictionary = {
	AnimationState.CAST: LPCAnimation.new("cast",7),
	AnimationState.STAB: LPCAnimation.new("stab",8),
	AnimationState.WALK: LPCAnimation.new("walk",9, true),
	AnimationState.SLASH: LPCAnimation.new("slash",6),
	AnimationState.SHOOT: LPCAnimation.new("shoot",13),
	AnimationState.HURT: LPCAnimation.new("hurt",6),
	AnimationState.STAND: LPCAnimation.new("stand",1),
	AnimationState.EXTRA_STAND: LPCAnimation.new("extra_stand",1),
	AnimationState.EXTRA_WALK: LPCAnimation.new("extra_walk",9, true),
	AnimationState.EXTRA_ATTACK: LPCAnimation.new("extra_attack",6),
}
func generate_animation_library() -> AnimationLibrary:
	var library = AnimationLibrary.new()
	for key in animation_properties:
		var ani = Animation.new()
		ani.loop_mode = Animation.LOOP_LINEAR if animation_properties[key].loop else Animation.LOOP_NONE
		ani.length = animation_properties[key].frames / fps
		ani.add_track(Animation.TYPE_VALUE)
		ani.track_set_path(0,NodePath(String(get_path())+":current_frame"))
		ani.track_insert_key(0,0.0,0)
		ani.track_insert_key(0,ani.length,animation_properties[key].frames)
		if not animation_properties[key].loop:
			ani.add_track(Animation.TYPE_VALUE)
			ani.track_set_path(1,NodePath(String(get_path())+":animation"))
			ani.track_insert_key(1,ani.length,animation_properties[key].frames)
		library.add_animation(animation_properties[key].name,ani)
	return library

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
