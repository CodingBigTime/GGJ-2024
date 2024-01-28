class_name CymbalsAoe
extends Area3D

signal hit_villager(villager: Villager)


func _ready():
	$GPUParticles3D.one_shot = true
	$GPUParticles3D.emitting = true


func _on_body_entered(body: Node3D):
	if body.is_in_group("villager"):
		self.hit_villager.emit(body)


func _on_timer_timeout():
	self.queue_free()


func set_radius(radius: float):
	$CollisionShape3D.shape.radius = radius
	$GPUParticles3D.scale = Vector3.ONE * radius
