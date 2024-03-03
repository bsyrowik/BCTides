import Toybox.Application.Properties;
import Toybox.Lang;

using Toybox.WatchUi;

class BCTidesDelegate extends WatchUi.BehaviorDelegate {
    var mView = null;
    private var mGetDataMenuItem = null;

    function initialize(view) {
        mView = view;
		WatchUi.BehaviorDelegate.initialize();
	}

    function onNextPage() {
        if (mView.mPage < mView.mPageCount - 1) {
            mView.mPage += 1;
        } else {
            mView.mPage = 0;
        }
        mView.mPageUpdated = true;
        WatchUi.requestUpdate();
        return true;
    }

    function onPreviousPage() {
        if (mView.mPage > 0) {
            mView.mPage -= 1;
        } else {
            mView.mPage = mView.mPageCount - 1;
        }
        mView.mPageUpdated = true;
        WatchUi.requestUpdate();
        return true;
    }

    function getLocation() as Void {
        mView.onPosition(Toybox.Position.getInfo());
    }

    function setGetDataMenuItemSubLabel(name as String) as Void {
        mGetDataMenuItem.setSubLabel(name);
    }

    function onMenu() {
        var menu = new WatchUi.CustomMenu(90, Graphics.COLOR_WHITE, {
                :foreground=>new Rez.Drawables.MenuForeground(),
                :title => new CustomMenuTitle("Settings")
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
                MainMenuDelegate.MENU_SETTINGS_GPS_ID, // identifier
                Rez.Strings.mainMenuLabelGetLocation, // Label
                Rez.Strings.mainMenuLabelGetLocationSub // Sub-Label
            )
        );

        // Get Data
        mGetDataMenuItem = new BasicCustomMenuItem(
                MainMenuDelegate.MENU_GET_DATA,
                Rez.Strings.mainMenuLabelGetData,
                StorageUtil.getStationName()
            );
        menu.addItem(mGetDataMenuItem);

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

        WatchUi.pushView(menu, new MainMenuDelegate(self), WatchUi.SLIDE_IMMEDIATE);
        return true;
    }

	function onStateUpdated(state) {
		WatchUi.requestUpdate();
	}

	function onSelect() {
		onMenu();
        return true;
	}
}   
