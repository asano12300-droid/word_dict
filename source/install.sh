#!/bin/bash

sudo apt update
sudo apt install g++ nlohmann-json3-dev
mkdir -p word-dict

cat << E0F > Makefile
# control.in から Version の値を取得する
VERSION := $(shell grep -i '^Version:' control.in | awk '{print $$2}')

# 変数定義
PKG_NAME := dict
ARCH := amd64
DEB_FILE := $(PKG_NAME)_$(VERSION)_$(ARCH).deb

BUILD_DIR := build_deb
BIN_DIR := $(BUILD_DIR)/usr/local/bin
SHARE_DIR := $(BUILD_DIR)/usr/share/dict-app
DEBIAN_DIR := $(BUILD_DIR)/DEBIAN

CXX := g++
CXXFLAGS := -std=c++17 -O2
LIBS := 

.PHONY: all clean deb install uninstall

# デフォルトターゲット: .deb パッケージのビルド
all: deb

# 1. C++ソースコードのコンパイル
$(PKG_NAME): main.cpp
        $(CXX) $(CXXFLAGS) $< -o $@ $(LIBS)

# 2. .deb パッケージの作成
deb: $(PKG_NAME) control.in dictionary.json
        @echo "--- .deb パッケージを作成中 (Version: $(VERSION)) ---"
        mkdir -p $(BIN_DIR)
        mkdir -p $(SHARE_DIR)
        mkdir -p $(DEBIAN_DIR)
        cp $(PKG_NAME) $(BIN_DIR)/$(PKG_NAME)
        cp dictionary.json $(SHARE_DIR)/dictionary.json
        cp control.in $(DEBIAN_DIR)/control
        dpkg-deb --build $(BUILD_DIR) $(DEB_FILE)
        @echo "--- 作成完了: $(DEB_FILE) ---"

# 3. 開発用: ローカルシステムへ直接インストール
install: deb
        sudo dpkg -i $(DEB_FILE)

# 4. アンインストール
uninstall:
        sudo dpkg -r $(PKG_NAME)

# 5. クリーンアップ
clean:
        rm -rf $(PKG_NAME) $(BUILD_DIR) *.deb
E0F
mv Makefile word-dict/

cat << E0F > control.in
Package: dict
Version: 1.0.4
Section: utils
Priority: optional
Architecture: amd64
Maintainer: aryu44 <asano12300@gmail.com>
Description: Command Line English Dictionary
 A simple CLI dictionary program written in C++ using JSON for storage.
E0F
mv control.in word-dict/


cat << E0F > main.cpp
#include <iostream>
#include <fstream>
#include <string>
#include <map>
#include <algorithm>
#include <cstdlib>
#include <sys/stat.h>
#include <nlohmann/json.hpp>

using json = nlohmann::json;

class Dictionary {
private:
    std::map<std::string, std::string> words;
    std::string user_filepath;
    const std::string default_filepath = "/usr/share/dict-app/dictionary.json";

    std::string toLower(std::string str) const {
        std::transform(str.begin(), str.end(), str.begin(), [](unsigned char c){
            return std::tolower(c);
        });
        return str;
    }

    std::string getSaveFilePath() {
        const char* home = std::getenv("HOME");
        std::string dir = home ? std::string(home) + "/.dict" : ".";
        
        #ifndef _WIN32
            mkdir(dir.c_str(), 0755);
        #endif
        
        return dir + "/dictionary.json";
    }

    bool fileExists(const std::string& name) {
        struct stat buffer;
        return (stat(name.c_str(), &buffer) == 0);
    }

    // デフォルト辞書と既存辞書をマージ（新しく追加された単語を取り込む）
    void mergeWithDefaultDictionary() {
        std::ifstream default_file(default_filepath);
        if (!default_file.is_open()) return;

        try {
            json default_j;
            default_file >> default_j;
            bool updated = false;

            for (auto& [key, value] : default_j.items()) {
                // ユーザーの辞書に存在しない単語だけを追加
                if (words.find(key) == words.end()) {
                    words[key] = value.get<std::string>();
                    updated = true;
                }
            }

            // 新しい単語が追加された場合は保存
            if (updated) {
                saveToFile();
            }
        } catch (const std::exception& e) {
            // パースエラー等の無視
        }
        default_file.close();
    }

public:
    Dictionary() {
        user_filepath = getSaveFilePath();

        // 既存データを読み込み
        if (fileExists(user_filepath)) {
            loadFromFile();
        }

        // デフォルト辞書（最新の配布データ）とマージ
        mergeWithDefaultDictionary();
    }

    size_t getWordCount() const {
        return words.size();
    }

    void loadFromFile() {
        std::ifstream file(user_filepath);
        if (!file.is_open()) return;

        try {
            json j;
            file >> j;
            words.clear();
            for (auto& [key, value] : j.items()) {
                words[key] = value.get<std::string>();
            }
        } catch (const std::exception& e) {
            std::cerr << "JSON読み込みエラー: " << e.what() << std::endl;
        }
        file.close();
    }

    void saveToFile() const {
        std::ofstream file(user_filepath);
        if (!file.is_open()) {
            std::cerr << "エラー: ファイルに保存できませんでした。" << std::endl;
            return;
        }

        json j = words;
        file << j.dump(4);
        file.close();
    }

    void searchWord(const std::string& raw_word) const {
        std::string word = toLower(raw_word);
        auto it = words.find(word);
        if (it != words.end()) {
            std::cout << "\n[検索結果]\n" << it->first << " : " << it->second << "\n\n";
        } else {
            std::cout << "\n\"" << raw_word << "\" は見つかりませんでした。\n\n";
        }
    }

    void addWord(const std::string& raw_word, const std::string& meaning) {
        std::string word = toLower(raw_word);
        words[word] = meaning;
        saveToFile();
        std::cout << "\n「" << word << "」を追加・更新しました。\n\n";
    }

    void listWords() const {
        if (words.empty()) {
            std::cout << "\n辞書は空です。\n\n";
            return;
        }
        std::cout << "\n--- 登録単語一覧 (" << words.size() << "語) ---\n";
        for (const auto& pair : words) {
            std::cout << pair.first << " : " << pair.second << "\n";
        }
        std::cout << "------------------------------\n\n";
    }
};

int main() {
    Dictionary dict;
    int choice = 0;

    while (true) {
        std::cout << "=== 英単語帳 （現在: " << dict.getWordCount() << "語) ===" << std::endl;
        std::cout << "1. 単語を検索\n"
                  << "2. 単語を追加/更新\n"
                  << "3. 一覧表示\n"
                  << "4. 終了\n"
                  << "選択 (1-4): ";

        if (!(std::cin >> choice)) {
            std::cin.clear();
            std::cin.ignore(10000, '\n');
            std::cout << "無効な入力です。番号を入力してください。\n\n";
            continue;
        }

        std::cin.ignore(10000, '\n');

        if (choice == 1) {
            std::string word;
            std::cout << "検索する単語: ";
            std::getline(std::cin, word);
            if (!word.empty()) dict.searchWord(word);
        } else if (choice == 2) {
            std::string word, meaning;
            std::cout << "追加する単語: ";
            std::getline(std::cin, word);
            std::cout << "意味: ";
            std::getline(std::cin, meaning);
            if (!word.empty() && !meaning.empty()) {
                dict.addWord(word, meaning);
            } else {
                std::cout << "単語と意味の両方を入力してください。\n\n";
            }
        } else if (choice == 3) {
            dict.listWords();
        } else if (choice == 4) {
            std::cout << "辞書アプリを終了します。" << std::endl;
            break;
        } else {
            std::cout << "1〜4の番号を選択してください。\n\n";
        }
    }

    return 0;
}
E0F
mv main.cpp word-dict/