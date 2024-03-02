import Toybox.Lang;
import Toybox.Application.Storage;

using Toybox.WatchUi;

class NearestStationMenuDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        var stationList = RezUtil.getStationData() as Array<Dictionary>;
        var id = item.getId() as Number;
        var code = stationList[id]["code"];
        var name = item.getLabel();
        //var dist = item.getSubLabel();
        //System.println("Selected station " + name + " with code " + code + " and distance " + dist);
        //Storage.setValue("selectedStationCode", code);  // FIXME: #9 These should be in "Storage", not "Properties"
        //Storage.setValue("selectedStationName", name);
        PropUtil.setStation(code, name);
        getDataLabel.setSubLabel(name);
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}
