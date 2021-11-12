extends Control

export(float, 0, 10) var fade_time = 1.0
export(float, 0, 10) var sleep_time = 2.0

const BTSPLSH_1_FADING_IN 	= 1
const BTSPLSH_1_SLEEPING 	= 2
const BTSPLSH_1_FADING_OUT 	= 3
const BTSPLSH_1_DONE		= 4

onready var state = 0

func _ready():
	$Timer.wait_time = sleep_time
	$Bootsplash1.modulate.a = 0
	
	# center window
	var screen_size = OS.get_screen_size()
	var window_size = OS.get_window_size()	
	OS.set_window_position(screen_size*0.5 - window_size*0.5)

	# fade bootsplash 1 in
	state = BTSPLSH_1_FADING_IN
	$Tween.interpolate_property($Bootsplash1, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), fade_time, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()

func _on_tween_tween_all_completed():
	if state == BTSPLSH_1_FADING_IN:
		# bootsplash 1 faded in, now sleep
		state = BTSPLSH_1_SLEEPING
		$Timer.start()
	
	elif state == BTSPLSH_1_FADING_OUT:
		# bootsplash 1 faded out, now sleep
		state = BTSPLSH_1_DONE
		$Timer.start()

func _on_timer_timeout():
	if state == BTSPLSH_1_SLEEPING:
		# bootsplash 1 slept, now fade out
		state = BTSPLSH_1_FADING_OUT

		$Tween.interpolate_property($Bootsplash1, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), fade_time, Tween.TRANS_LINEAR, Tween.EASE_IN)
		$Tween.start()
	
	elif state == BTSPLSH_1_DONE:
		end()

func end():
	print("bootsplash done")
	$Bootsplashblank.modulate.a = 0
