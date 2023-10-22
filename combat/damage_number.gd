extends Node2D

@export var value: int = 0

func _ready():
	$Label.text = str(value)


func _on_timer_timeout():
	queue_free()
