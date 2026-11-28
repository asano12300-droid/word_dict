import os
import json
from pathlib import Path

directory = Path(__file__).resolve().parents[2] / "words/Datas"

def count(grade: str):
    file = os.path.expanduser(f"{directory}/{grade}.json")
    if os.path.exists(file):
        with open(file, "r", encoding="utf-8") as f:
            data = json.load(f)
        words = len(data['words'])
        return words
    else:
        return "なし"
