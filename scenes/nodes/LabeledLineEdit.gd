tool
extends VBoxContainer

# exports
export(String) var label = "Input"				setget set_label
export(String) var default_text = ""			setget set_default_text
export(String) var placeholder = ""				setget set_placeholder
export(int) var max_length = 25					setget set_max_length
enum ALIGNMENT { Left, Center, Right, Fill }
export(ALIGNMENT) var align = ALIGNMENT.Left	setget set_alignment

# setters
func set_label(new: String):
	label = new
	$Label.text = new
func set_default_text(new: String):
	default_text = new
	$LineEdit.text = new
func set_placeholder(new: String):
	placeholder = new
	$LineEdit.placeholder_text = new
func set_max_length(new: int):
	max_length = new
	$LineEdit.max_length = new
func set_alignment(new):
	align = new
	match new:
		ALIGNMENT.Left: $LineEdit.align = $LineEdit.ALIGN_LEFT
		ALIGNMENT.Center: $LineEdit.align = $LineEdit.ALIGN_CENTER
		ALIGNMENT.Right: $LineEdit.align = $LineEdit.ALIGN_RIGHT
		ALIGNMENT.Fill: $LineEdit.align = $LineEdit.ALIGN_FILL

# functions
