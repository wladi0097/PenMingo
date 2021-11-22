extends Node

var player: KinematicBody2D

func _ready():
	var master_sound = AudioServer.get_bus_index("Master")
#	AudioServer.set_bus_mute(master_sound, true)
