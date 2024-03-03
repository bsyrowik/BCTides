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
        var menu = new WatchUi.Menu2({:title=>"Settings"});
        var delegate;

        // Data Label
        menu.addItem(
            new WatchUi.MenuItem(
                Rez.Strings.labelSettingTitle, // Label
                PropUtil.getDataLabelString(), // Sub-Label
                MainMenuDelegate.MENU_SETTINGS_DISP_TYPE_ID, // identifier
                {} // options
            )
        );

        // Units
        menu.addItem(
            new WatchUi.MenuItem(
                Rez.Strings.unitsSettingTitle, // Label
                PropUtil.getUnitsString(), // Sub-Label
                MainMenuDelegate.MENU_SETTINGS_UNITS_ID, // identifier
                {} // options
            )
        );

        // Display Mode
        menu.addItem(
            new WatchUi.MenuItem(
                Rez.Strings.displaySettingTitle, // Label
                PropUtil.getDisplayTypeString(), // Sub-Label
                MainMenuDelegate.MENU_SETTINGS_DISP_MODE_ID, // identifier
                {} // options
            )
        );

        // Get Location
        menu.addItem(
            new WatchUi.MenuItem(
                Rez.Strings.mainMenuLabelGetLocation, // Label
                Rez.Strings.mainMenuLabelGetLocationSub, // Sub-Label
                MainMenuDelegate.MENU_SETTINGS_GPS_ID, // identifier
                {} // options
            )
        );

        // Get Data
        mGetDataMenuItem = new WatchUi.MenuItem(
                Rez.Strings.mainMenuLabelGetData,
                PropUtil.getStationName(),
                MainMenuDelegate.MENU_GET_DATA,
                {}
            );
        menu.addItem(mGetDataMenuItem);
        
        // Zone
        menu.addItem(
            new WatchUi.MenuItem(
                Rez.Strings.zoneSettingTitle,
                PropUtil.getZoneString(),
                MainMenuDelegate.MENU_SETTINGS_ZONE_ID,
                {}
            )
        );

        // Select Station
        menu.addItem(
            new WatchUi.MenuItem(
                Rez.Strings.mainMenuLabelSelectStation,
                "",
                MainMenuDelegate.MENU_SET_STATION,
                {}
            )
        );

        delegate = new MainMenuDelegate(self);
        WatchUi.pushView(menu, delegate, WatchUi.SLIDE_IMMEDIATE);

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
