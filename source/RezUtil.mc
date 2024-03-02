import Toybox.Lang;

using Toybox.WatchUi;

module RezUtil {
    function getStationData() as Array<Dictionary> {
        if (PropUtil.getStationZone() == PropUtil.ZONE_PROP_NORTH) {
            return WatchUi.loadResource(Rez.JsonData.stationsNorth) as Array<Dictionary>;
        } else {
            return WatchUi.loadResource(Rez.JsonData.stationsSouth) as Array<Dictionary>;
        }
    }

    function getNoDataForStationString() as Array<String> {
        var part0 = WatchUi.loadResource(Rez.Strings.noDataAvailableForStation0) as String;
        var part1 = WatchUi.loadResource(Rez.Strings.noDataAvailableForStation1) as String;
        var part2 = WatchUi.loadResource(Rez.Strings.noDataAvailableForStation2) as String;
        return [part0, part1, part2];
    }

    function getNoDataForDateString() as Array<String> {
        var part0 = WatchUi.loadResource(Rez.Strings.noDataAvailableForDate0) as String;
        var part1 = WatchUi.loadResource(Rez.Strings.noDataAvailableForDate1) as String;
        var part2 = WatchUi.loadResource(Rez.Strings.noDataAvailableForDate2) as String;
        return [part0, part1, part2];
    }

    function getRanOutOfDataString() as Array<String> {
        var part0 = WatchUi.loadResource(Rez.Strings.ranOutOfData0) as String;
        return [part0];
    }
}