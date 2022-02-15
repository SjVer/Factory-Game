extends Node2D

var tilemap: TileMap
onready var hold_time: float = 0
var holding: bool

const HOLD_MIN = 0.25
signal _tile_set_request(position, clear)

"""
press? -> is first? -> wait -> longer than HOLD_MIN? -> delete
							-> shorter than HOLD_MIN? -> place
	   -> is second? -> zoom
"""

func set_tile(worldpos: Vector2, set: bool):
	var localpos = tilemap.world_to_map(worldpos)
	emit_signal("_tile_set_request", localpos, not set)

func _input(event):
	if event is InputEventScreenTouch:
		if event.is_pressed():
			if event.index > 0:
				# second touch: zoom
				holding = false
				# print("\nis second -> zoom")
			else:
				# first touch
				hold_time = 0
				holding = true
				# print("\nis first -> wait")

		elif holding and hold_time < HOLD_MIN:
			# release single touch early: place
			set_tile(tilemap.make_input_local(event).position, true)
			holding = false
			# print("shorter than HOLD_MIN -> place")

func _process(delta):
	if holding:
		hold_time += delta
		if hold_time > HOLD_MIN:
			# holding for long enough: delete
			set_tile(tilemap.get_local_mouse_position(), false)
			holding = false
			# print("longer than HOLD_MIN -> delete")