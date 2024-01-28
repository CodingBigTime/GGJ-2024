class_name ActorUtils


static func get_movement_string(movement: Vector2) -> String:
	if movement == Vector2(0, 0):
		return "normal_down"

	var angle = atan2(movement.y, movement.x)
	var normalized = angle / (2 * PI)

	var index = int(round(normalized * 8)) % 8

	var directions = [
		"right_normal",
		"right_down",
		"normal_down",
		"left_down",
		"left_normal",
		"left_up",
		"normal_up",
		"right_up"
	]

	return directions[index]
