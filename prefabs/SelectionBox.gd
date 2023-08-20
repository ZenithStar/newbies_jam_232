class_name SelectionBox extends Area2D

func _init():
	queue_redraw()
var pinned_corner = Vector2.ZERO
@onready var area = Vector2.ZERO
var corner: Vector2 = Vector2.ZERO:
	get:
		return corner
	set(value):
		corner = value
		area = corner - pinned_corner
		global_position = pinned_corner + ( area / 2 )
		$CollisionShape2D.shape.size = area.abs()
		queue_redraw()
@export var border_color: Color = Color.WHITE
@export var fill_color: Color = Color(Color.AQUA, 0.2)
func _draw():
	draw_rect(Rect2(-area/2, area), fill_color)
	draw_rect(Rect2(-area/2, area), border_color, false)
