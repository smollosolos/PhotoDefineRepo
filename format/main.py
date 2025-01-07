import os
#pyinstaller main.py --onefile

# thanks to pradyunsg for a function
# https://stackoverflow.com/a/14598135
def a(test_str):
    ret = ''
    skip1c = 0
    skip2c = 0
    for i in test_str:
        if i == '{':
            skip1c += 1
        elif i == '<':
            skip2c += 1
        elif i == '}' and skip1c > 0:
            skip1c -= 1
        elif i == '>'and skip2c > 0:
            skip2c -= 1
        elif skip1c == 0 and skip2c == 0:
            ret += i
    return ret

txtpath = os.path.join(os.getcwd() + r'\temp.txt')
formatted_def = ""

with open(txtpath, 'r', encoding="utf8") as file:
    if file:
        formatted_def = file.readlines()[0]

formatted_def = a(formatted_def)
while "[[" in formatted_def:
    start = formatted_def.find("[[")
    section = formatted_def[start: formatted_def.find("]]") + 2]
    if "|" in section:
        srt = section.find("|") + 1
        formatted_def = formatted_def.replace(section, section[srt: section.find("]]")])
    else:
        formatted_def = formatted_def.replace("[[", "", 1).replace("]]", "", 1)
print(formatted_def.replace("\'\'\'", "").replace("\'", "’"))
