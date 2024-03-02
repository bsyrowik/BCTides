import Toybox.Lang;

using Toybox.WatchUi;

class StationMenuDelegate extends WatchUi.Menu2InputDelegate {
    public enum {
        MENU_STATION_NEAREST,
        MENU_STATION_ALPHABETICAL,
        MENU_STATION_SEARCH
    }
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function d2r(d as Float) as Float {
        return d * Math.PI / 180.0f;
    }

    // All input values should be in radians.
    // Retruns the 'distance squared', scaled to a 'unit' sized Earth.
    // Pass through the distance() function to get a distance in kilometers.
    // Only accurate for coordinates around 49 degrees latitude.
    function d2(lat1 as Float, lon1 as Float, lat2 as Float, lon2 as Float) as Float {
        var dlat = lat2 - lat1;
        var dlon = lon2 - lon1;
        var dlon_scale_factor = 0.652; // Should be `cos((lat1 + lat2) / 2)` ; optimized for ~49 deg N
        dlon = dlon * dlon_scale_factor;
        return dlat * dlat + dlon * dlon;
    }

    function distance(d2 as Float) as Float {
        var d = Math.sqrt(d2);
        var r = 6371;
        return d * r;
    }

    function nearestStationMenu(h as HeapOfPair, all_stations as Array<Dictionary>) {
        var menu = new WatchUi.Menu2({:title=>"Nearest"});

        var count = 7;
        for (var i = 0; i < count; i++) {
            var p = h.heapExtractMin();
            var dist = distance(p.distance);
            var station = all_stations[p.index] as Dictionary;
            //System.println(station["name"] + " " + dist.format("%.2f") + "km");
            menu.addItem(
                new WatchUi.MenuItem(
                    station["name"],
                    dist.format("%.2f") + "km",
                    p.index,
                    {}
                )
            );
        }

        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);   

        var delegate = new NearestStationMenuDelegate();
        WatchUi.pushView(menu, delegate, WatchUi.SLIDE_IMMEDIATE);

        return true;
    }


    function onSelect(item) {

        // TODO: search by coordinates?

        if (item.getId() == MENU_STATION_NEAREST) {
            var home_pos = TideUtil.currentPosition.toRadians() as Array;
            var home_lat = home_pos[0];
            var home_lon = home_pos[1];
            // TODO: dynamic list of stations
            // FIXME TODO: New menu level for choosing north or south list???
            var all_stations = RezUtil.getStationData() as Array<Dictionary>;
            // TODO: use insertion sort or similar? What about a min heap?
            var size = all_stations.size();
            var h = new HeapOfPair(size);
            for(var i = 0; i < size; i++) {
                var d_squared = d2(home_lat, home_lon, all_stations[i]["lat"], all_stations[i]["lon"]);
                h.minHeapInsert(d_squared, i);
            }
            nearestStationMenu(h, all_stations);
        } else if (item.getId() == MENU_STATION_ALPHABETICAL) {
            // TODO: dynamic list of stations
            // DO this one first, it is easier.
        } else if (item.getId() == MENU_STATION_SEARCH) {
            // TODO: get text input
            var text_picker = new MyInputDelegate();
            text_picker.initialize();
        }
        //WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);   
    }
}
