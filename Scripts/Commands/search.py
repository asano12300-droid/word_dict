# words/Scripts/Commands/search.py

import os
import json
from pathlib import Path

directory = Path(__file__).resolve().parents[2] / "words/Datas"

def search(grade: str, word: str):
    file_url = f"{directory}/{grade}.json"
    if os.path.exists(file_url):
        with open(file_url, "r", encoding="utf-8") as f:
            data = json.load(f)
        words = data['words']
        if word in words:
            print(f"{word}: {words[word]}")
        else:
            print(f"{word}は登録されていません")
    else:
        print(f"{grade}.jsonは存在しません。\n再度ご確認ください。")
