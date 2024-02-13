 
using Toybox.WatchUi;
using Toybox.Timer;
import Toybox.Application.Properties;
import Toybox.Lang;


class StationMenuDelegate extends WatchUi.Menu2InputDelegate {
    public enum {
        MENU_STATION_NEAREST,
        MENU_STATION_ALPHABETICAL,
        MENU_STATION_SEARCH
    }
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        if (item.getId() == MENU_STATION_NEAREST) {
            // TODO: dynamic list of stations
        } else if (item.getId() == MENU_STATION_ALPHABETICAL) {
            // TODO: dynamic list of stations
            // DO this one first, it is easier.
        } else if (item.getId() == MENU_STATION_SEARCH) {
            // TODO: get text input
        }
    }
}

class MainMenuDelegate extends WatchUi.Menu2InputDelegate {
    public enum {
        MENU_SETTINGS_UNITS_ID,
        MENU_SETTINGS_DISP_TYPE_ID,
        MENU_SETTINGS_DISP_MODE_ID,
        MENU_GET_DATA,
        MENU_SET_STATION,
        MENU_SETTINGS_GPS_ID
    }
    private var _parent;
    function initialize(parent) {
        _parent = parent;
        Menu2InputDelegate.initialize();
    }

    function stationMenu() {
        var menu = new WatchUi.Menu2({:title=>"Station"});

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
                "Nearest",  // FIXME: only show N nearest?
                "", // Sub-Label
                StationMenuDelegate.MENU_STATION_NEAREST, // identifier
                {} // options
            )
        );
        menu.addItem(
            new WatchUi.MenuItem(
                "Alphabetical", // Remove?
                "", // Sub-Label
                StationMenuDelegate.MENU_STATION_ALPHABETICAL, // identifier
                {} // options
            )
        );
        menu.addItem(
            new WatchUi.MenuItem(
                "Search", // Show top N results once we've got any input?
                "", // Sub-Label
                StationMenuDelegate.MENU_STATION_SEARCH, // identifier
                {} // options
            )
        );

        var delegate = new StationMenuDelegate();
        WatchUi.pushView(menu, delegate, WatchUi.SLIDE_IMMEDIATE);

        return true;
    }

    function onSelect(item) {
        if (item.getId() == MENU_SETTINGS_UNITS_ID) {
            var subLabel = item.getSubLabel();
            if (subLabel.equals(WatchUi.loadResource(Rez.Strings.unitsSettingSystem))) {
                item.setSubLabel(Rez.Strings.unitsSettingMetric);
                Properties.setValue("unitsProp", UNITS_PROP_METRIC);
            } else if (subLabel.equals(WatchUi.loadResource(Rez.Strings.unitsSettingMetric))) {
                item.setSubLabel(Rez.Strings.unitsSettingImperial);
                Properties.setValue("unitsProp", UNITS_PROP_IMPERIAL);
            } else if (subLabel.equals(WatchUi.loadResource(Rez.Strings.unitsSettingImperial))) {
                item.setSubLabel(Rez.Strings.unitsSettingSystem);
                Properties.setValue("unitsProp", UNITS_PROP_SYSTEM);
            }
        } else if (item.getId() == MENU_SETTINGS_DISP_TYPE_ID) {
            var subLabel = item.getSubLabel();
            if (subLabel.equals(WatchUi.loadResource(Rez.Strings.labelSettingValHeight))) {
                item.setSubLabel(Rez.Strings.labelSettingValTime);
                Properties.setValue("dataLabelProp", DATA_LABEL_PROP_TIME);
            } else if (subLabel.equals(WatchUi.loadResource(Rez.Strings.labelSettingValTime))) {
                item.setSubLabel(Rez.Strings.labelSettingValNone);
                Properties.setValue("dataLabelProp", DATA_LABEL_PROP_NONE);
            } else if (subLabel.equals(WatchUi.loadResource(Rez.Strings.labelSettingValNone))) {
                item.setSubLabel(Rez.Strings.labelSettingValHeight);
                Properties.setValue("dataLabelProp", DATA_LABEL_PROP_HEIGHT);
            }
        } else if (item.getId() == MENU_SETTINGS_DISP_MODE_ID) {
            var subLabel = item.getSubLabel();
            if (subLabel.equals(WatchUi.loadResource(Rez.Strings.displaySettingValGraph))) {
                item.setSubLabel(Rez.Strings.displaySettingValTable);
                Properties.setValue("displayProp", DISPLAY_PROP_TABLE);
            } else if (subLabel.equals(WatchUi.loadResource(Rez.Strings.displaySettingValTable))) {
                item.setSubLabel(Rez.Strings.displaySettingValGraph);
                Properties.setValue("displayProp", DISPLAY_PROP_GRAPH);
            }
        } else if (item.getId() == MENU_SETTINGS_GPS_ID) {
            item.setSubLabel("working");
            _parent.getLocation();
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        } else if (item.getId() == MENU_GET_DATA) {
            //_parent.makeRequest();
            _parent.getStationInfo();
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        } else if (item.getId() == MENU_SET_STATION) {
            stationMenu();
        }
    }
}

class garmin_sampleDelegate extends WatchUi.BehaviorDelegate {
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
        WatchUi.requestUpdate();
        return true;
    }
    function onPreviousPage() {
        if (mView.mPage > 0) {
            mView.mPage -= 1;
        } else {
            mView.mPage = mView.mPageCount - 1;
        }
        WatchUi.requestUpdate();
        return true;
    }

    function makeRequest() as Void {
        var kits = "5cebf1e43d0f4a073c4bc404";
//      var vanc = "5cebf1de3d0f4a073c4bb943";
        getStationData(kits);
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
                "from" => mView.getFromDateString(),
                "to" => mView.getToDateString()
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
        var code = "07707"; // Kitsilano
        //code = "07010"; // Point no Point
        code = "07710"; // False Creek
        Communications.makeWebRequest(
            "https://api-iwls.dfo-mpo.gc.ca/api/v1/stations/",
            {
                "code" => code
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
                var station_id = data[0]["id"].toString();
                var requested_station_data = data[0]["officialName"].toString();
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
        if (data_label_setting == DATA_LABEL_PROP_TIME) {
            data_label_sub = Rez.Strings.labelSettingValTime;
        } else if (data_label_setting == DATA_LABEL_PROP_NONE) {
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
        var setting = Properties.getValue("unitsProp");
        var unitsSub = Rez.Strings.unitsSettingSystem;
        if (setting == UNITS_PROP_METRIC) {
            unitsSub = Rez.Strings.unitsSettingMetric;
        } else if (setting == UNITS_PROP_IMPERIAL) {
            unitsSub = Rez.Strings.unitsSettingImperial;
        }
        menu.addItem(
            new WatchUi.MenuItem(
                Rez.Strings.unitsSettingTitle, // Label
                unitsSub, // Sub-Label
                MainMenuDelegate.MENU_SETTINGS_UNITS_ID, // identifier
                {} // options
            )
        );

        // Display Mode
        var display_setting = Properties.getValue("displayProp");
        var display_sub = Rez.Strings.displaySettingValGraph;
        if (display_setting == DISPLAY_PROP_TABLE) {
            display_sub = Rez.Strings.displaySettingValTable;
        }
        menu.addItem(
            new WatchUi.MenuItem(
                Rez.Strings.displaySettingTitle, // Label
                display_sub, // Sub-Label
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
        menu.addItem(
            new WatchUi.MenuItem(
                "Get Data",
                "wlp-hilo",
                MainMenuDelegate.MENU_GET_DATA,
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
