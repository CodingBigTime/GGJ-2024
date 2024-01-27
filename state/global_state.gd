extends Node

signal reset_best_score_signal

const SCORE_FILE = "user://score.save"

var debug: bool = false
var new_best_score: bool = false
var game_over_visible: bool = false


func toggle_debug() -> void:
	debug = !debug


func get_best_score() -> int:
	var best_score: int
	if FileAccess.file_exists(SCORE_FILE):
		var file = FileAccess.open(SCORE_FILE, FileAccess.READ)
		best_score = file.get_var()
		file.close()
	else:
		best_score = 0
	return best_score


## Shouldn't be called directly, use submit_new_score instead
func set_best_score(new_score: int) -> void:
	var file = FileAccess.open(SCORE_FILE, FileAccess.WRITE)
	file.store_var(new_score)
	file.close()


func reset_best_score() -> void:
	if FileAccess.file_exists(SCORE_FILE):
		set_best_score(0)
		reset_best_score_signal.emit()


func submit_new_score(new_score: int) -> void:
	if new_score > get_best_score():
		set_best_score(new_score)
		new_best_score = true


## Call this to show Game Over in the main menu next time instead of the game logo
func make_game_over_visible() -> void:
	game_over_visible = true
