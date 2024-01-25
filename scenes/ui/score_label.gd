extends Label

var score: int = 0


func _ready():
	update_score(0)


func update_score(new_score: int):
	score = new_score
	GlobalState.submit_new_score(score)
	text = "Score: " + str(score)


func increase_score(delta_score: int):
	update_score(score + delta_score)
