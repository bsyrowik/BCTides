using Toybox.WatchUi;
import Toybox.Application.Properties;

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