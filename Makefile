.PHONY: all clean debug release install

THEOS ?= $(HOME)/theos
ARCHS = arm64 arm64e
TARGET = iphone:clang:16.5:15.0

export THEOS
export ARCHS
export TARGET

TWEAK_NAME = ProxyHook

$(TWEAK_NAME)_FILES = \
    src/main.mm \
    src/ProxyManager.mm \
    src/FloatingButton.mm \
    src/ProxySettingsViewController.mm \
    src/CFNetworkHooks.mm

$(TWEAK_NAME)_CFLAGS = -fobjc-arc -std=c++11 -I$(THEOS)/include
$(TWEAK_NAME)_LDFLAGS = -framework CoreFoundation -framework Foundation -framework UIKit -framework CFNetwork
$(TWEAK_NAME)_LIBRARIES = substrate

include $(THEOS)/makefiles/common.mk
include $(THEOS)/makefiles/tweak.mk

# Custom build for non-Theos builds
DEBUG ?= 0
OUTPUT_DIR = build
DYLIB_NAME = libProxyHook.dylib

SRC_DIR = src
SRCS = \
    $(SRC_DIR)/main.mm \
    $(SRC_DIR)/ProxyManager.mm \
    $(SRC_DIR)/FloatingButton.mm \
    $(SRC_DIR)/ProxySettingsViewController.mm \
    $(SRC_DIR)/CFNetworkHooks.mm

OBJS = $(SRCS:.mm=.o)

SDK_PATH = $(shell xcrun --sdk iphoneos --show-sdk-path)
CC = $(shell xcrun --sdk iphoneos --find clang++)
CFLAGS = -arch arm64 -arch arm64e -isysroot $(SDK_PATH) \
    -mios-version-min=15.0 \
    -fobjc-arc \
    -std=c++11 \
    -I./include \
    -I$(THEOS)/include \
    -framework CoreFoundation \
    -framework Foundation \
    -framework UIKit \
    -framework CFNetwork \
    -dynamiclib

ifeq ($(DEBUG),1)
    CFLAGS += -g -O0 -DDEBUG=1
else
    CFLAGS += -O3 -DNDEBUG
endif

LDFLAGS = -undefined dynamic_lookup \
    -framework CoreFoundation \
    -framework Foundation \
    -framework UIKit \
    -framework CFNetwork

all: $(OUTPUT_DIR)/$(DYLIB_NAME)

direct: $(OUTPUT_DIR)/$(DYLIB_NAME)

$(OUTPUT_DIR):
	mkdir -p $(OUTPUT_DIR)

%.o: %.mm
	$(CC) $(CFLAGS) -c $< -o $@

$(OUTPUT_DIR)/$(DYLIB_NAME): $(OUTPUT_DIR) $(OBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJS)
	@echo "Built: $@"
	@echo "Architecture:"
	@file $@

debug:
	$(MAKE) DEBUG=1

release:
	$(MAKE) DEBUG=0

clean:
	rm -rf $(OUTPUT_DIR)
	rm -f $(SRC_DIR)/*.o
	rm -rf .theos

install: $(OUTPUT_DIR)/$(DYLIB_NAME)
	@echo "Copying to device..."
	scp $(OUTPUT_DIR)/$(DYLIB_NAME) root@iphone:/var/jb/usr/lib/

# VS Code tasks compatible targets
vscode-debug: debug
vscode-release: release
