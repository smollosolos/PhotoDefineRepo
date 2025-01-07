import requests
import os

#pyinstaller main.py --onefile
txtpath = os.path.join(os.getcwd() + r'\arg.txt')
definitions = []


with open(txtpath, 'r', encoding="utf8") as file:
    for line in file:
        response = requests.get('https://en.wikipedia.org/w/api.php?action=query&origin=*&prop=revisions&rvprop=content&format=json&titles=' + line.strip())
        r = response.json()
        idd = list(r["query"]["pages"].keys())[0]
        info = r["query"]["pages"][idd]["revisions"][0]["*"]
        new_title = line.strip().replace("_"," ").replace("%27","'")
        if ("'''" + new_title) in info:
            start: int = info.find("'''" + new_title)
            info = info[start:]
            info = info[0 : info.find("\n")]
            definitions.append(info + "\n")
        else:
            start: int = info.find("'''")
            info = info[start:]
            info = info[0 : info.find("\n")]
            definitions.append(info + "\n")

file1 = open(txtpath, 'w', encoding="utf-8")
file1.writelines(definitions)
file1.close()
