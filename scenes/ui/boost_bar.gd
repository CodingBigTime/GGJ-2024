extends TextureProgressBar


func update_value(new_value: float):
	value = clamp(new_value, min_value, max_value)
