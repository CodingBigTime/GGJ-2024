extends Camera3D

@export var follow_target: Node3D
@export var lerp_weight := 2.0
@export var offset: Vector3 = Vector3(0, 10, 10)


func _ready():
	position = follow_target.position + offset


func _process(delta: float):
	position = lerp(position, follow_target.position + offset, lerp_weight * delta)
