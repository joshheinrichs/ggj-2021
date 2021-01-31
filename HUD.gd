extends CanvasLayer

var goal = 5
var score = 0
var totalScore = 0
var days = 1
var current_time
var mission_time = 60
var game_over = false

func _ready():
	$Mission_Timer.start(mission_time)
	$Items_Collected.hide()
	$Died.hide()
	$Out_of_time.hide()
	$Score.text = String(score) + "/" + String(goal)
	var background_music = get_parent().get_node("background")
	if background_music:
		background_music.play()
	
func _process(_delta):
	if $"/root/Globals".play == false:
		return
	$Day.text = "DAY " + String(days)
	$Score.text = String(score) + "/" + String(goal)
	if int($Mission_Timer.time_left) != 0:
		$Items_Collected.hide()
		current_time = mission_time - int($Mission_Timer.time_left)
	$Time.text = String(int($Mission_Timer.time_left))
	
	if score == goal:
		$Mission_Timer.stop()
		$Items_Collected/Items.text = String(score) + "/" + String(goal) + " COLLECTED"
		$Items_Collected/Time.text = "In " + String(current_time) + " Seconds"
		$Items_Collected.show()
		_on_Timer_timeout()
	elif game_over:
		$Mission_Timer.stop()
	
func _on_Player_found_bug():
	score = score + 1
	$Score.text = String(score) + "/" + String(goal)

func _on_Player_killed():
	game_over = true
	$Died/Items.text = "{score}/{goal} COLLECTED".format({"score": score, "goal": goal})
	$Died.show()

func _on_Timer_timeout():
#	$Tween.interpolate_property(ColorRect,"color", "00ffffff", "00000000", EASE_IN, Ease_OUT, 4)
#	$Tween.start()
	get_parent().get_node("Player").position = get_parent().get_node("hideyHole").position
	next_day()
	
func next_day():
	if score < goal:
		$Out_of_time.show()
		
	days += 1
	totalScore += score
	$"/root/Globals".play = false
	get_parent().get_node("background").stop()


func _on_Button_button_down():
	$"/root/Globals".play=true
	score = 0
	$Mission_Timer.start(mission_time)
	$"/root/Globals".totalScore = totalScore
	get_parent().get_node("background").play()
