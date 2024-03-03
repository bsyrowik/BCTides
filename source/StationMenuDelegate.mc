import Toybox.Lang;

using Toybox.WatchUi;

class StationMenuDelegate extends WatchUi.Menu2InputDelegate {
    public enum {
        MENU_STATION_RECENT,
        MENU_STATION_NEAREST,
        MENU_STATION_ALPHABETICAL,
        MENU_STATION_SEARCH
    }

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    // All input values should be in radians.
    // Returns the 'distance squared', scaled to a 'unit' sized Earth.
    // Pass through the distance() function to get a distance in kilometers.
    // Only accurate for coordinates around 49 degrees latitude.
    function distanceSquaredApproximation(lat1 as Float, lon1 as Float, lat2 as Float, lon2 as Float) as Float {
        var dLat = lat2 - lat1;
        var dLon = lon2 - lon1;
        var dLon_scale_factor = 0.652; // FIXME: Should be `cos((lat1 + lat2) / 2)`, but optimized for ~49 deg N to save computation time.
        dLon = dLon * dLon_scale_factor;
        return dLat * dLat + dLon * dLon;
    }

    // Convert a result produced by distanceSquaredApproximation() to a distance in km
    function distance(d2 as Float) as Float {
        var d = Math.sqrt(d2);
        var r = 6371;  // Radius of earth in km
        return d * r;
    }

    function buildNearestStationHeap(all_stations as Array<Dictionary>) as HeapOfPair {
        var position = TideUtil.currentPosition.toRadians() as Array;  // FIXME: deal with case where currentPosition is still null
        var myLatitude = position[0];
        var myLongitude = position[1];
        var size = all_stations.size();
        var h = new HeapOfPair(size);
        for(var i = 0; i < size; i++) {
            var d_squared = distanceSquaredApproximation(myLatitude, myLongitude, all_stations[i]["lat"], all_stations[i]["lon"]);
            h.minHeapInsert(d_squared, i);
        }
        return h;
    }

    function buildNearestStationMenu() as Void {
        var stationList = RezUtil.getStationData() as Array<Dictionary>;
        var h = buildNearestStationHeap(stationList);

        var stationsToShow = 7;
        var menu = new WatchUi.Menu2({:title=>WatchUi.loadResource(Rez.Strings.selectStationMenuNearest)});
        for (var i = 0; i < stationsToShow; i++) {
            var p = h.heapExtractMin();
            var dist = distance(p.distance);
            menu.addItem(
                new WatchUi.MenuItem(
                    stationList[p.index]["name"],
                    dist.format("%.2f") + "km",
                    stationList[p.index]["code"],
                    {} // options
                )
            );
        }

        // Get rid of the station selection strategy menu so when we finish here we go back to the main menu
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);   

        var delegate = new SelectStationMenuDelegate();
        WatchUi.pushView(menu, delegate, WatchUi.SLIDE_IMMEDIATE);
    }

    function buildRecentStationMenu() as Void {
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

        // Get rid of the station selection strategy menu so when we finish here we go back to the main menu
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);   

        var delegate = new SelectStationMenuDelegate();
        WatchUi.pushView(menu, delegate, WatchUi.SLIDE_IMMEDIATE);
    }

    function onSelect(item) as Void {
        // TODO: search by coordinates?
        if (item.getId() == MENU_STATION_NEAREST) {
            buildNearestStationMenu();
        } else if (item.getId() == MENU_STATION_ALPHABETICAL) {
            // TODO: dynamic list of stations
        } else if (item.getId() == MENU_STATION_RECENT) {
            buildRecentStationMenu();
        } else if (item.getId() == MENU_STATION_SEARCH) {
            // TODO: get text input
            /*
            var text_picker = new MyInputDelegate();
            text_picker.initialize();
            */
        }
    }
}
