from PIL import Image
import sys
import os


def bin3(x):
    s = bin(x)[2:]
    if len(s) == 0:
        return '000'
    if len(s) == 1:
        return '00' + s
    if len(s) == 2:
        return '0' + s
    return s


offset = []
datalst = []
filelst = os.listdir('.')
filelst.sort()

for filename in filelst:
    if filename.endswith('.jpg'):
        img = Image.open(filename)
        w, h = img.size

        txt = ''
        txt += 'WIDTH=9;\nDEPTH=%d;\nADDRESS_RADIX=UNS;\nDATA_RADIX=BIN;\nCONTENT BEGIN\n' % (w * h)
        offset.append('\tconstant {name}: integer := {pos};'.format(name=filename.replace('.jpg', '_start'), pos=len(datalst)))

        for i in range(h):
            for j in range(w):
                r, g, b = img.getpixel((j, i))
                r = r // 32 * 32
                g = g // 32 * 32
                b = b // 32 * 32
                img.putpixel((j, i), (r, g, b))
                datalst.append('\t%d:%s%s%s;\n' % (len(datalst), bin3(r // 32), bin3(g // 32), bin3(b // 32)))

        img.save('jpg3/' + filename.replace('.jpg', '.png'))


fout = open('mif/allimg.mif', 'w')
foffset = open('../scripts/packages/img_offset_temp.vhd')
template = foffset.read()
foffset.close()
foffset = open('../scripts/packages/img_offset.vhd', 'w')

fout.write('WIDTH=9;\nDEPTH={};\nADDRESS_RADIX=UNS;\nDATA_RADIX=BIN;\nCONTENT BEGIN\n'.format(len(datalst)))
for line in datalst:
    fout.write(line)
fout.write('END;\n')

foffset.write(template.format('\n'.join(offset)))