import Toybox.Lang;
import Toybox.Graphics;

using Toybox.WatchUi;

module ManageStationsMenu {
    function pushMenu() {
        var menu = new WatchUi.CustomMenu(getApp().screenHeight / 3, Graphics.COLOR_WHITE, {
                :title => new CustomMenuTitle(Rez.Strings.selectStationMenuTitle), :theme => null});

        for (var i = 0; i < 3; i++) { // FIXME: don't hardcode 3 here
            var stationName = StorageUtil.getStationName(i);
            var stationCode = StorageUtil.getStationCode(i);
            menu.addItem(
                new BasicCustomMenuItem(
                    i, // identifier
                    stationCode == null ? "+ Add" : stationName,
                    "" // Sub-Label
                )
            );
            if (stationCode == null) {
                break;
            }
        }

        var delegate = new ManageStationsMenuDelegate();
        WatchUi.pushView(menu, delegate, WatchUi.SLIDE_IMMEDIATE);

        return true;
    }
}

class ManageStationsMenuDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) as Void {
        System.println("Configuring station " + item.getId());
        StationMenu.pushMenu(/*pageNumber*/item.getId() as Number, /* includeDelete */(StorageUtil.getStationCode(item.getId() as Number) != null));
    }
}
