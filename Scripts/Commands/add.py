# words/Scripts/Commands/add.py

import os
import json
import datetime
from pathlib import Path
from . import grades

directory = Path(__file__).resolve().parents[2] / "words/Datas"

def create_words(grade: str):
    os.makedirs(directory, exist_ok=True)
    today = datetime.datetime.now()
    creatingDate = today.strftime("%Y/%m/%d %H:%M:%S")

    file_url = f"{directory}/{grade}.json"
    if grade == "2q":
        data = grades.grade_2()
    elif grade == "pre2q":
        data = grades.grade_pre2()
    elif grade == "all":
        data1 = grades.grade_2()
        words1 = data1['words']
        data2 = grades.grade_pre2()
        words2 = data2['words']
        data3 = {}
        for word, meaning in words1.items():
            if word in words2.items():
                data3[word] = meaning
            else:
                data3[word] = meaning

        for word, meaning in words2.items():
            if word in words1.items():
                continue
            else:
                data3[word] = meaning
        data = {
            "creatingDate": creatingDate,
            "updatingDate": creatingDate,
            "words": data3
        }
    
    else:
        return
    with open(file_url, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
            
def add_words(grade: str, new_word: str, new_meaning: str):
    file_url = f"{directory}/{grade}.json"
    with open(file_url, "r", encoding="utf-8") as f:
        data = json.load(f)
        words = data['words']
        
    today = datetime.datetime.now()
    now = today.strftime("%Y/%m/%d %H:%M:%S")

    data['words'][new_word] = new_meaning
    data['updatingDate'] = now

    with open(file_url, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"「{new_word}: {new_meaning}」を {grade} に追加しました。")

def add(grade):
    file_url = f"{directory}/{grade}.json"  
    if not os.path.exists(file_url):
        create_words(grade)
    else:
        new_word = input("追加したい英単語を入力: ")
        new_meaning = input("その意味: ")
        add_words(grade, new_word, new_meaning)
