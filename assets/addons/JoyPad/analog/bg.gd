extends Control


var height = 128 #target height
var width = 128 #target width



func _ready():
	get_node("_bg").scale = Vector2(2,2)
