import Toybox.Application.Properties;
import Toybox.Lang;
import Toybox.System;

class PropUtil {
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

    static function getStationCode() as String {
        var code = Properties.getValue("selectedStationCode").format("%05i").toString();
        return code;
    }

    static function getStationZone() as Number {
        return Properties.getValue("zoneProp");
    }

    (:glance)
    static function getStationName() as String {
        return Properties.getValue("selectedStationName");
    }

    (:glance)
    static function getUnits() as System.UnitsSystem {
        var setting = Properties.getValue("unitsProp");
        if (setting == UNITS_PROP_SYSTEM) {
            return System.getDeviceSettings().elevationUnits;
        } else if (setting == UNITS_PROP_METRIC) {
            return System.UNIT_METRIC;
        } else {
            return System.UNIT_STATUTE;
        }
    }

    static function graphLabelType() as Number {
        return Properties.getValue("dataLabelProp");
    }

    static function getDisplayType() as Number {
        return Properties.getValue("displayProp");
    }

    static function getUnitsString() as String {
        var setting = Properties.getValue("unitsProp");
        var unitsSub = Rez.Strings.unitsSettingSystem as String;
        if (setting == UNITS_PROP_METRIC) {
            unitsSub = Rez.Strings.unitsSettingMetric as String;
        } else if (setting == UNITS_PROP_IMPERIAL) {
            unitsSub = Rez.Strings.unitsSettingImperial as String;
        }
        return unitsSub;
    }

    static function getDisplayTypeString() as String {
        var display_setting = Properties.getValue("displayProp");
        var display_sub = Rez.Strings.displaySettingValGraph as String;
        if (display_setting == DISPLAY_PROP_TABLE) {
            display_sub = Rez.Strings.displaySettingValTable as String;
        }
        return display_sub;
    }

    static function getZoneString() as String {
        var zone_setting = Properties.getValue("zoneProp");
        var zone_sub = Rez.Strings.zoneSettingValSouth as String;
        if (zone_setting == ZONE_PROP_NORTH) {
            zone_sub = Rez.Strings.zoneSettingValNorth as String;
        }
        return zone_sub;
    }
}