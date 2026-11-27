# words/Scripts/command.py

import os
import json
import sys
from . import Commands
from . import count
def command():
    if len(sys.argv) < 3:
        grade = input("何級ですか？ :ex)２級 -> 2q(半角): ")
        amount_words = count.count(grade)
        select = input(f"{grade}: {amount_words} 件 \n1.追加 2.検索 3.一覧 \n何をしますか？: ") 
        if select == "1": 
            Commands.add(grade)
        elif select == "2":
            word = input("検索したい単語: ")
            Commands.search(grade, word)
        elif select == "3":
            Commands.list(grade)
        else:
            print("無効な操作です。")
    elif sys.argv[1] == "-d":
        if not sys.argv[2]:
            print("何級か選択してください")
        else:
            Commands.list(grade=sys.argv[2])
    elif sys.argv[1] == "-a":
        if not sys.argv[2]:
            print("何級か選択してください")
        else:
            Commands.add(grade=sys.argv[2])
    elif sys.argv[1] == "-s":
        if not sys.argv[2]:
            print("何級か選択してください")
        else:
            if not sys.argv[3]:
                print("検索したい単語を指定してください")
            else:
                Commands.search(grade=sys.argv[2], word=sys.argv[3])
    elif sys.argv[1] == "-h":
        Commands.help()
    else:
        Commands.help()