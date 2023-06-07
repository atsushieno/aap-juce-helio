
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
	cp $(AAP_JUCE_DIR)/sample-project.gradle.properties $(ANDROID_APP_DIR)/gradle.properties
	cp override.gradle-wrapper.properties $(ANDROID_APP_DIR)/gradle/wrapper/gradle-wrapper.properties
	cp $(AAP_JUCE_DIR)/sample-project.libs.versions.toml $(ANDROID_APP_DIR)/gradle/libs.versions.toml
	cd $(ANDROID_APP_DIR) && ./gradlew build bundle

patch-helio: .stamp-helio

.stamp-helio:
	cd $(APP_TOPDIR) && patch -i $(PWD)/helio.patch -p1
	touch .stamp-helio

patch-juce: $(JUCE_DIR)/.stamp-juce

$(JUCE_DIR)/.stamp-juce:
	cd $(JUCE_DIR) ; \
		patch -i $(AAP_JUCE_DIR)/JUCE-support-Android-thread-via-dalvik-juce6.patch -p1 -l ; \
		patch -i $(AAP_JUCE_DIR)/JUCE-support-Android-kill-system-class-loader.patch -p1 -l ; \
		patch -i $(AAP_JUCE_DIR)/JUCE-support-Android-disable-detach-current-thread-juce6.patch -p1 -l ; \
		patch -i $(AAP_JUCE_DIR)/JUCE-76589ee.patch -p1 -l ; \
	touch .stamp-juce

dist:
	mkdir -p dist
	cp ./external/helio-workstation/Projects/Android/app/build/outputs/apk/debug_/debug/*.apk dist/
	cp ./external/helio-workstation/Projects/Android/app/build/outputs/bundle/release_Release/*.aab dist/
