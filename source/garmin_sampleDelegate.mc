 
using Toybox.WatchUi;
using Toybox.Timer;
import Toybox.Application.Properties;
import Toybox.Lang;

var getDataLabel;

// A string to display on the screen
var screenMessage = "Press Menu to Enter Text";
var lastText = "";

function getStationCode() as String {
    var code = Properties.getValue("selectedStationCode").format("%05i").toString();
    return code;
}

(:glance)
function getStationName() as String {
    return Properties.getValue("selectedStationName");
}

class MyTextPickerDelegate extends WatchUi.TextPickerDelegate {
    function initialize() {
        TextPickerDelegate.initialize();
    }

    function onTextEntered(text, changed) as Boolean {
        screenMessage = text + "\n" + "Changed: " + changed;
        lastText = text;
        return false;
    }

    function onCancel() as Boolean {
        screenMessage = "Canceled";
        return false;
    }
}

class MyInputDelegate extends WatchUi.InputDelegate {
    function initialize() {
        InputDelegate.initialize();
    }

    function onKey(key) {
        if (WatchUi has :TextPicker) {
            if (key.getKey() == WatchUi.KEY_MENU) {
                WatchUi.pushView(
                    new WatchUi.TextPicker(lastText),
                    new MyTextPickerDelegate(),
                    WatchUi.SLIDE_DOWN
                );
            }
        }
        return true;
    }
}

class NearestStationMenuDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        var all_stations;
        var id = item.getId() as Number;
        if (Properties.getValue("zoneProp") == ZONE_PROP_NORTH) {
            all_stations = WatchUi.loadResource(Rez.JsonData.stationsNorth) as Array<Dictionary>;
        } else {
            all_stations = WatchUi.loadResource(Rez.JsonData.stationsSouth) as Array<Dictionary>;
        }
        var code = all_stations[id]["code"];
        var name = item.getLabel();
        var dist = item.getSubLabel();
        System.println("Selected station " + name + " with code " + code + " and distance " + dist);
        Properties.setValue("selectedStationCode", code);
        Properties.setValue("selectedStationName", name);
        getDataLabel.setSubLabel(name);
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}


class StationMenuDelegate extends WatchUi.Menu2InputDelegate {
    public enum {
        MENU_STATION_NEAREST,
        MENU_STATION_ALPHABETICAL,
        MENU_STATION_SEARCH
    }
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function d2r(d as Float) as Float {
        return d * Math.PI / 180.0f;
    }

    // All input values should be in radians.
    // Retruns the 'distance squared', scaled to a 'unit' sized Earth.
    // Pass through the distance() function to get a distance in kilometers.
    // Only accurate for coordinates around 49 degrees latitude.
    function d2(lat1 as Float, lon1 as Float, lat2 as Float, lon2 as Float) as Float {
        var dlat = lat2 - lat1;
        var dlon = lon2 - lon1;
        var dlon_scale_factor = 0.652; // Should be `cos((lat1 + lat2) / 2)` ; optimized for ~49 deg N
        dlon = dlon * dlon_scale_factor;
        return dlat * dlat + dlon * dlon;
    }

    function distance(d2 as Float) as Float {
        var d = Math.sqrt(d2);
        var r = 6371;
        return d * r;
    }

    function nearestStationMenu(h as HeapOfPair, all_stations as Array<Dictionary>) {
        var menu = new WatchUi.Menu2({:title=>"Nearest"});

        var count = 7;
        for (var i = 0; i < count; i++) {
            var p = h.heapExtractMin();
            var dist = distance(p.distance);
            var station = all_stations[p.index] as Dictionary;
//            System.println(station["name"] + " " + dist.format("%.2f") + "km");
            menu.addItem(
                new WatchUi.MenuItem(
                    station["name"],
                    dist.format("%.2f") + "km",
                    p.index,
                    {}
                )
            );
        }

        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);   

        var delegate = new NearestStationMenuDelegate();
        WatchUi.pushView(menu, delegate, WatchUi.SLIDE_IMMEDIATE);

        return true;
    }


    function onSelect(item) {

        // TODO: search by coordinates?

        if (item.getId() == MENU_STATION_NEAREST) {
            var home_pos = TideUtil.currentPosition.toRadians() as Array;
            var home_lat = home_pos[0]; // d2r(49.267);
            var home_lon = home_pos[1]; // d2r(-123.114);
            //System.println("home coords: " + home_lat + "N " + home_lon + "W");
            // TODO: dynamic list of stations
            // FIXME TODO: New menu level for choosing north or south list???
            var all_stations;
            if (Properties.getValue("zoneProp") == ZONE_PROP_NORTH) {
                all_stations = WatchUi.loadResource(Rez.JsonData.stationsNorth) as Array<Dictionary>;
            } else {
                all_stations = WatchUi.loadResource(Rez.JsonData.stationsSouth) as Array<Dictionary>;
            }
            // TODO: use insertion sort or similar? What about a min heap?
            var size = all_stations.size();
            var h = new HeapOfPair(size);
            for(var i = 0; i < size; i++) {
                var d_squared = d2(home_lat, home_lon, all_stations[i]["lat"], all_stations[i]["lon"]);
                h.minHeapInsert(d_squared, i);
            }
            nearestStationMenu(h, all_stations);
        } else if (item.getId() == MENU_STATION_ALPHABETICAL) {
            // TODO: dynamic list of stations
            // DO this one first, it is easier.
        } else if (item.getId() == MENU_STATION_SEARCH) {
            // TODO: get text input
            var text_picker = new MyInputDelegate();
            text_picker.initialize();
        }
        //WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);   
    }
}

class MainMenuDelegate extends WatchUi.Menu2InputDelegate {
    public enum {
        MENU_SETTINGS_UNITS_ID,
        MENU_SETTINGS_DISP_TYPE_ID,
        MENU_SETTINGS_DISP_MODE_ID,
        MENU_SETTINGS_ZONE_ID,
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
        } else if (item.getId() == MENU_SETTINGS_ZONE_ID) {
            var subLabel = item.getSubLabel();
            if (subLabel.equals(WatchUi.loadResource(Rez.Strings.zoneSettingValNorth))) {
                item.setSubLabel(Rez.Strings.zoneSettingValSouth);
                Properties.setValue("zoneProp", ZONE_PROP_SOUTH);
            } else if (subLabel.equals(WatchUi.loadResource(Rez.Strings.zoneSettingValSouth))) {
                item.setSubLabel(Rez.Strings.zoneSettingValNorth);
                Properties.setValue("zoneProp", ZONE_PROP_NORTH);
            }
        } else if (item.getId() == MENU_SETTINGS_GPS_ID) {
            item.setSubLabel("working");
            _parent.getLocation();
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        } else if (item.getId() == MENU_GET_DATA) {
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
        Communications.makeWebRequest(
            "https://api-iwls.dfo-mpo.gc.ca/api/v1/stations/",
            {
                "code" => getStationCode()
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
        getDataLabel = new WatchUi.MenuItem(
                "Get Data",
                getStationName(),
                MainMenuDelegate.MENU_GET_DATA,
                {}
            );
        menu.addItem(getDataLabel);
        
        var zone_setting = Properties.getValue("zoneProp");
        var zone_sub = Rez.Strings.zoneSettingValSouth;
        if (zone_setting == ZONE_PROP_NORTH) {
            zone_sub = Rez.Strings.zoneSettingValNorth;
        }
        menu.addItem(
            new WatchUi.MenuItem(
                Rez.Strings.zoneSettingTitle, // Label
                zone_sub, // Sub-label
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
