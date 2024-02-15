using Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Application.Properties;

class NearestStationMenuDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        var all_stations;
        var id = item.getId() as Number;
        if (Properties.getValue("zoneProp") == ZONE_PROP_NORTH) {
            all_stations = WatchUi.loadResource(Rez.JsonData.stationsNorth) as Array<Dictionary>;
        } else {
            all_stations = WatchUi.loadResource(Rez.JsonData.stationsSouth) as Array<Dictionary>;
        }
        var code = all_stations[id]["code"];
        var name = item.getLabel();
        var dist = item.getSubLabel();
        System.println("Selected station " + name + " with code " + code + " and distance " + dist);
        Properties.setValue("selectedStationCode", code);
        Properties.setValue("selectedStationName", name);
        getDataLabel.setSubLabel(name);
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}

