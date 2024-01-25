extends Camera2D

@export var follow_target: Node2D
@export var lerp_weight := 2.0


func _ready():
	position = follow_target.position


func _process(delta: float):
	position = lerp(position, follow_target.position, lerp_weight * delta)
