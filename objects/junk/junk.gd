extends Node3D

var junk_options: Array[CompressedTexture2D] = [
	preload("res://assets/sprites/junk/junk_01.png"),
	preload("res://assets/sprites/junk/junk_02.png"),
	preload("res://assets/sprites/junk/junk_03.png")
]


func _ready():
	$Sprite3D.texture = Random.random_from_array(self.junk_options)
	$Sprite3D.position = clown_minion.position


func _process(_delta):
	pass
