
PWD=$(shell pwd)
AAP_DIR=$(shell pwd)/external/android-audio-plugin-framework
APP_TOPDIR=external/helio-workstation
ANDROID_APP_DIR=external/helio-workstation/Projects/Android

all: build

build: build-aap-core build-helio

build-aap-core:
	cd $(AAP_DIR) && make

build-helio: .stamp-aap patch-helio
	cp gradle.properties $(ANDROID_APP_DIR)
	cd ThirdParty/JUCE && git checkout master && cd ../..
	cd $(ANDROID_APP_DIR) && ./gradlew build

.stamp-aap: dummy-aap-dir
	touch .stamp-aap

dummy-aap-dir:
	unzip $(AAP_DIR)/java/androidaudioplugin/build/outputs/aar/androidaudioplugin-debug.aar -d dummy-aap-dir

patch-helio: .stamp-helio

.stamp-helio:
	cd $(APP_TOPDIR) && patch -i $(PWD)/helio.patch -p1
	touch .stamp-helio

dist:
	mkdir -p release-builds
	cp ./external/helio-workstation/Projects/Android/app/build/outputs/apk/release_/release/*.apk release-builds
