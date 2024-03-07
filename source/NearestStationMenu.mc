import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

module NearestStationMenu {
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
        var d = Toybox.Math.sqrt(d2);
        var r = 6371;  // Radius of earth in km
        return d * r;
    }

    function buildHeap(allStations as Array<Dictionary>) as HeapOfPair {
        var position = getApp().currentPosition.toRadians() as Array;  // FIXME: deal with case where currentPosition is still null
        var myLatitude = position[0];
        var myLongitude = position[1];
        var size = allStations.size();
        var h = new HeapOfPair(size);
        for(var i = 0; i < size; i++) {
            var dSquared = distanceSquaredApproximation(myLatitude, myLongitude, allStations[i]["lat"], allStations[i]["lon"]);
            h.minHeapInsert(dSquared, i);
        }
        return h;
    }

    function pushNextMenu(title as String, h as HeapOfPair?, stationIndex as Number, depth as Number) as Void {
        var stationList = RezUtil.getStationData() as Array<Dictionary>;
        if (h == null) {
            h = buildHeap(stationList);
        }
        
        var menu = new LoadMoreMenu(title, Application.loadResource(Rez.Strings.loadMoreMenuPage) + " " + (depth + 1), getApp().screenHeight / 3, Graphics.COLOR_WHITE, {:theme => null});

        var allowWrap = true;
        var stationsToShow = 7;
        for (var i = 0; i < stationsToShow; i++) {
            var p = h.heapExtractMin();
            if (p == null) {
                // Ran out of items -- this menu shouldn't allow scrolling to the next
                menu.disableFooter();
                allowWrap = false;
                break;
            }
            var dist = distance(p.distance);
            menu.addItem(
                new BasicCustomMenuItem(
                    [stationIndex, stationList[p.index]["code"]],
                    stationList[p.index]["name"],
                    dist.format("%.2f") + "km"
                )
            );
        }

        // TODO: maybe cache each menu we push so we can scroll through them?
        //  --> The min heap is destroyed after creating each subsequent menu...
        var delegate = new LoadMoreMenuDelegate(new Lang.Method(NearestStationMenu, :pushNextMenu), h, stationIndex, depth, allowWrap, false);
        WatchUi.pushView(menu, delegate, WatchUi.SLIDE_IMMEDIATE);
    }
}
