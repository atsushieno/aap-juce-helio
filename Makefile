
PWD=$(shell pwd)
AAP_DIR=$(shell pwd)/external/android-audio-plugin-framework
APP_TOPDIR=external/helio-workstation
ANDROID_APP_DIR=external/helio-workstation/Projects/Android
JUCE_ORIGINAL=https://github.com/juce-framework/JUCE.git

all: build

build: prepare build-aap-core build-helio

prepare:
	cd external/helio-workstation/ThirdParty/JUCE && git remote set-url original $(JUCE_ORIGINAL) || git remote add original $(JUCE_ORIGINAL)
	cd external/helio-workstation/ThirdParty/JUCE && git fetch original master && git checkout 6.0.8

build-aap-core:
	cd $(AAP_DIR) && make

build-helio: .stamp-aap patch-helio
	cd external/helio-workstation/ThirdParty/JUCE && git checkout master && cd ../../../..
	cp gradle.properties $(ANDROID_APP_DIR)
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
