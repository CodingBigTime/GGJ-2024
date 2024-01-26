extends RigidBody3D

signal explode(position: Vector2)


func _on_area_3d_body_entered(body: Node3D):
	if body.is_in_group("ground"):
		explode.emit(Vector2(position.x, position.z))
		queue_free()
