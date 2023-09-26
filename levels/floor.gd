extends Node2D
class_name Floor

@export var size: int = 32
@export var sprites: Array[Texture2D]
@export var rotate: bool = false
@export var width: int = 640
@export var height = 360

var rng = RandomNumberGenerator.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	
	for y in range(height / size + 1):
		for x in range(width / size + 1):
			var sprite = Sprite2D.new()
			sprite.centered = false
			sprite.texture = sprites[0]
			sprite.position = Vector2(x * size, y * size)
			if rotate:
				sprite.rotation_degrees = 90 * rng.randi_range(0, 3)
			add_child(sprite)

