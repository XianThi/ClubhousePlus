TARGET := iphone:clang:latest:7.0
INSTALL_TARGET_PROCESSES = clubhouse
export ARCHS=arm64

include $(THEOS)/makefiles/common.mk
ADDITIONAL_CFLAGS = -fobjc-arc
TWEAK_NAME = ClubhousePlus

ClubhousePlus_FILES = Tweak.xm
ClubhousePlus_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
