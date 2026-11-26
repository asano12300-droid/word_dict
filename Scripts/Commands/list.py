# words/Scripts/Commands/list.py

import argparse
import json
from pathlib import Path

directory = Path(__file__).resolve().parents[2] / "Datas"

def list(grade):
    file_url = directory / f"{grade}.json"
    if file_url.exists():
        with file_url.open("r", encoding="utf-8") as f:
            data = json.load(f)
        print(f"------単語一覧(最終更新: {data['updatingDate']})------")
        words = data['words']
        i = 1
        for word, meaning in words.items():
            print(f"{i}. {word}: {meaning}")
            i += 1 
    else:
        print(f"{grade}の単語が登録されていません")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="単語一覧を表示します")
    parser.add_argument("grade", nargs="?", help="表示する級 (例: 2q)")
    args = parser.parse_args()
    list(args.grade or input("何級ですか？ :ex)２級 -> 2q(半角): "))
