extends Area2D
class_name PickUp

onready var animations := $AnimationPlayer
enum PICKUP_TYPE {health, maxHealth, upgrade}
export(PICKUP_TYPE) var currentType = PICKUP_TYPE.health

func _ready():
	match currentType:
		PICKUP_TYPE.health:
			$Sprites/Health.show()
		PICKUP_TYPE.upgrade:
			$Sprites/Upgrade.show()
	
	animations.play("float")

func _on_Health_body_entered(body):
	match currentType:
		PICKUP_TYPE.health:
			body.heal()
		PICKUP_TYPE.upgrade:
			body.upgrade()
	
	queue_free()
