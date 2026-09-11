import os
import json

class Word:
    def __init__(self):
        self.file_path = os.path.expanduser('/home/asano12300-droid/workspaces/word_dict/dictionary.json')

    def op(self):
        with open(self.file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        return data

    def add(self):
        words = self.op()
        word = input("新しい単語: ").strip()
        if word in words:
            print(f"{word}は追加されています。")
        else:
            meaning = input("意味: ").strip()
            words[word] = meaning
            with open(self.file_path, 'w', encoding='utf-8') as f:
                json.dump(words, f, ensure_ascii=False, indent=4)

    def amount(self):
        words = self.op()
        word = len(words)
        return word

if __name__ == '__main__':
    print("=== Select Menu ===")
    print("1. 追加")
    print("2. 単語数")
    print("3. 終了")
    print("===================")
    word = Word()
    select = input("何をしますか: ").strip()
    if select == "1":
        while True:
            try:
                word.add()
            except KeyboardInterrupt:
                break
    elif select == "2":
        word.amount()
    elif select == "3":
        pass