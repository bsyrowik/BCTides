import Toybox.Lang;
import Toybox.Graphics;

using Toybox.WatchUi;

module GetDataMenu {
    enum {
        GET_ALL_STATIONS_ID = -1
    }

    function pushMenu() {
        var validStationCount = StorageUtil.getNumValidStationCodes();
        if (validStationCount == 0) {
            Notification.showNotification(Rez.Strings.noStationSelectedMessage, 2000);
            return;
        }

        var menu = new WatchUi.CustomMenu(getApp().screenHeight / 3, Graphics.COLOR_WHITE, {
                :title => new CustomMenuTitle(Rez.Strings.mainMenuLabelGetData), :theme => null});

        if (validStationCount > 1) {
            // Add menu option to download data for all stations
            menu.addItem(
                new BasicCustomMenuItem(
                    GET_ALL_STATIONS_ID, // Identifier
                    Rez.Strings.getDataMenuAll,
                    "" // Sub-Label
                )
            );
        }

        for (var i = 0; i < getApp().stationsToShow; i++) {
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
        if (id == GetDataMenu.GET_ALL_STATIONS_ID) {
            // Get data for all stations
            WebRequests.downloadAllStationData();
        } else {
            // Get data for a specific station
            WebRequests.downloadStationData(id);
        }
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}
