class_name HealthBar
extends Node2D

# @onready var background: Sprite2D = $background
@onready var colored: Sprite2D = $colored

var health: float = 1.0
# 0...1
@rpc("any_peer", "call_local", "unreliable_ordered", 5)
func set_health(health: float):
	colored.scale.x = clamp(health, 0, 1)
	if health <= 0:
		visible = false
