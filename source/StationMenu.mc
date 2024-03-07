import Toybox.Application;
import Toybox.Lang;
import Toybox.Graphics;

using Toybox.WatchUi;

module StationMenu {
    function pushMenu(pageNumber as Number, includeDelete as Boolean) {
        var menu = new WatchUi.CustomMenu(getApp().screenHeight / 3, Graphics.COLOR_WHITE, {
                :title => new CustomMenuTitle(Rez.Strings.selectStationMenuTitle), :theme => null});

        menu.addItem(
            new BasicCustomMenuItem(
                [StationMenuDelegate.MENU_STATION_RECENT, pageNumber], // identifier
                Rez.Strings.selectStationMenuRecent,
                "" // Sub-Label
            )
        );
        menu.addItem(
            new BasicCustomMenuItem(
                [StationMenuDelegate.MENU_STATION_NEAREST, pageNumber], // identifier
                Rez.Strings.selectStationMenuNearest,
                "" // Sub-Label
            )
        );
        menu.addItem(
            new BasicCustomMenuItem(
                [StationMenuDelegate.MENU_STATION_SEARCH, pageNumber], // identifier
                Rez.Strings.selectStationMenuSearch,
                "" // Sub-Label
            )
        );
        if (includeDelete) {
            menu.addItem(
                new BasicCustomMenuItem(
                    [StationMenuDelegate.MENU_STATION_DELETE, pageNumber], // identifier
                    Rez.Strings.selectStationMenuDelete,
                    "" // Sub-Label
                )
            );
        }

        var delegate = new StationMenuDelegate();
        WatchUi.pushView(menu, delegate, WatchUi.SLIDE_IMMEDIATE);

        return true;
    }
}

class StationMenuDelegate extends WatchUi.Menu2InputDelegate {
    public enum {
        MENU_STATION_RECENT,
        MENU_STATION_NEAREST,
        MENU_STATION_SEARCH,
        MENU_STATION_DELETE
    }

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) as Void {
        // TODO: search by coordinates?
        var id = item.getId() as Array<Number>;
        if (id[0] == MENU_STATION_NEAREST) {
            NearestStationMenu.pushNextMenu(Application.loadResource(Rez.Strings.selectStationMenuNearest), null, id[1], 1);
        } else if (id[0] == MENU_STATION_RECENT) {
            RecentStationMenu.pushMenu(id[1]);
        } else if (id[0] == MENU_STATION_SEARCH) {
            SearchStationMenu.pushView("", id[1]);
        } else if (id[0] == MENU_STATION_DELETE) {
            // TODO Push confirmation before deleting?
            StorageUtil.setStation(null, null, id[1]);
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            ManageStationsMenu.pushMenu();
        }
    }
}
