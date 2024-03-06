import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.System;

(:background)
module StorageUtil {
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

    function deleteMaxTide(stationIndex as Number) {
        var maxTides = Storage.getValue("maxTides") as Array<Float or Null>;
        if (maxTides == null) {
            maxTides = [null, null, null]; // FIXME: hardcoded 3....
        }
        maxTides = maxTides.slice(0, stationIndex).addAll(maxTides.slice(stationIndex + 1, null)).add(null);
        Storage.setValue("maxTides", maxTides);
    }

    function setMaxTide(stationIndex as Number, maxTide as Float) as Void {
        var maxTides = Storage.getValue("maxTides") as Array<Float>;
        if (maxTides == null) {
            maxTides = [null, null, null]; // FIXME: hardcoded 3....
        }
        maxTides[stationIndex] = maxTide;
        Storage.setValue("maxTides", maxTides);
    }

    function getMaxTide(stationIndex as Number) as Float {
        var maxTides = Storage.getValue("maxTides") as Array<Float>;
        if (maxTides == null) {
            maxTides = [null, null, null]; // FIXME: hardcoded 3....
        }
        return maxTides[stationIndex];
    }

    function setStation(code as Number or Null, name as String or Null, stationIndex as Number) as Void {
        var codes = Storage.getValue("selectedStationCodes") as Array<Number or Null> or Null;
        var names = Storage.getValue("selectedStationNames") as Array<String or Null> or Null;
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
            // Initialize to size of 3  // FIXME: get this from a global var or something, instead of hard-coding 3
            for (var i = 0; i < 3; i++) {
                names.add(null);
                codes.add(null);
            }
        }
        if (stationIndex >= 3) {
            return; // FIXME: error?
        }
        if (code == null) {
            System.println("removing element " + stationIndex + " from " + names);
            // Remove element, and shift up all remaining entries
            names = names.slice(0, stationIndex).addAll(names.slice(stationIndex + 1, null)).add(null);
            codes = codes.slice(0, stationIndex).addAll(codes.slice(stationIndex + 1, null)).add(null);
            var tdv = getApp().tideDataValid as Array<Boolean>;
            getApp().tideDataValid = tdv.slice(0, stationIndex).addAll(tdv.slice(stationIndex + 1, null)).add(false);
            var data = getApp().tideData as Array<Array<Array> or Null>;
            getApp().tideData = data.slice(0, stationIndex).addAll(data.slice(stationIndex + 1, null)).add(null);
            deleteMaxTide(stationIndex);
        } else {
            names[stationIndex] = name;
            codes[stationIndex] = code;
            addRecentStation(code, name);
            getApp().tideDataValid[stationIndex] = false;
            getApp().tideData[stationIndex] = null;
        }
        System.println("  --> result: " + names);
        Storage.setValue("selectedStationCodes", codes);
        Storage.setValue("selectedStationNames", names);
    }

    function getNumValidStationCodes() as Number {
        var codes = Storage.getValue("selectedStationCodes") as Array<Number> or Null;
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

    function getStationCode(stationIndex as Number) as String or Null {
        var codes = Storage.getValue("selectedStationCodes") as Array<Number> or Null;
        if (codes == null || stationIndex > codes.size() || codes[stationIndex] == null) {
            return null;
        }
        return codes[stationIndex].format("%05i").toString();
    }

    (:glance)
    function getStationName(stationIndex as Number) as String {
        var names = Storage.getValue("selectedStationNames") as Array<String> or Null;
        if (names == null || stationIndex > names.size() || names[stationIndex] == null) {
            return "No station selected"; // FIXME Rez.Strings
        }
        return names[stationIndex];
    }
}
