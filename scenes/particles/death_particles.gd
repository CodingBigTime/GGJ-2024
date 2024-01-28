extends GPUParticles3D

@export var time_to_live: float = 1.0


func _on_done() -> void:
	self.queue_free()


func set_one_time() -> void:
	self.one_shot = true
	self.emitting = true
