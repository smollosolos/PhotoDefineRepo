from PIL import Image
from PIL import ImageGrab
import pytesseract
import os

#pyinstaller main.py --onefile

txtpath = os.path.join(os.getcwd() + r'\arg.txt')
path = os.path.join(os.getcwd() + r'\Tesseract-OCR\tesseract')
pytesseract.pytesseract.tesseract_cmd = path


def get_img():
    return ImageGrab.grabclipboard()


def convert_to_string(img) -> str:
    if img:
        return pytesseract.image_to_string(img)
    else:
        return "NAN"


def read_files_in_directory(directory):
    if os.path.isfile(directory):
        return Image.open(directory)


with open(txtpath, 'r') as file:
    imgpath: str = file.readlines()[0]

imgpath = imgpath[:-1]

if os.path.exists(imgpath):
    image = read_files_in_directory(imgpath)
    if not image:
        image = get_img()
else:
    image = get_img()

print(convert_to_string(image))
