class_name BestScoreLabel
extends Label


func _ready() -> void:
	GlobalState.reset_best_score_signal.connect(update_best_score)
	update_best_score()


func update_best_score() -> void:
	if GlobalState.new_best_score:
		text = "New best score: " + str(GlobalState.get_best_score())
		label_settings.font_color = Color(1.0, 1.0, 0.0)
		GlobalState.new_best_score = false
	else:
		text = "Best score: " + str(GlobalState.get_best_score())
		label_settings.font_color = Color(1.0, 1.0, 1.0)
