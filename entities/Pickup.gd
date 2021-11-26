extends Area2D

onready var animations := $AnimationPlayer
enum PICKUP_TYPE {health, upgrade}
export(PICKUP_TYPE) var currentType = PICKUP_TYPE.upgrade
var rng = RandomNumberGenerator.new()

func _ready():
	match currentType:
		PICKUP_TYPE.health:
			$Sprites/Health.show()
		PICKUP_TYPE.upgrade:
			$Sprites/Upgrade.show()
	
	animations.play("float")
	
func chooseRandom():
	rng.randomize()
	currentType = rng.randi_range(0, PICKUP_TYPE.size() -1)

func _on_Health_body_entered(body):
	match currentType:
		PICKUP_TYPE.health:
			body.heal()
		PICKUP_TYPE.upgrade:
			body.upgrade()
	
	queue_free()
