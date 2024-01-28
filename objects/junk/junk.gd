extends Node3D

const JUNK_OPTIONS: Array[CompressedTexture2D] = [
	preload("res://assets/sprites/junk/junk_01.png"),
	preload("res://assets/sprites/junk/junk_02.png"),
	preload("res://assets/sprites/junk/junk_03.png")
]
var junk_type: int = 0


func _ready():
	self.junk_type = Random.weighted_choice([0, 1, 2], [0.05, 0.2, 0.5])
	$Sprite3D.texture = JUNK_OPTIONS[self.junk_type]


func convert_power():
	match self.junk_type:
		0:
			return 2
		1:
			return 0.5
		2:
			return 0.2
		_:
			return 0.05
