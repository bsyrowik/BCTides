import Toybox.Lang;
import Toybox.Graphics;

using Toybox.WatchUi;

module RecentStationMenu {
    function pushMenu() as Void {
        var recents = StorageUtil.getRecentStations();
        if (recents == null) {
            return;
        }
        var menu = new WatchUi.CustomMenu(90, Graphics.COLOR_WHITE, {
                :title => new CustomMenuTitle(Rez.Strings.selectStationMenuRecent)});
        for (var i = recents.size() - 1; i >= 0; i--) {
            menu.addItem(
                new BasicCustomMenuItem(
                    recents[i][0], // ID (station code)
                    recents[i][1], // Station Name
                    ""
                )
            );
        }

        var delegate = new SelectStationMenuDelegate();
        WatchUi.pushView(menu, delegate, WatchUi.SLIDE_IMMEDIATE);
    }
}