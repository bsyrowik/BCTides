import Toybox.Application.Properties;
import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.System;

(:background)
module PropUtil {
    public enum unitsPropSettings {
        UNITS_PROP_SYSTEM,
        UNITS_PROP_METRIC,
        UNITS_PROP_IMPERIAL
    }

    public enum dataLabelPropSettings {
        DATA_LABEL_PROP_HEIGHT,
        DATA_LABEL_PROP_TIME,
        DATA_LABEL_PROP_NONE
    }

    public enum displayPropSettings {
        DISPLAY_PROP_GRAPH,
        DISPLAY_PROP_TABLE
    }

    public enum zonePropSettings {
        ZONE_PROP_SOUTH,
        ZONE_PROP_NORTH
    }

    function addRecentStation(code as Number, name as String) as Void {
        var recents = getRecentStations();
        if (recents == null) {
            Storage.setValue("recentStations", [[code, name]]);
            return;
        }
        
        for (var i = 0; i < recents.size(); i++) {
            if (code == recents[i][0]) {
                return; // Already have this one in the list
            }
        }
        recents.add([code, name]);
        if (recents.size() > 5) {
            recents = recents.slice(1, null);
        }
        Storage.setValue("recentStations", recents);
    }

    function getRecentStations() as Array<Array<Number or String>> {
        return Storage.getValue("recentStations");
    }

    function setStation(code as Number, name as String) as Void {
        if (code == Storage.getValue("selectedStationCode")) {
            return;
        }
        Storage.setValue("selectedStationCode", code);
        Storage.setValue("selectedStationName", name);
        addRecentStation(code, name);
        TideUtil.dataValid = false;
        getApp().delegate.setGetDataMenuItemSubLabel(name);
    }

    function getStationCode() as String or Null {
        var code = Storage.getValue("selectedStationCode");
        if (code == null) {
            return null;
        }
        return code.format("%05i").toString();
    }

    (:glance)
    function getStationName() as String {
        var name = Storage.getValue("selectedStationName");
        return name == null ? "No station selected" : name;
    }

    (:glance)
    function getUnits() as System.UnitsSystem {
        var setting = Properties.getValue("unitsProp");
        if (setting == UNITS_PROP_SYSTEM) {
            return System.getDeviceSettings().elevationUnits;
        } else if (setting == UNITS_PROP_METRIC) {
            return System.UNIT_METRIC;
        } else {
            return System.UNIT_STATUTE;
        }
    }

    function getUnitsString() as String {
        var setting = Properties.getValue("unitsProp");
        var unitsSub = Rez.Strings.unitsSettingSystem as String;
        if (setting == UNITS_PROP_METRIC) {
            unitsSub = Rez.Strings.unitsSettingMetric as String;
        } else if (setting == UNITS_PROP_IMPERIAL) {
            unitsSub = Rez.Strings.unitsSettingImperial as String;
        }
        return unitsSub;
    }

    function graphLabelType() as Number {
        return Properties.getValue("dataLabelProp");
    }

    function getDataLabelString() as String {
        var data_label_setting = Properties.getValue("dataLabelProp");
        var data_label_sub = Rez.Strings.labelSettingValHeight as String;
        if (data_label_setting == PropUtil.DATA_LABEL_PROP_TIME) {
            data_label_sub = Rez.Strings.labelSettingValTime as String;
        } else if (data_label_setting == PropUtil.DATA_LABEL_PROP_NONE) {
            data_label_sub = Rez.Strings.labelSettingValNone as String;
        }
        return data_label_sub;
    }

    function getDisplayType() as Number {
        return Properties.getValue("displayProp");
    }

    function getDisplayTypeString() as String {
        var display_setting = Properties.getValue("displayProp");
        var display_sub = Rez.Strings.displaySettingValGraph as String;
        if (display_setting == DISPLAY_PROP_TABLE) {
            display_sub = Rez.Strings.displaySettingValTable as String;
        }
        return display_sub;
    }

    function getStationZone() as Number {
        return Properties.getValue("zoneProp");
    }

    function getZoneString() as String {
        var zone_setting = Properties.getValue("zoneProp");
        var zone_sub = Rez.Strings.zoneSettingValSouth as String;
        if (zone_setting == ZONE_PROP_NORTH) {
            zone_sub = Rez.Strings.zoneSettingValNorth as String;
        }
        return zone_sub;
    }
}