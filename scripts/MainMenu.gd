extends CanvasLayer

onready var buttonHoverAudio := $ButtonHover
onready var buttonClickAudio := $ButtonClick

func _on_NewGameButton_button_down():
	buttonClickAudio.play()
	yield(buttonClickAudio, "finished")
	
	LOADING_TRANSITION.start()
	yield(LOADING_TRANSITION, "animation_finished")
	
	CURRENT_RUN.startNewRun()
	queue_free()

func _on_ContinueButton_mouse_entered():
	pass
	
func _on_NewGameButton_mouse_entered():
	buttonHoverAudio.play()

func _on_OptionsButton_mouse_entered():
	buttonHoverAudio.play()

func _on_OptionsButton_button_down():
	$SwitchScenePlayer.play("toOptions")
	$SwitchAudio.play()

func _on_HSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)
	$SwitchAudio.play()

func _on_optionsBack_button_down():
	$SwitchScenePlayer.play_backwards("toOptions")
	$SwitchAudio.play()

func _on_optionsBack_mouse_entered():
	buttonHoverAudio.play()
