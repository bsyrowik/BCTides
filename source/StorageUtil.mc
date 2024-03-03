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

    function setStation(code as Number, name as String) as Void {
        if (code == Storage.getValue("selectedStationCode")) {
            return;
        }
        Storage.setValue("selectedStationCode", code);
        Storage.setValue("selectedStationName", name);
        addRecentStation(code, name);
        getApp().tideDataValid = false;
        getApp().delegate.setGetDataMenuItemSubLabel(name);
    }

    function getStationCode() as String or Null {
        var code = Storage.getValue("selectedStationCode");
        if (code == null) {
            return null;
        }
        return code.format("%05i").toString();
    }

    (:glance)
    function getStationName() as String {
        var name = Storage.getValue("selectedStationName");
        return name == null ? "No station selected" : name;
    }
}
