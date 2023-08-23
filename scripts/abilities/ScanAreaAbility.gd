class_name ScanAreaAbility extends AbilityComponent

func _ready():
	get_parent().find_child("AbilityManager").managedAbilities.append(self)
	abilityName = " Scan  Area "

@export var radiusIncrease:int = 128
@onready var fogRevealComponent : FogRevealComponent = get_parent().find_child("FogRevealComponent")
func start():
	state = CommandComponentState.RUNNING
	fogRevealComponent.radius += radiusIncrease
	fogRevealComponent.recompile()
	
	await get_tree().create_timer(1).timeout
	stop()

func stop():
	state = CommandComponentState.INACTIVE
	fogRevealComponent.radius -= radiusIncrease
	fogRevealComponent.recompile()
