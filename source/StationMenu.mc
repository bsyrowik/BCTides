import Toybox.Lang;

using Toybox.WatchUi;

module StationMenu {
    function pushMenu() {
        var menu = new WatchUi.Menu2({:title=>Rez.Strings.selectStationMenuTitle});

        menu.addItem(
            new WatchUi.MenuItem(
                Rez.Strings.selectStationMenuRecent,
                "", // Sub-Label
                StationMenuDelegate.MENU_STATION_RECENT, // identifier
                {} // options
            )
        );
        menu.addItem(
            new WatchUi.MenuItem(
                Rez.Strings.selectStationMenuNearest,
                "", // Sub-Label
                StationMenuDelegate.MENU_STATION_NEAREST, // identifier
                {} // options
            )
        );
        menu.addItem(
            new WatchUi.MenuItem(
                Rez.Strings.selectStationMenuAlphabetical,
                "", // Sub-Label
                StationMenuDelegate.MENU_STATION_ALPHABETICAL, // identifier
                {} // options
            )
        );
        menu.addItem(
            new WatchUi.MenuItem(
                Rez.Strings.selectStationMenuSearch,
                "", // Sub-Label
                StationMenuDelegate.MENU_STATION_SEARCH, // identifier
                {} // options
            )
        );

        var delegate = new StationMenuDelegate();
        WatchUi.pushView(menu, delegate, WatchUi.SLIDE_IMMEDIATE);

        return true;
    }
}

class StationMenuDelegate extends WatchUi.Menu2InputDelegate {
    public enum {
        MENU_STATION_RECENT,
        MENU_STATION_NEAREST,
        MENU_STATION_ALPHABETICAL,
        MENU_STATION_SEARCH
    }

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) as Void {
        // TODO: search by coordinates?
        if (item.getId() == MENU_STATION_NEAREST) {
            NearestStationMenu.pushNextMenu("Nearest", null, 1);
        } else if (item.getId() == MENU_STATION_RECENT) {
            RecentStationMenu.pushMenu();
        } else if (item.getId() == MENU_STATION_ALPHABETICAL) {
            // TODO: dynamic list of stations
        } else if (item.getId() == MENU_STATION_SEARCH) {
            // TODO: get text input
            /*
            var text_picker = new MyInputDelegate();
            text_picker.initialize();
            */
        }
    }
}
