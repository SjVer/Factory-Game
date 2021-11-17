extends Node

func _ready():
	pass
	# get_tree().set_quit_on_go_back(false)
	# get_tree().set_auto_accept_quit(false)

func print(format: String, args: Array = []):
	if OS.is_debug_build():
		print(format % args)
	
