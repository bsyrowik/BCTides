# cSpell: disable
import json
import re
#import simplejson
import requests

from pathlib import Path
from math import radians

#from json import encoder
#encoder.FLOAT_REPR = lambda o: format(o, '.5f')

region = "PAC" # "TEST" # PAC, ATL, QUE
use_radians = True
split_NS = True

raw_data_file = "stations_" + region + "_wlp-hilo.json"
#raw_data_file = "stations_PAC_wlp-hilo-startDate.json"
output_file = "stations_" + region + "_small_" + ("rad" if use_radians else "deg")
#output_file = "stations_PAC_small_startDate.json"

output_dir = "../resources/data/"

def get_raw_data():
    url = "https://api.iwls-sine.azure.cloud-nuage.dfo-mpo.gc.ca/api/v1/stations?chs-region-code=PAC&time-series-code=wlp-hilo"
    #url = "https://api.iwls-sine.azure.cloud-nuage.dfo-mpo.gc.ca/api/v1/stations?chs-region-code=PAC&time-series-code=wlp-hilo&dateStart=2024-01-01T00%3A00%3A00Z&dateEnd=2024-02-02T00%3A00%3A00Z"
    '''
       API seems broken when you add start/end date - only gives 38 stations.
       From looking at other stations, there _is_ data for the other stations too...
    '''
    response = requests.get(url)
    if response.status_code != 200:
        print("Got bad status code from API request: ", response.status_code)
        exit(1)
    data = response.json()
    with open(raw_data_file, 'w') as f:
        json.dump(data, f, indent=4)

if not Path(raw_data_file).is_file():
    # TODO: also check how old the file is
    print("Getting data from API")
    get_raw_data()
else:
    print("Using file on disk")


#class PrettyFloat(float):
#    def __repr__(self):
#        return '%.2f' % self
#
#def pretty_floats(obj):
#    if isinstance(obj, float):
#        return PrettyFloat(obj)
#    elif isinstance(obj, dict):
#        return dict((k, pretty_floats(v)) for k, v in obj.items())
#    elif isinstance(obj, (list, tuple)):
#        return list(map(pretty_floats, obj))
#    return obj

max_name_len = 0
longest_name = ""

def clean_name(name):
    global max_name_len
    global longest_name
    name = name.replace("  ", " ")
    name = name.replace(".", "")
    name = name.replace("Harbour", "Hbr")
    name = name.replace("Islands", "Is")
    name = name.replace("Island", "Is")
    name = re.sub(r'North\b', 'N', name)
    name = re.sub(r'South\b', 'S', name)
    name = re.sub(r'East\b', 'E', name)
    name = re.sub(r'West\b', 'W', name)
    name = name.strip()
    if len(name) > max_name_len:
        max_name_len = len(name)
        longest_name = name
    return name

nameTag = "n"
codeTag = "c"
lonTag  = "x"
latTag  = "y"

with open(raw_data_file) as f:
    new_data_north = []
    new_data_south = []
    data = json.load(f)
    for station in data:
        n = station["officialName"]
        c = int(station["code"])
        lat = station["latitude"]
        lon = station["longitude"]
        north = split_NS and lat > 51
        if use_radians:
            lat, lon = map(radians, [lat, lon])
        if north:
            new_data_north.append({nameTag:clean_name(n), codeTag:c, latTag:lat, lonTag:lon})
        else:
            new_data_south.append({nameTag:clean_name(n), codeTag:c, latTag:lat, lonTag:lon})

    new_data_north = sorted(new_data_north, key=lambda d: d[codeTag])
    new_data_south = sorted(new_data_south, key=lambda d: d[codeTag])

    print(len(new_data_north), " stations in the north")
    print(len(new_data_south), " stations in the south")
    print("Max name length: ", max_name_len, " ", longest_name)

    #with open(output_dir + output_file + ".json", 'w') as out_file:
        #json.dump(pretty_floats(new_data), out_file, indent=2)
        #json.dump(new_data, out_file, indent=2)
        #out_file.write(json.dumps(pretty_floats(new_data), indent=1))
        #out_file.write(json.dumps(json.loads(json.dumps(new_data), parse_float=lambda x: round(float(x), 6)), indent=2))
        #pass

    if split_NS:
        with open(output_dir + output_file + "_north.json", 'w') as out_file:
            print("Writing", len(new_data_north), "stations to", output_file + "_north.json")
            out_file.write(json.dumps(json.loads(json.dumps(new_data_north), parse_float=lambda x: round(float(x), 6)), separators=(',', ':')))

        with open(output_dir + output_file + "_south.json", 'w') as out_file:
            print("Writing", len(new_data_south), "stations to", output_file + "_south.json")
            out_file.write(json.dumps(json.loads(json.dumps(new_data_south), parse_float=lambda x: round(float(x), 6)), separators=(',', ':')))
    else:
        with open(output_dir + output_file + ".json", 'w') as out_file:
            print("Writing", len(new_data_south), "stations to", output_file + ".json")
            out_file.write(json.dumps(json.loads(json.dumps(new_data_south), parse_float=lambda x: round(float(x), 6)), separators=(',', ':')))

