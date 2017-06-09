from PIL import Image
import os

for filename in os.listdir():
    if filename.endswith('.jpg'):
        img = Image.open(filename)
        w, h = img.size

        txt = 'WIDTH=2;\nDEPTH=%d;\nADDRESS_RADIX=UNS;\nDATA_RADIX=BIN;\nCONTENT BEGIN\n' % (w * h)

        s = ''
        k = 0
        str = ''
        for i in range(h):
            for j in range(w):
                r, g, b = img.getpixel((j, i))
                if r > 100:
                    if g > 100:
                        s = '01'
                    else:
                        s = '10'
                elif r < 20 and g < 20 and b < 20:
                    s = '00'
                else:
                    s = '11'

                txt += '\t%d:%s;\n' % (k, s)
                str += s
                k += 1
        txt += 'END;\n'

        with open(filename.replace('.jpg', '.mif'), 'w') as f:
            f.write(txt)

        print(filename, str)