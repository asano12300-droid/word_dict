import os
import json

def count(grade: str):
    file = os.path.expanduser(f"/home/aryu44/words/Datas/{grade}.json")
    with open(file, "r", encoding="utf-8") as f:
        data = json.load(f)
    words = len(data['words'])
    return words