extends MarginContainer

# exports
export(String, FILE, "*.tscn") var back_scene_path
onready var list: VBoxContainer = $Panel/HBoxContainer/ScrollContainer/VBoxContainer
onready var name_label: Label = $Panel/HBoxContainer/InfoPanel/Name
onready var last_played_label: Label = $Panel/HBoxContainer/InfoPanel/Values/LastPlayed
onready var total_time_label: Label = $Panel/HBoxContainer/InfoPanel/Values/TotalTime
onready var seed_label: Label = $Panel/HBoxContainer/InfoPanel/Values/Seed

var selected_save: SaveData = null

# load save files into list
func _ready():
	update_saves_list()
	reset_info_display()
	
func update_saves_list():
	# clear old buttons
	for child in list.get_children():
		list.remove_child(child)
		child.queue_free()

	# add new buttons
	var saves = SaveHandler.get_saves()
	for save in saves:
		var button = Button.new()
		button.text = " " + save["name"]
		button.align = HALIGN_LEFT
		button.connect("pressed", self, "on_save_clicked", [save])
		list.add_child(button)

func reset_info_display():
	selected_save = null
	name_label.text = "Select a savefile"
	seed_label.text = "0000000000    "
	total_time_label.text = "00h 00m"
	last_played_label.text = "00:00 00-00-'00"

# display info on save in panel
func on_save_clicked(save: SaveData):
	selected_save = save
	print("selected: %s" % save.path)
	
	name_label.text = save.name
	seed_label.text = str(save.world_seed) + "    "
	
	# get local timezone offset to convert saved timestamp to local
	var local_timestamp = save.last_played + OS.get_time_zone_info()["bias"] * 60
	var dt = OS.get_datetime_from_unix_time(local_timestamp)
	last_played_label.text = "%02d:%02d %02d/%02d/'%02d" % [dt["hour"], dt["minute"], dt["day"], dt["month"], dt["year"] - 2000]
	
	total_time_label.text = "%dh %dm" % [int(save.total_played / 60), int(save.total_played) % 60]

func _on_Copy_pressed():
	print("copying seed %d" % selected_save.world_seed)
	OS.set_clipboard(str(selected_save.world_seed))

func _on_ButtonDelete_pressed():
	# make sure we can delete the selected file
	if selected_save is SaveData:
		# Warning first
		$PopupDeleteSave.normal_popup()
		while $PopupDeleteSave.state == $PopupDeleteSave.popupState.PENDING: yield(get_tree(), "idle_frame")
		if $PopupDeleteSave.state == $PopupDeleteSave.popupState.CANCELLED: return

		Directory.new().remove(selected_save.path)
		update_saves_list()
		reset_info_display()

# loading
func _on_ButtonLoad_pressed():
	if selected_save == null: return
	# load the World scene and make it load the selected save file
	var worldScene: Node = load("res://scenes/gameplay/World.tscn").instance()
	worldScene.preload_save(selected_save)
	var root = get_tree().get_root()
	root.get_child(root.get_child_count() - 1).queue_free()
	root.add_child(worldScene)
	get_tree().set_current_scene(worldScene)

# cancelling stuff
func _on_ButtonBack_pressed():
	back()
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
		back()
func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		back()
func back():
	# go to main menu
	var scene: PackedScene = load(back_scene_path)
	var _retval = get_tree().change_scene_to(scene)
