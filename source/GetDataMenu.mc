import Toybox.Lang;
import Toybox.Graphics;

using Toybox.WatchUi;

module GetDataMenu {
    function pushMenu() {
        var validStationCount = StorageUtil.getNumValidStationCodes();
        if (validStationCount == 0) {
            Notification.showNotification("No stations selected!", 2000);
            return;
        }

        var menu = new WatchUi.CustomMenu(getApp().screenHeight / 3, Graphics.COLOR_WHITE, {
                :title => new CustomMenuTitle("Get Data"), :theme => null});

        if (validStationCount > 1) {
            menu.addItem(
                new BasicCustomMenuItem(
                    -1, // Identifier
                    "All",
                    "" // Sub-Label
                )
            );
        }

        for (var i = 0; i < 3; i++) { // FIXME: don't hardcode 3 here
            var stationName = StorageUtil.getStationName(i);
            var stationCode = StorageUtil.getStationCode(i);
            if (stationCode == null) {
                continue;
            }
            menu.addItem(
                new BasicCustomMenuItem(
                    i, // identifier
                    stationName,
                    "" // Sub-Label
                )
            );
        }

        var delegate = new GetDataMenuDelegate();
        WatchUi.pushView(menu, delegate, WatchUi.SLIDE_IMMEDIATE);
    }
}

class GetDataMenuDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) as Void {
        var id = item.getId() as Number;
        if (id == -1) {
            // Get all
            for (var i = 0; i < StorageUtil.getNumValidStationCodes(); i++) {
                if (StorageUtil.getStationCode(i) != null) {
                    WebRequests.getStationInfo(i);
                }
            }
        } else {
            WebRequests.getStationInfo(id);
            // Get for a specific station
        }
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}
