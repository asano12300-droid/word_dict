import sys
import Scripts

def command():
    if len(sys.argv) < 2:
        grade = input("何級ですか？ :ex)２級 -> 2q(半角): ")
        select = input("1.追加 2.検索 3.一覧 \n何をしますか？: ")
        if select == "1": 
            Scripts.add(grade)
        elif select == "2":
            word = input("検索したい単語: ")
            Scripts.search(grade, word)
        elif select == "3":
            Scripts.list(grade)
        else:
            print("無効な操作です。")
    elif sys.argv[1] == "-d":
        if not sys.argv[2]:
            print("何級か選択してください")
        else:
            Scripts.list(grade=sys.argv[2])
    elif sys.argv[1] == "-a":
        if not sys.argv[2]:
            print("何級か選択してください")
        else:
            Scripts.add(grade=sys.argv[2])
    elif sys.argv[1] == "-s":
        if not sys.argv[2]:
            print("何級か選択してください")
        else:
            if not sys.argv[3]:
                print("検索したい単語を指定してください")
            else:
                Scripts.search(grade=sys.argv[2], word=sys.argv[3])
    elif sys.argv[1] == "-h":
        Scripts.help()
    else:
        Scripts.help()