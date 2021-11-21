extends Node2D

onready var line1 := $Line2D1
onready var line2 := $Line2D2
onready var line3 := $Line2D3
onready var animations := $AnimationPlayer
var points = []

func _ready():
	line1.points = points
	line2.points = [points[0] * 1.05, points[1] * 1.05]
	line3.points = [points[0] * 1.1, points[1] * 1.1]
	animations.play("fade")

func addPoint(position: Vector2):
	points.append(position)

func _on_destroyTimer_timeout():
	queue_free()
