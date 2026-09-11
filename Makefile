# control.in から Version の値を取得
VERSION := $(shell grep -i '^Version:' control.in | awk '{print $$2}')

PKG_NAME := dict
ARCH := amd64
DEB_FILE := $(PKG_NAME)_$(VERSION)_$(ARCH).deb
EXE_FILE := $(PKG_NAME).exe
ZIP_FILE := $(PKG_NAME)_$(VERSION)_windows.zip

BUILD_DIR := build_deb
BIN_DIR := $(BUILD_DIR)/usr/local/bin
SHARE_DIR := $(BUILD_DIR)/usr/share/dict-app
DEBIAN_DIR := $(BUILD_DIR)/DEBIAN

CXX := g++
WIN_CXX := x86_64-w64-mingw32-g++
CXXFLAGS := -std=c++17 -O2

.PHONY: all clean deb exe install uninstall

all: deb exe

# 1. Linux用バイナリのビルド
$(PKG_NAME): main.cpp
	$(CXX) $(CXXFLAGS) $< -o $@

# 2. Windows用 .exe のクロスコンパイル (静的リンクを設定して依存DLLを排除)
$(EXE_FILE): main.cpp
	$(WIN_CXX) $(CXXFLAGS) -static -static-libgcc -static-libstdc++ $< -o $@

# 3. .deb パッケージの作成
deb: $(PKG_NAME) control.in dictionary.json
	@echo "--- .deb パッケージを作成中 (Version: $(VERSION)) ---"
	mkdir -p $(BIN_DIR) $(SHARE_DIR) $(DEBIAN_DIR)
	cp $(PKG_NAME) $(BIN_DIR)/$(PKG_NAME)
	cp dictionary.json $(SHARE_DIR)/dictionary.json
	cp control.in $(DEBIAN_DIR)/control
	dpkg-deb --build $(BUILD_DIR) $(DEB_FILE)
	@echo "--- Linux向け作成完了: $(DEB_FILE) ---"

# 4. Windows用配布パッケージ (.zip) の作成
exe: $(EXE_FILE) dictionary.json
	@echo "--- Windows向け Zip を作成中 ---"
	zip -r $(ZIP_FILE) $(EXE_FILE) dictionary.json
	@echo "--- Windows向け作成完了: $(ZIP_FILE) ---"

install: deb
	sudo dpkg -i $(DEB_FILE)

uninstall:
	sudo dpkg -r $(PKG_NAME)

clean:
	rm -rf $(PKG_NAME) $(EXE_FILE) $(BUILD_DIR) *.deb *.zip
