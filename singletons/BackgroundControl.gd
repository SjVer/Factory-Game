extends Node

func _input(event):
    if event is InputEventKey:
        if event.is_action_pressed("Debug_RotateScreen"):
            var oldsize: Vector2 = OS.get_window_size()
            OS.set_window_size(Vector2(oldsize.y, oldsize.x))