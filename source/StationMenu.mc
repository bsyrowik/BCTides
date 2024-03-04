import Toybox.Lang;
import Toybox.Graphics;

using Toybox.WatchUi;

module StationMenu {
    function pushMenu() {
        var menu = new WatchUi.CustomMenu(90, Graphics.COLOR_WHITE, {
                :title => new CustomMenuTitle(Rez.Strings.selectStationMenuTitle)});

        menu.addItem(
            new BasicCustomMenuItem(
                StationMenuDelegate.MENU_STATION_RECENT, // identifier
                Rez.Strings.selectStationMenuRecent,
                "" // Sub-Label
            )
        );
        menu.addItem(
            new BasicCustomMenuItem(
                StationMenuDelegate.MENU_STATION_NEAREST, // identifier
                Rez.Strings.selectStationMenuNearest,
                "" // Sub-Label
            )
        );
        menu.addItem(
            new BasicCustomMenuItem(
                StationMenuDelegate.MENU_STATION_ALPHABETICAL, // identifier
                Rez.Strings.selectStationMenuAlphabetical,
                "" // Sub-Label
            )
        );
        menu.addItem(
            new BasicCustomMenuItem(
                StationMenuDelegate.MENU_STATION_SEARCH, // identifier
                Rez.Strings.selectStationMenuSearch,
                "" // Sub-Label
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
