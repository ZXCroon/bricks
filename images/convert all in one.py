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


filelst = os.listdir('.')
filelst.sort()

offset = {}
width = {}
datalst = []

for filename in filelst:
    if filename.endswith('.jpg') and not filename.endswith('_2v.jpg'):
        img = Image.open(filename)
        w, h = img.size

        txt = ''
        txt += 'WIDTH=9;\nDEPTH=%d;\nADDRESS_RADIX=UNS;\nDATA_RADIX=BIN;\nCONTENT BEGIN\n' % (w * h)
        # offset.append('\tconstant {name}: integer := {pos};'.format(name=filename.replace('.jpg', '_start'), pos=len(datalst)))
        offset[filename.replace('.jpg', '')] = len(datalst)
        width[filename.replace('.jpg', '')] = w

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
foffset = open('../scripts/packages/img_coding_temp.vhd')
template = foffset.read()
foffset.close()
foffset = open('../scripts/packages/img_coding.vhd', 'w')

fout.write('WIDTH=9;\nDEPTH={};\nADDRESS_RADIX=UNS;\nDATA_RADIX=BIN;\nCONTENT BEGIN\n'.format(len(datalst)))
for line in datalst:
    fout.write(line)
fout.write('END;\n')

keys = list(offset.keys())
keys.sort()
offset_txt = ',\n\t\t'.join(map(lambda k: '{} => {}'.format(k, offset[k]), keys))
width_txt = ',\n\t\t'.join(map(lambda k: '{} => {}'.format(k, width[k]), keys))

img_info = ',\n\t\t'.join(keys)
foffset.write(template.format(img_info=img_info, offset=offset_txt, width=width_txt))


####################################################################

offset = {}
width = {}
datalst = []

for filename in filelst:
    if filename.endswith('_2v.jpg'):
        img = Image.open(filename)
        w, h = img.size

        txt = ''
        txt += 'WIDTH=1;\nDEPTH=%d;\nADDRESS_RADIX=UNS;\nDATA_RADIX=BIN;\nCONTENT BEGIN\n' % (w * h)
        # offset.append('\tconstant {name}: integer := {pos};'.format(name=filename.replace('.jpg', '_start'), pos=len(datalst)))
        offset[filename.replace('_2v.jpg', '')] = len(datalst)
        width[filename.replace('_2v.jpg', '')] = w

        for i in range(h):
            for j in range(w):

                r, g, b = img.getpixel((j, i))
                if (r >= 128 and g >= 128 and b >= 128):
                    datalst.append('\t%d:1;\n' % len(datalst))
                    img.putpixel((j, i), (255, 255, 255))
                else:
                    datalst.append('\t%d:0;\n' % len(datalst))
                    img.putpixel((j, i), (0, 0, 0))

        img.save('jpg1/' + filename.replace('_2v.jpg', '.png'))


fout = open('mif/allimg2v.mif', 'w')
foffset = open('../scripts/packages/img_coding2v_temp.vhd')
template = foffset.read()
foffset.close()
foffset = open('../scripts/packages/img_coding2v.vhd', 'w')

fout.write('WIDTH=1;\nDEPTH={};\nADDRESS_RADIX=UNS;\nDATA_RADIX=BIN;\nCONTENT BEGIN\n'.format(len(datalst)))
for line in datalst:
    fout.write(line)
fout.write('END;\n')

keys = list(offset.keys())
keys.sort()
offset_txt = ',\n\t\t'.join(map(lambda k: '{} => {}'.format(k, offset[k]), keys))
width_txt = ',\n\t\t'.join(map(lambda k: '{} => {}'.format(k, width[k]), keys))

img_info = ',\n\t\t'.join(keys)
foffset.write(template.format(img_info2v=img_info, offset=offset_txt, width=width_txt))