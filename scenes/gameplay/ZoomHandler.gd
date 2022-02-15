extends Camera2D

var first_distance = 0
var events = {}
var percision = 10
var current_zoom
var maximum_zoomin = Vector2(0.5, 0.5)
var minimum_zoomout = Vector2(5, 5)
onready var zoom_factor = 0.99 - 0.49 * Settings.zoom

func _ready():
	set_process_unhandled_input(true)

func dist():
	var first_event = null
	var result 
	for event in events:
		if first_event != null:
			result = events[event].get_position().distance_to(first_event.get_position())
			break
		first_event = events[event]
	return result

func _unhandled_input(event):
		if event is InputEventScreenTouch and event.is_pressed():
			events[event.index] = event

			if events.size() > 1:
				current_zoom = get_zoom()
				first_distance = dist()

		elif event is InputEventScreenTouch and not event.is_pressed():
			events.erase(event.index)

		elif event is InputEventScreenDrag:
			events[event.index] = event

			if events.size() > 1:
				var second_distance = dist()
				if abs(first_distance - second_distance) > percision:
					var new_zoom = Vector2(
						first_distance / second_distance,
						first_distance / second_distance
						)
					var zoom = new_zoom * current_zoom
					if zoom < minimum_zoomout and zoom > maximum_zoomin:
						set_zoom(zoom)
					elif zoom > minimum_zoomout:
						set_zoom(minimum_zoomout)
					elif zoom < maximum_zoomin:
						set_zoom(maximum_zoomin)

		elif event.is_action_pressed("ui_zoom_in"):
			zoom.x = clamp(zoom.x * zoom_factor, maximum_zoomin.x, minimum_zoomout.x)
			zoom.y = clamp(zoom.y * zoom_factor, maximum_zoomin.y, minimum_zoomout.y)
			set_zoom(zoom)

		elif event.is_action_pressed("ui_zoom_out"):
			zoom.x = clamp(zoom.x / zoom_factor, maximum_zoomin.x, minimum_zoomout.x)
			zoom.y = clamp(zoom.y / zoom_factor, maximum_zoomin.y, minimum_zoomout.y)
			set_zoom(zoom)
