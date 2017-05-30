from PIL import Image
import sys
import os

def bin3(x):
    s = bin(x)[2:];
    if (len(s) == 0):
        return '000'
    if (len(s) == 1):
        return '00' + s
    if (len(s) == 2):
        return '0' + s
    return s

for filename in os.listdir():
    if filename.endswith('.jpg'):
      img = Image.open(filename)
      w, h = img.size
      txt = ''
      txt += 'WIDTH=9;\nDEPTH=%d;\nADDRESS_RADIX=UNS;\nDATA_RADIX=BIN;\nCONTENT BEGIN\n' % (w * h)
      for i in range(h):
          for j in range(w):
              r, g, b = img.getpixel((j, i))
              r = r // 32 * 32
              g = g // 32 * 32
              b = b // 32 * 32
              img.putpixel((j, i), (r, g, b))

              txt += '\t%d:%s%s%s;\n' % (i * w + j, bin3(r // 32), bin3(g // 32), bin3(b // 32))
      img.save('jpg3/' + filename)
      txt += 'END;\n'
      f = open('mif/' + filename[:-4] + '.mif', 'w')
      f.write(txt)
      f.close()
