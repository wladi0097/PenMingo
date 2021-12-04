extends CanvasLayer

onready var animations := $AnimationPlayer
onready var audio := $switchAudioPlayer

signal animation_finished

func start():
	audio.play()
	animations.play("transition0")
	
func end():
	audio.play()
	animations.play("transition1")


func _on_AnimationPlayer_animation_finished(anim_name):
	emit_signal("animation_finished")
