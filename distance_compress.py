import json



from math import radians, cos, sin, asin, sqrt

def haversine(lon1, lat1, lon2, lat2):
    """
    https://stackoverflow.com/questions/4913349/haversine-formula-in-python-bearing-and-distance-between-two-gps-points
    https://en.wikipedia.org/wiki/Haversine_formula
    Calculate the great circle distance in kilometers between two points
    on the earth (specified in decimal degrees)
    """
    # convert decimal degrees to radians
    lon1, lat1, lon2, lat2 = map(radians, [lon1, lat1, lon2, lat2])

    # haversine formula
    dlon = lon2 - lon1
    dlat = lat2 - lat1
    a = sin(dlat/2)**2 + cos(lat1) * cos(lat2) * sin(dlon/2)**2
    c = 2 * asin(sqrt(a))
    r = 6371 # Radius of earth in kilometers. Use 3956 for miles. Determines return value units.
    return c * r

def est16(lon1, lat1, lon2, lat2):

    return 1

def naive(lon1, lat1, lon2, lat2):
    # convert decimal degrees to radians
    lon1, lat1, lon2, lat2 = map(radians, [lon1, lat1, lon2, lat2])
    d = sqrt((lon2 - lon1)**2 + (lat2 - lat1)**2)
    r = 6371 # Radius of earth in kilometers. Use 3956 for miles. Determines return value units.
    return d * r

def naive2(lon1, lat1, lon2, lat2):
    """
    https://en.wikipedia.org/wiki/Geographical_distance#Spherical_Earth_projected_to_a_plane
    """
    # convert decimal degrees to radians
    lon1, lat1, lon2, lat2 = map(radians, [lon1, lat1, lon2, lat2])
    mean_lat = (lat2 + lat1) / 2
    d = sqrt((lat2 - lat1)**2 + (cos(mean_lat) * (lon2 - lon1))**2)
    r = 6371 # Radius of earth in kilometers. Use 3956 for miles. Determines return value units.
    return d * r

def naive3(lon1, lat1, lon2, lat2):
    """
    https://en.wikipedia.org/wiki/Geographical_distance#Spherical_Earth_projected_to_a_plane
    """
    # convert decimal degrees to radians
    lon1, lat1, lon2, lat2 = map(radians, [lon1, lat1, lon2, lat2])
    mean_lat = (lat2 + lat1) / 2
    # BS FIXME: all our mean latitudes are going to be pretty close...
    # BS TODO: dividing by 2 is **probably** good enough (right shift by 1)
    d = sqrt((lat2 - lat1)**2 + (0.652 * (lon2 - lon1))**2)
    #print("mean_lat: ", mean_lat, " cos(mean_lat): ", cos(mean_lat))
    r = 6371 # Radius of earth in kilometers. Use 3956 for miles. Determines return value units.
    return d * r

data = []

#with open("response_1707718371665.json") as f:
with open("small.json") as f:
    d = json.load(f)
    for s in d:
        data.append({"officialName" : s["officialName"], "latitude": s["latitude"], "longitude": s["longitude"], "code": s["code"]})

print("data size: ", len(d))

home_lat = 49.27
home_lon = -123.114


print("{:20} {:12} {:12}".format("Home", home_lat, home_lon))

for d in data:
    h = haversine(home_lon, home_lat, d["longitude"], d["latitude"])
    e = est16(home_lon, home_lat, d["longitude"], d["latitude"])
    n = naive(home_lon, home_lat, d["longitude"], d["latitude"])
    n2 = naive2(home_lon, home_lat, d["longitude"], d["latitude"])
    n3 = naive3(home_lon, home_lat, d["longitude"], d["latitude"])
    print("{:20} {:12} {:12} {:12.3f}km {:12.3f}km {:12.3f}km   error:{:5.1f}%".format(d["officialName"], radians(d["latitude"]), radians(d["longitude"] + 90), h, n2, n3, (n3 - h)/h *100))

