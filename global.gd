extends Node

var player: KinematicBody2D

var allRunsAttemts = 0

var saveState = {
	"soundMasterDb": 0
}

func _init():
	readSaveState()

func updateSaveState():
	saveState.soundMasterDb = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
	
	var save_game = File.new()
	save_game.open("user://savegame.save", File.WRITE)
	save_game.store_string(to_json(saveState))
	
func readSaveState():
	var save_game = File.new()
	if not save_game.file_exists("user://savegame.save"): return # Error! We don't have a save to load.
	save_game.open("user://savegame.save", File.READ)

	var jsonResponse =  JSON.parse(save_game.get_as_text())
	
	if jsonResponse.error_string != "": return # Error in json
	
	saveState =jsonResponse.result
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), saveState.soundMasterDb)
