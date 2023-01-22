
PWD=$(shell pwd)
AAP_DIR=$(shell pwd)/external/aap-core
APP_TOPDIR=external/helio-workstation
ANDROID_APP_DIR=external/helio-workstation/Projects/Android
JUCE_ORIGINAL=https://github.com/juce-framework/JUCE.git

# TODO: apply juce-modules-*.patch files (they all matter)

all: build

build: build-aap-core build-helio

# it is disabled now that helio-workstation submodules fairly recent JUCE.
prepare:
	cd external/helio-workstation/ThirdParty/JUCE && git remote add original $(JUCE_ORIGINAL) || exit 0
	cd external/helio-workstation/ThirdParty/JUCE && git fetch original master && git checkout master

build-aap-core:
	cd $(AAP_DIR) && ./gradlew build publishToMavenLocal

build-helio: patch-helio
	cd external/helio-workstation/ThirdParty/JUCE && git checkout master && cd ../../../..
	cp gradle.properties $(ANDROID_APP_DIR)
	cd $(ANDROID_APP_DIR) && ./gradlew build

patch-helio: .stamp-helio

.stamp-helio:
	cd $(APP_TOPDIR) && patch -i $(PWD)/helio.patch -p1
	touch .stamp-helio

dist:
	mkdir -p release-builds
	cp ./external/helio-workstation/Projects/Android/app/build/outputs/apk/release_/release/*.apk release-builds
