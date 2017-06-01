from PIL import Image
import sys, os


size = 0
wordsize = 9

for fname in os.listdir('.'):
    if fname.endswith('.jpg'):
        img = Image.open(fname)
        w, h = img.size
        size += w*h

print('total image size is {} bits, {} words'.format(size*wordsize, size))