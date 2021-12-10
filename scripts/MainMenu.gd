extends CanvasLayer

onready var buttonHoverAudio := $ButtonHover
onready var buttonClickAudio := $ButtonClick
onready var soundSlider := $Control/Options/MarginContainer/VBoxContainer/HBoxContainer/SoundSlider

func _ready():
	soundSlider.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))

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
	buttonHoverAudio.play()

func _on_optionsBack_button_down():
	GLOBAL.updateSaveState()
	$SwitchScenePlayer.play_backwards("toOptions")
	$SwitchAudio.play()

func _on_optionsBack_mouse_entered():
	buttonHoverAudio.play()

func _on_toggleFullscreen_toggled(button_pressed):
	OS.window_fullscreen = button_pressed
