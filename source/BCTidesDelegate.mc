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
        //System.println("onRecieveStationInfo called....");
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
        //System.println("onRecieve called....");
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

        // Data Label Type
        var data_label_setting = Properties.getValue("dataLabelProp");
        var data_label_sub = Rez.Strings.labelSettingValHeight;
        if (data_label_setting == PropUtil.DATA_LABEL_PROP_TIME) {
            data_label_sub = Rez.Strings.labelSettingValTime;
        } else if (data_label_setting == PropUtil.DATA_LABEL_PROP_NONE) {
            data_label_sub = Rez.Strings.labelSettingValNone;
        }
        menu.addItem(
            new WatchUi.MenuItem(
                Rez.Strings.labelSettingTitle, // Label
                data_label_sub, // Sub-Label
                MainMenuDelegate.MENU_SETTINGS_DISP_TYPE_ID, // identifier
                {} // options
            )
        );


        // Units
        /*
        var setting = Properties.getValue("unitsProp");
        var unitsSub = Rez.Strings.unitsSettingSystem;
        if (setting == UNITS_PROP_METRIC) {
            unitsSub = Rez.Strings.unitsSettingMetric;
        } else if (setting == UNITS_PROP_IMPERIAL) {
            unitsSub = Rez.Strings.unitsSettingImperial;
        }
        */
        menu.addItem(
            new WatchUi.MenuItem(
                Rez.Strings.unitsSettingTitle, // Label
                PropUtil.getUnitsString(), // Sub-Label
                MainMenuDelegate.MENU_SETTINGS_UNITS_ID, // identifier
                {} // options
            )
        );

        // Display Mode
        /*
        var display_setting = Properties.getValue("displayProp");
        var display_sub = Rez.Strings.displaySettingValGraph;
        if (display_setting == DISPLAY_PROP_TABLE) {
            display_sub = Rez.Strings.displaySettingValTable;
        }*/
        menu.addItem(
            new WatchUi.MenuItem(
                Rez.Strings.displaySettingTitle, // Label
                PropUtil.getDisplayTypeString(), // Sub-Label
                MainMenuDelegate.MENU_SETTINGS_DISP_MODE_ID, // identifier
                {} // options
            )
        );

        menu.addItem(
            new WatchUi.MenuItem(
                "Get Location", // Label
                "Find GPS", // Sub-Label
                MainMenuDelegate.MENU_SETTINGS_GPS_ID, // identifier
                {} // options
            )
        );
        getDataLabel = new WatchUi.MenuItem(
                "Get Data",
                PropUtil.getStationName(),
                MainMenuDelegate.MENU_GET_DATA,
                {}
            );
        menu.addItem(getDataLabel);
        
        /*
        var zone_setting = Properties.getValue("zoneProp");
        var zone_sub = Rez.Strings.zoneSettingValSouth;
        if (zone_setting == ZONE_PROP_NORTH) {
            zone_sub = Rez.Strings.zoneSettingValNorth;
        }
        */
        menu.addItem(
            new WatchUi.MenuItem(
                Rez.Strings.zoneSettingTitle, // Label
                PropUtil.getZoneString(), // Sub-label
                MainMenuDelegate.MENU_SETTINGS_ZONE_ID,
                {}
            )
        );
        menu.addItem(
            new WatchUi.MenuItem(
                "Select Station",
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
