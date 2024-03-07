import Toybox.Lang;
import Toybox.Graphics;

using Toybox.WatchUi;

module ManageStationsMenu {
    function pushMenu() as Void {
        var menu = new WatchUi.CustomMenu(getApp().screenHeight / 3, Graphics.COLOR_WHITE, {
                :title => new CustomMenuTitle(Rez.Strings.selectStationMenuTitle), :theme => null});

        for (var i = 0; i < getApp().stationsToShow; i++) {
            var stationName = StorageUtil.getStationName(i);
            var stationCode = StorageUtil.getStationCode(i);
            menu.addItem(
                new BasicCustomMenuItem(
                    i, // identifier
                    stationCode == null ? Rez.Strings.manageStationsMenuAdd : stationName,
                    "" // Sub-Label
                )
            );
            if (stationCode == null) {
                break;
            }
        }

        var delegate = new ManageStationsMenuDelegate();
        WatchUi.pushView(menu, delegate, WatchUi.SLIDE_IMMEDIATE);
    }
}

class ManageStationsMenuDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) as Void {
        var addDeleteOption = StorageUtil.getStationCode(item.getId() as Number) != null;
        StationMenu.pushMenu(/*stationIndex*/item.getId() as Number, addDeleteOption);
    }
}
