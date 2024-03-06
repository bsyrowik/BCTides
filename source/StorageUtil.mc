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

    function setStation(code as Number or Null, name as String or Null, ndx as Number) as Void {
        var codes = Storage.getValue("selectedStationCodes") as Array<Number or Null> or Null;
        var names = Storage.getValue("selectedStationNames") as Array<String or Null> or Null;
        if (code != null && codes != null && ndx < codes.size()) {
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
        if (ndx >= 3) {
            return; // FIXME: error?
        }
        names[ndx] = name;
        codes[ndx] = code;
        if (code == null) {
            System.println("removing element " + ndx + " from " + names);
            // Remove element, and shift up all remaining entries
            names = names.slice(0, ndx).addAll(names.slice(ndx + 1, null)).add(null);
            codes = codes.slice(0, ndx).addAll(codes.slice(ndx + 1, null)).add(null);
            System.println("  --> result: " + names);
        }
        Storage.setValue("selectedStationCodes", codes);
        Storage.setValue("selectedStationNames", names);
        if (code != null) {
            addRecentStation(code, name);
            getApp().tideDataValid = false;  // Fixme: should be array
        }
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

    function getStationCode(ndx as Number) as String or Null {
        var codes = Storage.getValue("selectedStationCodes") as Array<Number> or Null;
        if (codes == null || ndx > codes.size() || codes[ndx] == null) {
            return null;
        }
        return codes[ndx].format("%05i").toString();
    }

    (:glance)
    function getStationName(ndx as Number) as String {
        var names = Storage.getValue("selectedStationNames") as Array<String> or Null;
        if (names == null || ndx > names.size() || names[ndx] == null) {
            return "No station selected"; // FIXME Rez.Strings
        }
        return names[ndx];
    }
}
