default: build cp

build:
	 ~/Apps/GODOTBUILDS/3.4/godot_3.4-stable_rpi4_editor_lto.bin project.godot --export-debug Android
cp:
	cp builds/factory-game-android.apk ~/gdrive/
