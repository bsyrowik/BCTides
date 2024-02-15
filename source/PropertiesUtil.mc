import Toybox.Application.Properties;
import Toybox.Lang;
import Toybox.System;


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

function getStationCode() as String {
    var code = Properties.getValue("selectedStationCode").format("%05i").toString();
    return code;
}

(:glance)
function getStationName() as String {
    return Properties.getValue("selectedStationName");
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

function graphLabelType() as Number {
    return Properties.getValue("dataLabelProp");
}

function getDisplayType() as Number {
    return Properties.getValue("displayProp");
}