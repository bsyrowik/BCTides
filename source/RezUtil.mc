
import Toybox.Lang;
using Toybox.WatchUi;


class RezUtil {
    static function getStationData() as Array<Dictionary> {
        if (PropUtil.getStationZone() == PropUtil.ZONE_PROP_NORTH) {
            return WatchUi.loadResource(Rez.JsonData.stationsNorth) as Array<Dictionary>;
        } else {
            return WatchUi.loadResource(Rez.JsonData.stationsSouth) as Array<Dictionary>;
        }
    }
}