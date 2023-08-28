class_name SpeedUpAbility extends AbilityComponent

func _ready():
	get_parent().find_child("AbilityManager").managedAbilities.append(self)
	abilityName = " Speed  Up! "

@export var maxVelocityIncrease:float = 3
@onready var movementController : MovementController = get_parent().find_child("MovementController")
func start():
	state = CommandComponentState.RUNNING
	movementController.max_linear_velocity *= maxVelocityIncrease
	
	await get_tree().create_timer(2).timeout
	stop()

func stop():
	state = CommandComponentState.INACTIVE
	movementController.max_linear_velocity /= maxVelocityIncrease 

