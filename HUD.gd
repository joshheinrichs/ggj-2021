extends CanvasLayer

var goal = 5
var score = 0
var totalScore = 0
var days = 0
var current_time
var mission_time = 60

func _ready():
	$Mission_Timer.start(mission_time)
	$Items_Collected.hide()
	$Died.hide()
	$Out_of_time.hide()
	$Score.text = String(score) + "/" + String(goal)
	
func _process(_delta):
	print($Between_Timer.time_left)
	if $Between_Timer.time_left == 0:
		$Items_Collected.hide()
		if int($Mission_Timer.time_left) != 0:
			current_time = mission_time - int($Mission_Timer.time_left)
		$Time.text = String(int($Mission_Timer.time_left))
		
		if score == goal:
			$Mission_Timer.stop()
			$Items_Collected/Items.text = String(score) + "/" + String(goal) + " COLLECTED"
			$Items_Collected/Time.text = "In " + String(current_time) + " Seconds"
			$Items_Collected.show()
			_on_Timer_timeout()
	
func _on_Player_found_bug():
	score = score + 1
	$Score.text = String(score) + "/" + String(goal)


func _on_Timer_timeout():
#	$Tween.interpolate_property(ColorRect,"color", "00ffffff", "00000000", EASE_IN, Ease_OUT, 4)
#	$Tween.start()
	get_parent().get_node("Player").position = get_parent().get_node("hideyHole").position
	next_day()
	
func next_day():
	if score < goal:
		$Out_of_time.show()
		
	days += 1
	$Day.text = "DAY " + String(days)
	$Mission_Timer.start(60)
	totalScore += score
	score = 0
	$Score.text = String(score) + "/" + String(goal)
	$Between_Timer.start(10)
	$Mission_Timer.start(60)
	



