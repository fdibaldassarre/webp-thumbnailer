#!/usr/bin/env python3

import sys
from PIL import Image

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Too few arguments")
    source = sys.argv[1]
    target = sys.argv[2]
    print(source, target)
    if len(sys.argv) == 4:
        size = int(sys.argv[3])
    else:
        size = 256
    image = Image.open(source)
    w, h = image.size
    if w > h:
        ratio = h / w
        new_width = size
        new_height = int(new_width * ratio)
    else:
        ratio = w / h
        new_height = size
        new_width = int(new_height * ratio)
    thumb = image.resize((new_width, new_height))
    thumb.save(target, format="png")
