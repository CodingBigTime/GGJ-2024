class_name WaterBalloonAoe
extends Area3D


func _on_area_3d_body_entered(body: Node3D):
	if body.is_in_group("villager"):
		body.mark_for_attack()


func _on_timer_timeout():
	self.queue_free()


func set_radius(radius: float):
	$CollisionShape3D.shape.radius = radius
	$Area3D/CollisionShape3D.shape.radius = radius
	$Sprite3D.scale = Vector3(3 * radius, 3 * radius, 1)
	$GPUParticles3D.scale = Vector3.ONE * radius * 1.5


func _ready():
	$GPUParticles3D.one_shot = true
	$GPUParticles3D.emitting = true
