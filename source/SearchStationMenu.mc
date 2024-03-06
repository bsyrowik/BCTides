import Toybox.Lang;
import Toybox.Graphics;
import Toybox.System;

using Toybox.WatchUi;

class MyTextPickerDelegate extends WatchUi.TextPickerDelegate {
    var _ndx as Number;

    function initialize(ndx) {
        TextPickerDelegate.initialize();
        _ndx = ndx;
    }

    function onTextEntered(text as String, changed as Boolean) as Boolean {
        SearchStationMenu.enteredText = text;
        if (text.length() < 2) {        
            // 1) Get rid of this picker view
            // 2) Add a new picker initialized with this text
            // 3) add notification
            // 4) add sacrificial view that will get dismissed when we exit this function
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            SearchStationMenu.pushView(text, _ndx);
            Notification.showNotification("Must be at least 2 characters.", 2000);
            WatchUi.pushView(new WatchUi.View(), new WatchUi.BehaviorDelegate(), WatchUi.SLIDE_IMMEDIATE); // Sacrificial view
        } else {
            // 1) Get rid of this picker view
            // 2) Add search results menu
            // 3) add sacrificial view that will get dismissed when we exit this function
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            SearchStationMenu.pushListMenu(_ndx);
            WatchUi.pushView(new WatchUi.View(), new WatchUi.BehaviorDelegate(), WatchUi.SLIDE_IMMEDIATE); // Sacrificial view
        }
        return false;
    }

    function onCancel() as Boolean {
        System.println("Canceled");
        return false;
    }
}

module SearchStationMenu {
    var enteredText = "" as String;
    var needle;
    function pushView(startingText, ndx as Number) {
        WatchUi.pushView(new WatchUi.TextPicker(startingText), new MyTextPickerDelegate(ndx), WatchUi.SLIDE_IMMEDIATE);
    }

    function pushListMenu(ndx as Number) {
        needle = enteredText.toLower();
        pushListMenuHelper("Search\nResults", 0, ndx, 1);
    }

    function pushListMenuHelper(title as String, startIndex as Number, ndx as Number, depth as Number) as Void {
        var stationList = RezUtil.getStationData() as Array<Dictionary>;
        var stationsToShow = 7;

        var menu = new LoadMoreMenu(title, "Page " + (depth + 1), getApp().screenHeight / 3, Graphics.COLOR_WHITE, {:theme => null});

        var i = startIndex;
        var stationsAdded = 0;
        for (; i < stationList.size(); i++) {
            var name = stationList[i]["name"].toLower();
            if (name.find(needle) != null) {
                menu.addItem(
                    new BasicCustomMenuItem(
                        [ndx, stationList[i]["code"]],
                        stationList[i]["name"],
                        ""
                    )
                );
                stationsAdded += 1;
                if (stationsAdded >= stationsToShow) {
                    i++;
                    break;
                }
            }
        }

        var allowWrap = true;
        // Don't show footer if we've gone through the entire list
        if (i >= stationList.size()) {
            menu.disableFooter();
            allowWrap = false;
        }

        if (stationsAdded > 0) {
            var delegate = new LoadMoreMenuDelegate(new Lang.Method(SearchStationMenu, :pushListMenuHelper), i, ndx, depth, allowWrap, true);
            WatchUi.pushView(menu, delegate, WatchUi.SLIDE_IMMEDIATE);
        } else {
            if (depth == 1) {
                // No results at all - go back to text picker
                SearchStationMenu.pushView(enteredText, ndx);
                Notification.showNotification("No results!", 2000);
            } else {
                Notification.showNotification("No more results!", 2000);
            }
        }
    }
}
