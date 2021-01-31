extends CanvasLayer

var goal = 5
var score = 0	
var days = 0
func _ready():
	$Items_Collected.hide()
	$Score.text = String(score) + "/" + String(goal)
	
func _process(_delta):
	$Time.text = String(int($Timer.time_left))
	
	if score == goal:
		$Timer.stop()
		$Items_Collected/Label.text = String(score) + "/" + String(goal) + " COLLECTED"
		$Items_Collected.show()
	
func _on_Player_found_bug():
	score = score + 1
	$Score.text = String(score) + "/" + String(goal)


func _on_Timer_timeout():
	days += 1
	$Day.text = "DAY " + String(days)
