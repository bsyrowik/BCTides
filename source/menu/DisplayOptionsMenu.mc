import Toybox.Application.Properties;
import Toybox.Graphics;
import Toybox.Position;

using Toybox.WatchUi;

class DisplayOptionsMenuDelegate extends WatchUi.Menu2InputDelegate {
    public enum {
        MENU_SETTINGS_UNITS_ID,
        MENU_SETTINGS_DISP_TYPE_ID,
        MENU_SETTINGS_FILL_GRAPH_ID,
        MENU_SETTINGS_DISP_MODE_ID
    }

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        (item as MultiToggleMenuItem).next();
    }
}

module DisplayOptionsMenu {
    function pushMenu() {
        var menu = new WatchUi.CustomMenu(getApp().screenHeight / 3, Graphics.COLOR_WHITE, {
                :title => new CustomMenuTitle(Rez.Strings.displayOptionsMenuTitle),
                :theme => null
            });

        // Data Label
        menu.addItem(
            new MultiToggleMenuItem(
                Rez.Strings.labelSettingTitle,
                [
                    Rez.Strings.labelSettingValHeight,
                    Rez.Strings.labelSettingValTime,
                    Rez.Strings.labelSettingValNone
                ],
                null,
                "dataLabelProp"
            )
        );

        // Units
        menu.addItem(
            new MultiToggleMenuItem(
                Rez.Strings.unitsSettingTitle,
                [
                    Rez.Strings.unitsSettingSystem,
                    Rez.Strings.unitsSettingMetric,
                    Rez.Strings.unitsSettingImperial
                ],
                null,
                "unitsProp"
            )
        );

        // Display Mode
        menu.addItem(
            new MultiToggleMenuItem(
                Rez.Strings.displaySettingTitle,
                [
                    Rez.Strings.displaySettingValGraph,
                    Rez.Strings.displaySettingValTable
                ],
                null,
                "displayProp"
            )
        );

        // Fill Graph
        menu.addItem(
            new MultiToggleMenuItem(
                Rez.Strings.fillGraphTitle,
                [
                    Rez.Strings.no,
                    Rez.Strings.yes
                ],
                null,
                "fillGraphProp"
            )
        );

        WatchUi.pushView(menu, new DisplayOptionsMenuDelegate(), WatchUi.SLIDE_IMMEDIATE);
    }
}