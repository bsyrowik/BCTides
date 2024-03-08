import Toybox.Application.Properties;
import Toybox.Graphics;
import Toybox.Position;

using Toybox.WatchUi;

class StationDataMenuDelegate extends WatchUi.Menu2InputDelegate {
    public enum {
        MENU_SETTINGS_ZONE_ID,
        MENU_SETTINGS_ENABLE_BACKGROUND_DL_ID,
        MENU_GET_DATA_ID
    }

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        if (item.getId() == MENU_SETTINGS_ENABLE_BACKGROUND_DL_ID) {
            (item as MultiToggleMenuItem).next();
            // TODO: some action here to control whether or not we download background data?
            // Here, if we set it to "no", we can disable any existing timer?
            // If we set it to "yes", should start the timer...
        } else if (item.getId() == MENU_GET_DATA_ID) {
            GetDataMenu.pushMenu();
        } else if (item instanceof MultiToggleMenuItem) {
            item.next();
        }
    }
}

module StationDataMenu {
    function pushMenu() {
        var menu = new WatchUi.CustomMenu(getApp().screenHeight / 3, Graphics.COLOR_WHITE, {
                :title => new CustomMenuTitle(Rez.Strings.stationDataMenuTitle),
                :theme => null
            });

        // Get Data
        menu.addItem(
            new BasicCustomMenuItem(
                StationDataMenuDelegate.MENU_GET_DATA_ID,
                Rez.Strings.mainMenuLabelGetData,
                ""
            )
        );

        // Background Download
        menu.addItem(
            new MultiToggleMenuItem(
                Rez.Strings.backgroundDownloadSettingTitle,
                [
                    Rez.Strings.no,
                    Rez.Strings.yes
                ],
                StationDataMenuDelegate.MENU_SETTINGS_ENABLE_BACKGROUND_DL_ID,
                "backgroundDownloadProp"
            )
        );

        // Zone
        menu.addItem(
            new MultiToggleMenuItem(
                Rez.Strings.zoneSettingTitle,
                [
                    Rez.Strings.zoneSettingValSouth,
                    Rez.Strings.zoneSettingValNorth
                ],
                StationDataMenuDelegate.MENU_SETTINGS_ZONE_ID,
                "zoneProp"
            )
        );

        WatchUi.pushView(menu, new StationDataMenuDelegate(), WatchUi.SLIDE_IMMEDIATE);
    }
}
