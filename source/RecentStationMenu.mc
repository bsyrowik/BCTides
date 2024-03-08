import Toybox.Lang;
import Toybox.Graphics;

using Toybox.WatchUi;

module RecentStationMenu {
    function pushMenu(stationIndex as Number) as Void {
        var recents = StorageUtil.getRecentStations();
        if (recents == null) {
            return;
        }
        var menu = new WatchUi.CustomMenu(getApp().screenHeight / 3, Graphics.COLOR_WHITE, {
                :title => new CustomMenuTitle(Rez.Strings.selectStationMenuRecent), :theme => null});
        for (var i = recents.size() - 1; i >= 0; i--) {
            var distance = NearestStationMenu.getDistanceToStation(recents[i][0]);
            menu.addItem(
                new BasicCustomMenuItem(
                    [stationIndex, recents[i][0]], // ID (station code)
                    recents[i][1], // Station Name
                    distance.format("%.2f") + "km"
                )
            );
        }

        var delegate = new SelectStationMenuDelegate();
        WatchUi.pushView(menu, delegate, WatchUi.SLIDE_IMMEDIATE);
    }
}