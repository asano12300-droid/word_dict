#include <iostream>
#include <fstream>
#include <string>
#include <map>
#include <algorithm>
#include <cstdlib>
#include <sys/stat.h>
#include <nlohmann/json.hpp>

#ifdef _WIN32
#include <direct.h>
#define MKDIR(dir) _mkdir(dir)
#else
#define MKDIR(dir) mkdir(dir, 0755)
#endif

using json = nlohmann::json;

class Dictionary {
private:
    std::map<std::string, std::string> words;
    std::string user_filepath;
    const std::string default_filepath = "dictionary.json"; // exeと同じ階層のデフォルトjson

    std::string toLower(std::string str) const {
        std::transform(str.begin(), str.end(), str.begin(), [](unsigned char c){
            return std::tolower(c);
        });
        return str;
    }

    std::string getSaveFilePath() {
#ifdef _WIN32
        const char* appdata = std::getenv("APPDATA");
        std::string dir = appdata ? std::string(appdata) + "\\dict" : ".";
#else
        const char* home = std::getenv("HOME");
        std::string dir = home ? std::string(home) + "/.dict" : ".";
#endif
        MKDIR(dir.c_str());

#ifdef _WIN32
        return dir + "\\dictionary.json";
#else
        return dir + "/dictionary.json";
#endif
    }

    bool fileExists(const std::string& name) {
        struct stat buffer;
        return (stat(name.c_str(), &buffer) == 0);
    }

    void mergeWithDefaultDictionary() {
        std::ifstream default_file(default_filepath);
        if (!default_file.is_open()) return;

        try {
            json default_j;
            default_file >> default_j;
            bool updated = false;

            for (auto& [key, value] : default_j.items()) {
                if (words.find(key) == words.end()) {
                    words[key] = value.get<std::string>();
                    updated = true;
                }
            }

            if (updated) {
                saveToFile();
            }
        } catch (const std::exception& e) {}
        default_file.close();
    }

public:
    Dictionary() {
        user_filepath = getSaveFilePath();

        if (fileExists(user_filepath)) {
            loadFromFile();
        }

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
