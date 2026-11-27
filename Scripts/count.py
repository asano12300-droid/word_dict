import json
from pathlib import Path

directory = Path(__file__).resolve().parents[2] / "Datas"

def count(grade: str):
    file = os.path.expanduser(f"{directory}/{grade}.json")
    with open(file, "r", encoding="utf-8") as f:
        data = json.load(f)
    words = len(data['words'])
    return words
