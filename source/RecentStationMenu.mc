import Toybox.Lang;

using Toybox.WatchUi;

module RecentStationMenu {
    function pushMenu() as Void {
        var recents = StorageUtil.getRecentStations();
        if (recents == null) {
            return;
        }
        var menu = new WatchUi.Menu2({:title=>Rez.Strings.selectStationMenuRecent});
        for (var i = recents.size() - 1; i >= 0; i--) {
            menu.addItem(
                new WatchUi.MenuItem(
                    recents[i][1], // Station Name
                    "",
                    recents[i][0], // Station Code
                    {} // options
                )
            );
        }

        var delegate = new SelectStationMenuDelegate();
        WatchUi.pushView(menu, delegate, WatchUi.SLIDE_IMMEDIATE);
    }
}