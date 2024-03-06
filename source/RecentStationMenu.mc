import Toybox.Lang;
import Toybox.Graphics;

using Toybox.WatchUi;

module RecentStationMenu {
    function pushMenu(ndx as Number) as Void {
        var recents = StorageUtil.getRecentStations();
        if (recents == null) {
            return;
        }
        var menu = new WatchUi.CustomMenu(getApp().screenHeight / 3, Graphics.COLOR_WHITE, {
                :title => new CustomMenuTitle(Rez.Strings.selectStationMenuRecent), :theme => null});
        for (var i = recents.size() - 1; i >= 0; i--) {
            menu.addItem(
                new BasicCustomMenuItem(
                    [ndx, recents[i][0]], // ID (station code)
                    recents[i][1], // Station Name
                    ""
                )
            );
        }

        var delegate = new SelectStationMenuDelegate();
        WatchUi.pushView(menu, delegate, WatchUi.SLIDE_IMMEDIATE);
    }
}