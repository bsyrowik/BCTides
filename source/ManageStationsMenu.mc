import Toybox.Lang;
import Toybox.Graphics;

using Toybox.WatchUi;

module ManageStationsMenu {
    function pushMenu() {
        var menu = new WatchUi.CustomMenu(getApp().screenHeight / 3, Graphics.COLOR_WHITE, {
                :title => new CustomMenuTitle(Rez.Strings.selectStationMenuTitle), :theme => null});

        menu.addItem(
            new BasicCustomMenuItem(
                0, // identifier
                StorageUtil.getStationName(),
                "" // Sub-Label
            )
        );
        menu.addItem(
            new BasicCustomMenuItem(
                1, // identifier
                "+ Add",
                "" // Sub-Label
            )
        );
        menu.addItem(
            new BasicCustomMenuItem(
                2, // identifier
                "+ Add",
                "" // Sub-Label
            )
        );

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
        StationMenu.pushMenu(/*pageNumber*/item.getId() as Number, /* includeDelete */(item.getId() == 0));
    }
}
