import Toybox.Lang;
import Toybox.Application.Storage;

using Toybox.WatchUi;

class SelectStationMenuDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        var code = item.getId() as Number;
        var name = item.getLabel();
        StorageUtil.setStation(code, name);
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}
