extends RigidBody3D

signal explode(area: Area3D)

var explosion_radius = 5


func _on_area_3d_body_entered(body: Node3D):
	if body.is_in_group("ground"):
		var sphere_shape = SphereShape3D.new()
		sphere_shape.radius = explosion_radius
		var collision_shape = CollisionShape3D.new()
		collision_shape.shape = sphere_shape
		var area = Area3D.new()
		area.position = self.position
		area.add_child(collision_shape)
		explode.emit(area)
		queue_free()
