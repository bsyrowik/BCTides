import Toybox.Lang;

using Toybox.WatchUi;

module RezUtil {
    var stationNameTag = "n";
    var stationCodeTag = "c";
    var stationLonTag  = "x";
    var stationLatTag  = "y";

    function getStationData() as Array<Dictionary> {
        if (PropUtil.getStationZone() == PropUtil.ZONE_PROP_NORTH) {
            return WatchUi.loadResource(Rez.JsonData.stationsNorth) as Array<Dictionary>;
        } else {
            return WatchUi.loadResource(Rez.JsonData.stationsSouth) as Array<Dictionary>;
        }
    }

    function getStationDataFromCode(code as Number) as Dictionary {
        // Station data should be sorted by code - do a simple binary search to find it
        var data = getStationData();
        var low = 0;
        var high = data.size();
        var mid = 0;
        while (low <= high) {
            mid = (low + high) / 2;
            if (data[mid][stationCodeTag] == code) {
                break;
            }
            if (data[mid][stationCodeTag] < code) {
                low = mid + 1;
            } else {
                high = mid - 1;
            }
        }
        return data[mid];
    }
}
