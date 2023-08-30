class_name TargettedMeleeAttackCommand extends TargettedCommandComponent

var damage: float = 10.0
var knockback: float = 100.0
var delay: float = 0.5
var duration: float = 1.0

func start():
	var hittable: Hittable = target.find_child("Hittable")
	if hittable:
		super()
		var offset_direction: Vector2 = (target.global_position - get_parent().global_position).normalized()
		get_tree().create_timer(delay).timeout.connect(hittable.hit.bind(damage, offset_direction * knockback))
		get_tree().create_timer(duration).timeout.connect(stop)
