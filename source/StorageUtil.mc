import Toybox.Application;
import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.System;

(:background)
module StorageUtil {
    // Remove element, but keep size constant, and all valid values at the beginning
    function deleteFromArrayByIndex(array as Array, index as Number, valueToInsert) as Array {
        return array.slice(0, index).addAll(array.slice(index + 1, null)).add(valueToInsert);
    }

    function getTideData() as Array<Array<Array>?>? {
        return Storage.getValue("tideData");
    }

    function setTideData(tideData as Array<Array<Array>?>?) as Void {
        Storage.setValue("tideData", tideData);
    }

    function addRecentStation(code as Number, name as String) as Void {
        var recents = getRecentStations();
        if (recents == null) {
            Storage.setValue("recentStations", [[code, name]]);
            return;
        }
        
        for (var i = 0; i < recents.size(); i++) {
            if (code == recents[i][0]) {
                return; // Already have this one in the list
            }
        }
        recents.add([code, name]);
        if (recents.size() > 5) {
            recents = recents.slice(1, null);
        }
        Storage.setValue("recentStations", recents);
    }

    function getRecentStations() as Array<Array<Number or String>> {
        return Storage.getValue("recentStations");
    }

    function getMaxTidesArray() as Array<Float?> {
        var maxTides = Storage.getValue("maxTides") as Array<Float?>;
        if (maxTides == null) {
            maxTides = [];
            for (var i = 0; i < getApp().stationsToShow; i++) {
                maxTides.add(null);
            }
        }
        return maxTides;
    }

    function deleteMaxTide(stationIndex as Number) {
        var maxTides = getMaxTidesArray();
        maxTides = deleteFromArrayByIndex(maxTides, stationIndex, null);
        Storage.setValue("maxTides", maxTides);
    }

    function setMaxTide(stationIndex as Number, maxTide as Float) as Void {
        var maxTides = getMaxTidesArray();
        maxTides[stationIndex] = maxTide;
        Storage.setValue("maxTides", maxTides);
    }

    function getMaxTide(stationIndex as Number) as Float {
        return getMaxTidesArray()[stationIndex];
    }

    function setStation(code as Number?, name as String?, stationIndex as Number) as Void {
        var codes = Storage.getValue("selectedStationCodes") as Array<Number?>?;
        var names = Storage.getValue("selectedStationNames") as Array<String?>?;
        if (code != null && codes != null && stationIndex < codes.size()) {
            for (var i = 0; i < codes.size(); i++) {
                // Don't allow duplicates
                if (code == codes[i]) {
                    return;
                }
            }
        }
        if (names == null || codes == null) {
            names = [];
            codes = [];
            for (var i = 0; i < getApp().stationsToShow; i++) {
                names.add(null);
                codes.add(null);
            }
        }
        if (stationIndex >= getApp().stationsToShow) {
            return;
        }
        if (code == null) {
            // Remove element, and shift up all remaining entries, keeping array size constant
            names = deleteFromArrayByIndex(names, stationIndex, null);
            codes = deleteFromArrayByIndex(codes, stationIndex, null);
            getApp().tideData = deleteFromArrayByIndex(getApp().tideData, stationIndex, null);
            getApp().tideDataValid = deleteFromArrayByIndex(getApp().tideDataValid, stationIndex, false);
            deleteMaxTide(stationIndex);
        } else {
            names[stationIndex] = name;
            codes[stationIndex] = code;
            addRecentStation(code, name);
            getApp().tideDataValid[stationIndex] = false;
            getApp().tideData[stationIndex] = null;
        }
        Storage.setValue("selectedStationCodes", codes);
        Storage.setValue("selectedStationNames", names);
    }

    function getNumValidStationCodes() as Number {
        var codes = Storage.getValue("selectedStationCodes") as Array<Number>?;
        if (codes == null) {
            return 0;
        }
        var count = 0;
        for (var i = 0; i < codes.size(); i++) {
            if (codes[i] != null) {
                count += 1;
            }
        }
        return count;
    }

    function getStationCode(stationIndex as Number) as String? {
        var codes = Storage.getValue("selectedStationCodes") as Array<Number>?;
        if (codes == null || stationIndex > codes.size() || codes[stationIndex] == null) {
            return null;
        }
        return codes[stationIndex].format("%05i").toString();
    }

    (:glance)
    function getStationName(stationIndex as Number) as String {
        var names = Storage.getValue("selectedStationNames") as Array<String>?;
        if (names == null || stationIndex > names.size() || names[stationIndex] == null) {
            return Application.loadResource(Rez.Strings.noStationSelectedStationName);
        }
        return names[stationIndex];
    }
}
