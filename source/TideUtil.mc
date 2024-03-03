import Toybox.Lang;
import Toybox.System;
import Toybox.Application.Properties;

(:glance)
module TideUtil {
    const FEET_PER_METER = 3.28084;

    var current_station_name = PropUtil.getStationName();

    var currentPosition = null;

    // static variables for getHeightAtT
    var t1 = null, t2 = null;
    var h1 = 0.0f, h2 = 0.0f;
    var A, B_n = Toybox.Math.PI, B_d, C, D;

    function tideData(app) as Array<Array> {
        return app._hilo as Array<Array>;
    }

    function getNextEvent(t as Number, app) as Array {
        var last_h = 0;
        var data = tideData(app);
        for (var i = 0; data != null && i < data.size(); i++) {
            var time = data[i][0];
            var height = data[i][1];
            if (time > t) {
                var event_type = "H";
                if (last_h > height) {
                    event_type = "L";
                }
                return [time, height, event_type];
            }
            last_h = height;
        }
        return [null, null, null];
    }

    // Predict the tide height at a given time using first-order sinusoidal interpolation.
    function getHeightAtT(t as Number, d as Number, p, app) as Array {
        // Compute h(t) = A * cos(B * (t - C)) + D
        // For: A = (h1 - h2) / 2
        //      B = PI / (t2 - t1)
        //      C = t1
        //      D = (h2 + h1) / 2

        if (t1 == null) { t1 = t; }
        if (t2 == null) { t2 = t; }
        var found = false;
        var data = tideData(app);
        for (var i = 0; data != null && i < data.size(); i++) {
            if (data[i][0] < t) {
                t1 = data[i][0];
                h1 = data[i][1];
            } else {
                t2 = data[i][0];
                h2 = data[i][1];
                found = true;
                break;
            }
        }
        if (!found) {
            return [null, null, null, null];
        }
        A = (h1 - h2) / 2.0f;
        B_d = t2 - t1;
        C = t1;
        D = (h2 + h1) / 2.0f;
        if (B_d == null || B_d == 0) {
            /*
            System.println("Failed to find an early enough time!");
            System.println("h1: " + h1 + " h2: " + h2);
            System.println("t: " + t + " t1: " + t1 + " t2: " + t2);
            System.println("A: " + A + " B_n: " + B_n + " t: " + t + " C: " + C + " B_d: " + B_d + " D: " + D);
            */
            return [null, null, null, null];
        }
        var h = A * Toybox.Math.cos(B_n * (t - C) / B_d) + D;
        //if (p) { System.println("h1 = " + h1.toString() + "; h2 = " + h2.toString() + "; t1 = " + formatDateStringShort(t1) + "; t2 = " + formatDateStringShort(t2)); }
        //if (p) { System.println("h(t) = " + A.toString() + " * cos(" + B_n.toString() + " * (t - " + formatDateStringShort(C) + ") / " + B_d.toString() + ") + " + D.toString()); }
        if (t - t1 < d) {
            return [h, (h1 > h2), h1, t1];
        } else if (t2 - t < d) {
            return [h, (h1 < h2), h2, t2];
        }
        return [h, null, null, null];
    }
}
