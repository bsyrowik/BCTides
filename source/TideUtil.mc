import Toybox.Lang;
import Toybox.System;
import Toybox.Application.Properties;

(:glance)
module TideUtil {
    // static variables for getHeightAtT
    var t1 = null, t2 = null;
    var h1 = 0.0f, h2 = 0.0f;
    var A, B_n = Toybox.Math.PI, B_d, C, D;

    function tideData(stationIndex as Number) as Array<Array>? {
        return getApp().tideData[stationIndex] as Array<Array>?;
    }

    function getNextEvent(t as Number, stationIndex as Number) as Dictionary {
        var last_h = 0;
        var data = tideData(stationIndex);
        for (var i = 0; data != null && i < data.size(); i++) {
            var time = data[i][0];
            var height = data[i][1];
            if (time > t) {
                var event_type = "H";
                if (last_h > height) {
                    event_type = "L";
                }
                return {:eventTime => time, :eventHeight => height, :eventType => event_type};
            }
            last_h = height;
        }
        return {};
    }

    // Predict the tide height at a given time using first-order sinusoidal interpolation.
    function getHeightAtT(t as Number, d as Number, stationIndex as Number) as Dictionary {
        // Compute h(t) = A * cos(B * (t - C)) + D
        // For: A = (h1 - h2) / 2
        //      B = PI / (t2 - t1)
        //      C = t1
        //      D = (h2 + h1) / 2

        if (t1 == null) { t1 = t; }
        if (t2 == null) { t2 = t; }
        var found = false;
        var data = tideData(stationIndex);
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
            return {};
        }
        A = (h1 - h2) / 2.0f;
        B_d = t2 - t1;
        C = t1;
        D = (h2 + h1) / 2.0f;
        if (B_d == null || B_d == 0) {
            return {};
        }
        var h = A * Toybox.Math.cos(B_n * (t - C) / B_d) + D;
        if (t - t1 < d) {
            // In realm of event h1 at time t1
            var atHigh = (h1 > h2);
            return {:height => h, :topLabel => atHigh, :eventHeight => h1, :eventTime => t1};
        } else if (t2 - t < d) {
            // In realm of event h2 at time t2
            var atHigh = (h2 > h1);
            return {:height => h, :topLabel => atHigh, :eventHeight => h2, :eventTime => t2};
        }
        // Somewhere between t1 and t2
        return {:height => h};
    }
}
