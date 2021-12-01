extends CanvasLayer

onready var animations := $AnimationPlayer

signal animation_finished

func start():
	animations.play("transition0")
	
func end():
	animations.play("transition1")


func _on_AnimationPlayer_animation_finished(anim_name):
	emit_signal("animation_finished")
