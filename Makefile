default: build cp

build:
	 cd /home/sjoerd/Apps/Godot/Godot_v3.4-stable_mono_x11_64
	 ./Godot_v3.4-stable_mono_x11.64 project.godot --export-debug Android
cp:
	cp builds/factory-game-android.apk ~/GoogleDrive/

.PHONY: version-up
version-up:
	@set -e; \
	\
	FULLOLD=$$(cat project.godot | pcregrep -o1 'config\/version="([0-9]+\.[0-9]+\.[0-9]+)"'); \
	OLDBEGIN=$$(echo $$FULLOLD | pcregrep -o1 '([0-9]+\.[0-9]+\.)[0-9]+'); \
	OLD=$$(echo $$FULLOLD | pcregrep -o1 '[0-9]+\.[0-9]+\.([0-9]+)'); \
	\
	NEW=$$(expr $$OLD + 1); \
	FULLNEW=$$OLDBEGIN$$NEW; \
	\
	echo "$$FULLOLD -> $$FULLNEW ($$OLD -> $$NEW)"; \
	eval "sed -i 's/config\/version=\"$$FULLOLD\"/config\/version=\"$$FULLNEW\"/' project.godot";

git:
	git add --all
	git commit -m upload
	git push origin main
