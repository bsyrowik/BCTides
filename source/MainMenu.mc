import Toybox.Application.Properties;
import Toybox.Graphics;
import Toybox.Position;

using Toybox.WatchUi;

class MainMenuDelegate extends WatchUi.Menu2InputDelegate {
    public enum {
        MENU_MANAGE_STATIONS_ID,
        MENU_DISPLAY_OPTIONS_ID,
        MENU_STATION_DATA_ID,
        MENU_GET_GPS_ID
    }

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        if (item.getId() == MENU_GET_GPS_ID) {
            getApp().view.onPosition(Toybox.Position.getInfo());
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        } else if (item.getId() == MENU_MANAGE_STATIONS_ID) {
            ManageStationsMenu.pushMenu();
        } else if (item.getId() == MENU_DISPLAY_OPTIONS_ID) {
            DisplayOptionsMenu.pushMenu();
        } else if (item.getId() == MENU_STATION_DATA_ID) {
            StationDataMenu.pushMenu();
        } else if (item instanceof MultiToggleMenuItem) {
            item.next();
        }
    }
}

module MainMenu {
    function pushMenu() {
        var menu = new WatchUi.CustomMenu(getApp().screenHeight / 3, Graphics.COLOR_WHITE, {
                :title => new CustomMenuTitle(Rez.Strings.mainMenuTitle),
                :theme => null
            });

        // Select Station
        menu.addItem(
            new BasicCustomMenuItem(
                MainMenuDelegate.MENU_MANAGE_STATIONS_ID,
                Rez.Strings.mainMenuLabelManageStations,
                null
            )
        );

        // Display Options
        menu.addItem(
            new BasicCustomMenuItem(
                MainMenuDelegate.MENU_DISPLAY_OPTIONS_ID,
                Rez.Strings.mainMenuLabelDisplayOptions,
                null
            )
        );

        // Station Data
        menu.addItem(
            new BasicCustomMenuItem(
                MainMenuDelegate.MENU_STATION_DATA_ID,
                Rez.Strings.mainMenuLabelStationData,
                null
            )
        );

        // Get Location
        menu.addItem(
            new BasicCustomMenuItem(
                MainMenuDelegate.MENU_GET_GPS_ID,
                Rez.Strings.mainMenuLabelGetLocation,
                Rez.Strings.mainMenuLabelGetLocationSub
            )
        );

        WatchUi.pushView(menu, new MainMenuDelegate(), WatchUi.SLIDE_IMMEDIATE);
    }
}
