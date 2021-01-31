extends Timer

signal day_passed

func _process(_delta):
	if is_stopped():
		emit_signal("day_passed")

