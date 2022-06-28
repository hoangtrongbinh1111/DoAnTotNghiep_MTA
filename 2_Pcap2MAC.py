import os
import shutil
import time
import binascii
from scapy.all import rdpcap
from scapy.error import Scapy_Exception
from setup import *
from utils import extractListDeviceToJSON, mkdir_Device_MAC

def loadPcap(pcap):
    if os.path.isfile(pcap):
        try:
            packet = rdpcap(pcap)
            src_mac = None
            for frame in packet: # packet is 1
                src_mac = frame['Ether']
                break
            return src_mac.src
        except Scapy_Exception as msg:
            print(str(msg))
    else:
        print('You sure that \'s the right file location???') 

'''
    Statistic number of files in folder
'''
def statisticFile(pcap_dir):
    print('------ Number of files in folder ------')
    sum = 0
    for item in os.listdir(pcap_dir):
        dir_item = os.path.join(pcap_dir, item)
        sumDir = len(os.listdir(dir_item))
        if sumDir == 0:
            os.rmdir(dir_item)
        else:
            sum += sumDir
            print(item, sumDir)
    print(f'Total file: {sum} files')

'''
    Convert Hex to binary
'''
def standard_Bin(pcap_file, pcap_new_file):
    with open(pcap_file, "r") as f:
        data = f.read()
        if data != "":
            data = data.strip().replace(':',' ').replace('\n','')
            data = binascii.unhexlify(''.join(data.split()))
            with open(pcap_new_file, "wb") as file:
                file.write(data)

def splitByMAC(pcap_dir, dict_mac):
    counter = 0
    for item in os.listdir(pcap_dir):
        source_dir_item = os.path.join(pcap_dir, item)
        try:
            src_MAC = loadPcap(source_dir_item)
            if src_MAC in dict_mac:
                if dict_mac[src_MAC] == "Non-IoT_Wireless":
                    if counter >= LIMIT_FILE_PCAP:
                        continue
                    counter = counter + 1
                des_dir = os.path.join(PATH_GROUP_BY_MAC, dict_mac[src_MAC])
                des_dir_item = os.path.join(des_dir, item)
                pcap_new_file = os.path.join(des_dir, f"iot_{counter}.bin")
                if os.path.exists(des_dir_item) == False:
                    os.system(f"tshark -2 -r {source_dir_item} -T fields -e tcp.payload > {des_dir_item}")
                    standard_Bin(des_dir_item, pcap_new_file)
        except:
            continue
        if counter % 1000 == 0:
            print("Loading in ")
    print('------ Done split by MAC address ------')

def main():
    # extract device
    dict_Device_by_MAC = extractListDeviceToJSON(LIST_DEVICE)
    mkdir_Device_MAC(dict_Device_by_MAC, PATH_GROUP_BY_MAC)
    splitByMAC(PCAP_DIR, dict_Device_by_MAC)
    statisticFile(PATH_GROUP_BY_MAC)

'''
    Run function main() to group pcap by source MAC address
'''
main()