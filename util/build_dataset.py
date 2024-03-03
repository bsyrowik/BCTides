import json
import re
#import simplejson
import requests

from pathlib import Path
from math import radians

#from json import encoder
#encoder.FLOAT_REPR = lambda o: format(o, '.5f')

raw_data_file = "stations_PAC_wlp-hilo.json"
#raw_data_file = "stations_PAC_wlp-hilo-startDate.json"
output_file = "stations_PAC_small_rad.json"
#output_file = "stations_PAC_small_startDate.json"

output_dir = "../resources/data/"

use_radians = True

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

with open(raw_data_file) as f:
    new_data = []
    data = json.load(f)
    for station in data:
        n = station["officialName"]
        c = station["code"]
        lat = station["latitude"]
        lon = station["longitude"]
        if use_radians:
            lat, lon = map(radians, [lat, lon])
        new_data.append({"name":clean_name(n), "code":c, "lat":lat, "lon":lon})

    print(len(new_data), " stations")
    print("Max name length: ", max_name_len, " ", longest_name)

    with open(output_dir + output_file, 'w') as out_file:
        #json.dump(pretty_floats(new_data), out_file, indent=2)
        #json.dump(new_data, out_file, indent=2)
        #out_file.write(json.dumps(pretty_floats(new_data), indent=1))
        out_file.write(json.dumps(json.loads(json.dumps(new_data), parse_float=lambda x: round(float(x), 6)), indent=2))

