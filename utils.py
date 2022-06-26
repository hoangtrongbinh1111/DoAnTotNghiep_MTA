import os
import errno 

def extractListDeviceToJSON(fileDevice):
    dict_mac = {}
    with open(fileDevice) as file:
        text = file.read()
        result = text.strip().split('\n')
        for row in result[2:]: # remove title so we start from index 2
            res = row.split('\t') # Name - MAC - connection type
            device_name = (res[0] + ('_' + res[2] if len(res) == 3 else '')).strip()
            mac_addr = res[1].strip()
            dict_mac[mac_addr] = device_name
    return dict_mac

def mkdir_Device_MAC(list_device, path_device):
    for mac, device in list_device.items():
        dir_full = os.path.join(path_device, device)
        try:
            if os.path.exists(dir_full) == False:
                os.makedirs(dir_full)
        except OSError as exc:
            if exc.errno == errno.EEXIST and os.path.isdir(dir_full):
                pass
            else:
                raise

def mkdir_p(path):
    try:
        os.makedirs(path)
    except OSError as exc:
        if exc.errno == errno.EEXIST and os.path.isdir(path):
            pass
        else:
            raise