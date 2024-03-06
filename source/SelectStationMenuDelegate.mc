import Toybox.Lang;
import Toybox.Application.Storage;

using Toybox.WatchUi;

class SelectStationMenuDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        var indexAndCode = item.getId() as Array<Number>;
        var index = indexAndCode[0];
        var code = indexAndCode[1];
        var name = item.getLabel() as String;
        StorageUtil.setStation(code, name, index);

        // From here we want to go back to the ManageStationsMenu, *but* we want to redraw it
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        ManageStationsMenu.pushMenu();
    }
}
