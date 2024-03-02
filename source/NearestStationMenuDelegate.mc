import Toybox.Lang;
import Toybox.Application.Storage;

using Toybox.WatchUi;

class NearestStationMenuDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        var stationList = RezUtil.getStationData() as Array<Dictionary>;
        var code = stationList[item.getId() as Number]["code"];
        var name = item.getLabel();
        PropUtil.setStation(code, name);
        getDataLabel.setSubLabel(name);
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}
