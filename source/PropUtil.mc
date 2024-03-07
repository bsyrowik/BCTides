import Toybox.Application.Properties;
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

    function toggle(propName as String) as Void {
        Properties.setValue(propName, !Properties.getValue(propName));
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

    (:glance)
    function units() as String {
        if (getUnits() == System.UNIT_STATUTE) {
            return "ft";
        }
        return "m";
    }

    (:glance)
    function heightMultiplier() as Float {
        if (getUnits() == System.UNIT_STATUTE) {
            return 3.28084;  // Feet per meter
        }
        return 1.0f;
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
    
    function toggleBackgroundDownload() {
        toggle("backgroundDownloadProp");
    }

    function getBackgroundDownload() as Boolean {
        return Properties.getValue("backgroundDownloadProp");
    }
}