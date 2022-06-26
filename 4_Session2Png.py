
import numpy
from PIL import Image
import binascii
import errno    
import os
import time
import shutil
from setup import *
from utils import mkdir_p

def getMatrixfrom_pcap(filename, width):
    with open(filename, 'rb') as f:
        content = f.read()
    
    hexst = binascii.hexlify(content)  
    fh = numpy.array([int(hexst[i : i + 2], 16) for i in range(0, len(hexst), 2)])  
    rn = len(fh) // width
    fh = numpy.reshape(fh[: rn * width], (-1, width))  
    fh = numpy.uint8(fh)
    return fh

def main():
    interval = []
    paths = [['Dataset/3_Standard_Dataset/TrimedSession/Train', 'Dataset/4_Image_Dataset/Train'], ['Dataset/3_Standard_Dataset/TrimedSession/Test', 'Dataset/4_Image_Dataset/Test']]

    for p in paths:
        dict_dev = {}
        if os.path.exists(p[1]) == True:
            shutil.rmtree(p[1])
        os.makedirs(p[1])
        for i, d in enumerate(os.listdir(p[0])):
            dir_full = os.path.join(p[1], str(i))
            print('[INFO] Saving image %s in: %s' % (d, dir_full))
            dict_dev[i] = d
            mkdir_p(dir_full)
            print()
            for f in os.listdir(os.path.join(p[0], d)):
                start = time.time()
                bin_full = os.path.join(p[0], d, f)
                im = Image.fromarray(getMatrixfrom_pcap(bin_full, PNG_SIZE))
                png_full = os.path.join(dir_full, os.path.splitext(f)[0] + '.png')
                im.save(png_full)
                end = time.time()
                interval.append(end - start)
        print(dict_dev)
    
    total = 0
    for i in interval:
        total += i
    print(total / len(interval))


''' ENTRY POINT '''
if __name__ == "__main__":
    main()