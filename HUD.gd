extends CanvasLayer

var score = 0	
func _on_Player_found_bug():
	score = score + 1
	$Score.text = String(score) + "/5"
