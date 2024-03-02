import Toybox.Application.Properties;
import Toybox.Lang;

using Toybox.WatchUi;

var getDataLabel;

class BCTidesDelegate extends WatchUi.BehaviorDelegate {
    var mView = null;
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

    function getStationData(station_id as String) as Void {
        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
            :headers => {
                "Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED
            }
        };
        Communications.makeWebRequest( 
            "https://api-iwls.dfo-mpo.gc.ca/api/v1/stations/" + station_id + "/data",
            {
                "time-series-code" => "wlp-hilo",
                "from" => DateUtil.getFromDateString(),
                "to" => DateUtil.getToDateString()
            },
            options,
            method(:onReceive)
        );
    }

    function getStationInfo() as Void {
        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
            :headers => {
                "Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED
            }
        };
        Communications.makeWebRequest(
            "https://api-iwls.dfo-mpo.gc.ca/api/v1/stations/",
            {
                "code" => PropUtil.getStationCode()
            },
            options,
            method(:onReceiveStationInfo)
        );
    }

    function getLocation() as Void {
        mView.onPosition(Toybox.Position.getInfo());
    }

    function onReceiveStationInfo(responseCode as Number, data as Dictionary?) as Void {
        //System.println("onReceiveStationInfo called....");
        //System.println("  responseCode:" + responseCode.toString());
        if (responseCode == 200) { // OK!
            if (data instanceof Array) {
                var station = data[0] as Dictionary;
                var station_id = station["id"].toString();
                //var requested_station_data = station["officialName"].toString();
                getStationData(station_id);
            }
        } else if (responseCode == Communications.BLE_CONNECTION_UNAVAILABLE) {
            // TODO: try Wi-Fi bulk download?
            mView.onReceive("Failed to load\nBLE connection\nunavailable");
        } else {
            mView.onReceive("Failed to load\nError: " + responseCode.toString());
        }
    }

    function onReceive(responseCode as Number, data as Dictionary?) as Void {
        //System.println("onReceive called....");
        //System.println("  responseCode:" + responseCode.toString());
        if (responseCode == 200) { // OK!
            mView.onReceive(data);
        } else if (responseCode == Communications.BLE_CONNECTION_UNAVAILABLE) {
            // TODO: try Wi-Fi bulk download?
            mView.onReceive("Failed to load\nBLE connection\nunavailable");
        } else {
            mView.onReceive("Failed to load\nError: " + responseCode.toString());
        }
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
                "Get Location", // Label
                "Find GPS", // Sub-Label
                MainMenuDelegate.MENU_SETTINGS_GPS_ID, // identifier
                {} // options
            )
        );

        // Get Data
        getDataLabel = new WatchUi.MenuItem(
                Rez.Strings.mainMenuLabelGetData,
                PropUtil.getStationName(),
                MainMenuDelegate.MENU_GET_DATA,
                {}
            );
        menu.addItem(getDataLabel);
        
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
