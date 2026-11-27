# words/Scripts/Commands/list.py

import os
import json
from pathlib import Path

directory = Path(__file__).resolve().parents[2] / "Datas"

def list(grade):
    file_url = f"{directory}/{grade}.json"
    if os.path.exists(file_url):
        with open(file_url, "r", encoding="utf-8") as f:
            data = json.load(f)
        print(f"------単語一覧(最終更新: {data['updatingDate']})------")
        words = data['words']
        i = 1
        for word, meaning in words.items():
            print(f"{i}. {word}: {meaning}")
            i += 1 
    else:
        print(f"{grade}の単語が登録されていません")
