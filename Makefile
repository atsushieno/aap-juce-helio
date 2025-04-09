
PWD=$(shell pwd)
AAP_DIR=$(shell pwd)/external/aap-core
APP_TOPDIR=external/helio-workstation
ANDROID_APP_DIR=external/helio-workstation/Projects/Android
JUCE_ORIGINAL=https://github.com/juce-framework/JUCE.git
AAP_JUCE_DIR=$(shell pwd)/external/aap-juce
JUCE_DIR=$(APP_TOPDIR)/ThirdParty/JUCE

all: build

build: build-aap-core patch-juce build-helio

build-aap-core:
	cd $(AAP_DIR) && ./gradlew build publishToMavenLocal

build-helio: patch-helio
	cp $(AAP_JUCE_DIR)/settings-head.gradle $(ANDROID_APP_DIR)/settings.gradle
	echo "rootProject.name='helio-workstation'" >> $(ANDROID_APP_DIR)/settings.gradle
	echo "include ':app'" >> $(ANDROID_APP_DIR)/settings.gradle
	cp $(AAP_JUCE_DIR)/projuce-app-template/gradle.properties $(ANDROID_APP_DIR)/gradle.properties
	cp $(AAP_JUCE_DIR)/projuce-app-template/gradle-wrapper.* $(ANDROID_APP_DIR)/gradle/wrapper/
	cp $(AAP_JUCE_DIR)/projuce-app-template/libs.versions.toml $(ANDROID_APP_DIR)/gradle/libs.versions.toml
	cp $(AAP_JUCE_DIR)/projuce-app-template/build.gradle $(ANDROID_APP_DIR)/
	cd $(ANDROID_APP_DIR) && ./gradlew build bundle

patch-helio: .stamp-helio

.stamp-helio:
	cd $(APP_TOPDIR) && patch -i $(PWD)/helio.patch -p1
	touch .stamp-helio

patch-juce: $(JUCE_DIR)/.stamp-juce

$(JUCE_DIR)/.stamp-juce:
	cd $(JUCE_DIR) ; \
		patch -i $(AAP_JUCE_DIR)/JUCE-support-Android-CMake-hosting.patch -p1 -l ; \
		patch -i $(AAP_JUCE_DIR)/juce-patches/7.0.5/thread-via-dalvik.patch -p1 -l ; \
		patch -i $(AAP_JUCE_DIR)/JUCE-76589ee.patch -p1 -l ; \
	touch .stamp-juce

dist:
	mkdir -p dist
	cp ./external/helio-workstation/Projects/Android/app/build/outputs/apk/debug_/debug/*.apk dist/
	cp ./external/helio-workstation/Projects/Android/app/build/outputs/bundle/release_Release/*.aab dist/
