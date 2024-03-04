import Toybox.Application.Properties;
import Toybox.Graphics;
import Toybox.Position;

using Toybox.WatchUi;

class MainMenuDelegate extends WatchUi.Menu2InputDelegate {
    public enum {
        MENU_SETTINGS_UNITS_ID,
        MENU_SETTINGS_DISP_TYPE_ID,
        MENU_SETTINGS_DISP_MODE_ID,
        MENU_SETTINGS_ZONE_ID,
        MENU_GET_DATA,
        MENU_SET_STATION,
        MENU_SETTINGS_GPS_ID,
        MENU_SETTINGS_ENABLE_BACKGROUND_DL
    }

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        if (item.getId() == MENU_SETTINGS_GPS_ID) {
            getApp().view.onPosition(Toybox.Position.getInfo());
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        } else if (item.getId() == MENU_SETTINGS_ENABLE_BACKGROUND_DL) {
            (item as MultiToggleMenuItem).next();
            // TODO: some action here to control whether or not we download background data?
            // Here, if we set it to "no", we can disable any existing timer?
            // If we set it to "yes", should start the timer...
        } else if (item.getId() == MENU_GET_DATA) {
            WebRequests.getStationInfo();
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            if (StorageUtil.getStationCode() == null) {
                Notification.showNotification(WatchUi.loadResource(Rez.Strings.noStationSelectedMessage), 2000);
            }
        } else if (item.getId() == MENU_SET_STATION) {
            StationMenu.pushMenu();
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
        
        // Data Label
        menu.addItem(
            new MultiToggleMenuItem(
                Rez.Strings.labelSettingTitle,
                [
                    Rez.Strings.labelSettingValHeight,
                    Rez.Strings.labelSettingValTime,
                    Rez.Strings.labelSettingValNone
                ],
                MainMenuDelegate.MENU_SETTINGS_DISP_TYPE_ID,
                "dataLabelProp"
            )
        );

        // Units
        menu.addItem(
            new MultiToggleMenuItem(
                Rez.Strings.unitsSettingTitle,
                [
                    Rez.Strings.unitsSettingSystem,
                    Rez.Strings.unitsSettingMetric,
                    Rez.Strings.unitsSettingImperial
                ],
                MainMenuDelegate.MENU_SETTINGS_UNITS_ID,
                "unitsProp"
            )
        );

        // Display Mode
        menu.addItem(
            new MultiToggleMenuItem(
                Rez.Strings.displaySettingTitle,
                [
                    Rez.Strings.displaySettingValGraph,
                    Rez.Strings.displaySettingValTable
                ],
                MainMenuDelegate.MENU_SETTINGS_DISP_MODE_ID,
                "displayProp"
            )
        );

        // Get Location
        menu.addItem(
            new BasicCustomMenuItem(
                MainMenuDelegate.MENU_SETTINGS_GPS_ID,
                Rez.Strings.mainMenuLabelGetLocation,
                Rez.Strings.mainMenuLabelGetLocationSub
            )
        );

        // Get Data
        var getDataMenuItem = new BasicCustomMenuItem(
                MainMenuDelegate.MENU_GET_DATA,
                Rez.Strings.mainMenuLabelGetData,
                StorageUtil.getStationName()
            );
        menu.addItem(getDataMenuItem);

        // Background Download
        menu.addItem(
            new MultiToggleMenuItem(
                Rez.Strings.backgroundDownloadSettingTitle,
                [
                    Rez.Strings.no,
                    Rez.Strings.yes
                ],
                MainMenuDelegate.MENU_SETTINGS_ENABLE_BACKGROUND_DL,
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
                MainMenuDelegate.MENU_SETTINGS_ZONE_ID,
                "zoneProp"
            )
        );

        // Select Station
        menu.addItem(
            new BasicCustomMenuItem(
                MainMenuDelegate.MENU_SET_STATION,
                Rez.Strings.mainMenuLabelSelectStation,
                null
            )
        );

        WatchUi.pushView(menu, new MainMenuDelegate(), WatchUi.SLIDE_IMMEDIATE);
        return getDataMenuItem;
    }
}

