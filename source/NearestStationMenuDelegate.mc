import Toybox.Lang;
import Toybox.Application.Properties;

using Toybox.WatchUi;

class NearestStationMenuDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        var all_stations = RezUtil.getStationData() as Array<Dictionary>;
        var id = item.getId() as Number;
        var code = all_stations[id]["code"];
        var name = item.getLabel();
        var dist = item.getSubLabel();
        System.println("Selected station " + name + " with code " + code + " and distance " + dist);
        Properties.setValue("selectedStationCode", code);  // FIXME: #9 These should be in "Storage", not "Properties"
        Properties.setValue("selectedStationName", name);
        TideUtil.dataValid = false; // FIXME: #8 only invalidate when we're actually changing the station!
        getDataLabel.setSubLabel(name);
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}
