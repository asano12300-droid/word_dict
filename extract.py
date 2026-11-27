# words/extract.py

import os
import json

def read(grade: str):
    file_url = os.path.expanduser(f"/home/aryu44/words/Datas/{grade}.json")
    with open(file_url, "r", encoding="utf-8") as f:
        data = json.load(f)
        words = data['words']
    return words

data1 = read(grade="2q")
data2 = read(grade="pre2q")
data3 = {}

for word, meaning in data1.items():
    if word in data2.items():
        data3[word] = meaning
    else:
        data3[word] = meaning

for word, meaning in data2.items():
    if word in data1.items():
        continue
    else:
        data3[word] = meaning

file = os.path.expanduser(f"/home/aryu44/words/Datas/result.json")
with open(file, "w", encoding="utf-8") as f:
    json.dump(data3, f, ensure_ascii=False, indent=2)