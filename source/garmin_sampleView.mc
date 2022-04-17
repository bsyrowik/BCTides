import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Application.Properties;
using Toybox.Time;
using Toybox.Time.Gregorian;

using Toybox.Graphics as Gfx;
using Toybox.Position as Position;

public enum unitsPropSettings {
    UNITS_PROP_SYSTEM,
    UNITS_PROP_METRIC,
    UNITS_PROP_IMPERIAL
}


(:glance)
class MyGlanceView extends WatchUi.GlanceView {
    function initialize() {
        GlanceView.initialize();    	         
    }
    function onUpdate(dc) {
		dc.setColor(Graphics.COLOR_BLACK,Graphics.COLOR_BLACK);
		dc.clear();
		dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_TRANSPARENT);
		dc.drawText(0, 0, Graphics.FONT_GLANCE, "3.4m H in 2H 27M", Graphics.TEXT_JUSTIFY_LEFT);
        // TODO
        //dc.drawBitmap(0, 16, "location2.png");

        // Draw position indicator
        // Numbers are a bit odd; this is just what looks good.
        dc.drawCircle(7, 26, 4);
        dc.drawLine(1, 26, 14, 26); // horizontal
        dc.drawLine(7, 20, 7, 33); // vertical line

        dc.drawText(18, 16, Graphics.FONT_GLANCE, "Kits", Graphics.TEXT_JUSTIFY_LEFT);
		dc.setColor(Graphics.COLOR_BLUE,Graphics.COLOR_TRANSPARENT);
        dc.drawText(0, 32, Graphics.FONT_GLANCE_NUMBER, "2.1m and rising", Graphics.TEXT_JUSTIFY_LEFT);
        // The FONT_GLANCE_NUMBER is much larger!
        //System.print("dc height: "); System.println(dc.getHeight());
        // Height is 63 pixels
    } 
}

class garmin_sampleView extends WatchUi.View {

    hidden var mIndicatorRad;
    hidden var mIndicatorL;
    hidden var mPosition = null;
    hidden var needGPS = true;
    private var _message = "";
    var app;
    static const FEET_PER_METER = 3.28084;

    private var _time_str = "";

    var mPage = 0;
    var mPageCount = 6;

    function initialize(the_app) {
        app = the_app;
        View.initialize();
        //mIndicatorRad = new PageIndicatorArc(mPageCount, Gfx.COLOR_WHITE, ALIGN_CENTER_RIGHT, /*margin*/3);
        mIndicatorL   = new PageIndicatorRad(mPageCount, Gfx.COLOR_WHITE, ALIGN_CENTER_LEFT, /*margin*/5);
    }

    function onPosition(info) {
        mPosition = info;
        if (mPosition == null || mPosition.accuracy < Position.QUALITY_POOR) {
            System.println("got position update but accuracy sucks!");
        }
        WatchUi.requestUpdate();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {

		mPosition = Position.getInfo();
        if (mPosition == null || mPosition.accuracy < Position.QUALITY_POOR) {
            System.println("onLayout: requesting position!");
            Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
		}
        setLayout(Rez.Layouts.MainLayout(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        WatchUi.requestUpdate();
    }

    function getUnits() as System.UnitsSystem {
        var setting = Properties.getValue("unitsProp");
        if (setting == UNITS_PROP_SYSTEM) {
            return System.getDeviceSettings().elevationUnits;
        } else if (setting == UNITS_PROP_METRIC) {
            return System.UNIT_METRIC;
        } else {
            return System.UNIT_STATUTE;
        }
    }

    function drawSinusoid(dc as Dc, x, y, w, h) as Void {
        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
        var h_f = h / 2.0f;
        var start_x = x + 2;
        var last_x = start_x;
        var last_y = y + h_f - Math.sin(0.1f * (last_x - start_x)) * h_f * 0.8f;
        for (var i = start_x + 1; i < x + w - 2; i++) {
            var this_x = i;
            var this_y = y + h_f - Math.sin(0.1f * (i - start_x)) * h_f * 0.8f;
            dc.drawLine(last_x, last_y, this_x, this_y);
            last_x = this_x;
            last_y = this_y;
        }
    }

    function graphTides(dc as Dc, x as Number, y as Number, w as Number, h as Number, start as Time.Moment, end as Time.Moment) as Void {
        //System.println("Graphing tides from " + formatDateStringShort(start) + " to " + formatDateStringShort(end));
        // graphs tide height 0 at bottom, tide height 6m at top
        var margin = 1;
        var duration_per_pixel = end.subtract(start).divide(w - margin * 2);

        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);

        var start_x = x + margin;
        var last_label_x = 0;
        var current_t = start;
        var height = getHeightAtT(current_t, duration_per_pixel, 0)[0];
        var last_y = y + h - (height / 6.0f) * h;
        //System.println("[" + start_x.toString() + "] height at " + formatDateStringShort(current_t) + " is " + height.toString());
        for (var i = start_x + 1; i < x + w - margin; i++) {
            var this_x = i;
            current_t = current_t.add(duration_per_pixel);
            var l = getHeightAtT(current_t, duration_per_pixel, 0);//(i > 115 && i < 125));
            height = l[0];
            //if (i < 125 && i > 115) {
                //System.println("[" + i.toString() + "] height at " + formatDateStringShort(current_t) + " is " + height.toString());
            //}
            var this_y = y + h - (height / 6.0f) * h;
            //var l = getLabelForT(current_t, duration_per_pixel);
            if (l[1] != null && (this_x - last_label_x > 10)) {
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                var h_label = l[2];
                if (getUnits() == System.UNIT_STATUTE) {
                    h_label *= FEET_PER_METER;
                }
                if (l[1] || height < 1) {
                    dc.drawText(this_x, this_y - 22, Graphics.FONT_XTINY, h_label.format("%.1f"), Graphics.TEXT_JUSTIFY_CENTER);
                } else {
                    dc.drawText(this_x, this_y + 1, Graphics.FONT_XTINY, h_label.format("%.1f"), Graphics.TEXT_JUSTIFY_CENTER);
                }
                last_label_x = this_x;
                dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
            }
            dc.drawLine(this_x - 1, last_y, this_x, this_y);
            last_y = this_y;
        }
    }

    function getLabelForT(t as Time.Moment, d as Time.Duration) as Array or Null {
        var t1 = t, t2 = t;
        var h1 = 0.0f, h2 = 0.0f;
        for (var i = 0; i < app._hilo.size(); i++) {
            if (app._hilo[i][0].lessThan(t)) {
                t1 = app._hilo[i][0];
                h1 = app._hilo[i][1];
            } else {
                t2 = app._hilo[i][0];
                h2 = app._hilo[i][1];
                break;
            }
        }
        if (t.subtract(t1).greaterThan(d)) {
            return [(h1 > h2), h1];
        } else if (t2.subtract(t).greaterThan(d)) {
            return [(h1 < h2), h2];
        }
        return null;
    }

    function getHeightAtT(t as Time.Moment, d, p) as Array {
        // Compute h(t) = A * cos(B * (t - C)) + D
        // For: A = (h1 - h2) / 2
        //      B = PI / (t2 - t1)
        //      C = t1
        //      D = (h2 + h1) / 2
        var t_ = t.value();
        var d_ = d.value();
        var t1 = t_, t2 = t_;
        var h1 = 0.0f, h2 = 0.0f;
        for (var i = 0; i < app._hilo.size(); i++) {
            if (app._hilo[i][0] < t_) {
                t1 = app._hilo[i][0];
                h1 = app._hilo[i][1];
            } else {
                t2 = app._hilo[i][0];
                h2 = app._hilo[i][1];
                break;
            }
        }
        var A = (h1 - h2) / 2.0f;
        var B_n = Math.PI;
        var B_d = t2 - t1;
        var C = t1;
        var D = (h2 + h1) / 2.0f;
        var h = A * Math.cos(B_n * (t_ - C) / B_d) + D;
        //if (p) { System.println("h1 = " + h1.toString() + "; h2 = " + h2.toString() + "; t1 = " + formatDateStringShort(t1) + "; t2 = " + formatDateStringShort(t2)); }
        //if (p) { System.println("h(t) = " + A.toString() + " * cos(" + B_n.toString() + " * (t - " + formatDateStringShort(C) + ") / " + B_d.toString() + ") + " + D.toString()); }
        //if (t.subtract(t1).greaterThan(d)) {
        if (t_ - t1 < d_) {
            return [h, (h1 > h2), h1];
        } else if (t2 - t_ < d_) {
            return [h, (h1 < h2), h2];
        }
        return [h, null, null];
    }

    public function getFromDateString() as String {
        var duration_8h = new Time.Duration(8 * Time.Gregorian.SECONDS_PER_HOUR);
        var from = Time.now().subtract(duration_8h);
        var from_utc = Gregorian.utcInfo(from, Time.FORMAT_SHORT);
        return formatDateString(from_utc);
    }

    public function getToDateString() as String {
        var duration_7d_6h = new Time.Duration(7 * Time.Gregorian.SECONDS_PER_DAY + 6 * Time.Gregorian.SECONDS_PER_HOUR);
        var to = Time.now().add(duration_7d_6h);
        var to_utc = Gregorian.utcInfo(to, Time.FORMAT_SHORT);
        return formatDateString(to_utc);
    }

    function parseDateString(str as String) as Time.Moment {
        // e.g. 2022-04-15T17:37:22Z
        var year   = str.substring(0,4).toNumber();
        var month  = str.substring(5,7).toNumber();
        var day    = str.substring(8,10).toNumber();
        var hour   = str.substring(11,13).toNumber();
        var minute = str.substring(14,16).toNumber();
        var second = str.substring(17,19).toNumber();
        var options = {
            :year   => year,
            :month  => month,
            :day    => day,
            :hour   => hour,
            :minute => minute
        };
        //System.println("parsed to " + year.toString() + "-" + month.toString() + "-" + day.toString() + "T" + hour.toString() + ":" + minute.toString());
        return Gregorian.moment(options);
    }

    function formatDateStringShort(moment as Time.Moment) as String {
        var info = Gregorian.utcInfo(moment, Gregorian.FORMAT_SHORT);
        // Moment should be in UTC; seconds zero'd
        return Lang.format("$1$-$2$ $3$:$4$",
            [
                info.month.format("%02d"),
                info.day.format("%02d"),
                info.hour.format("%02d"),
                info.min.format("%02d")
            ]);
    }

    function formatDateString(info as Gregorian.Info) as String {
        // Moment should be in UTC; seconds zero'd
        return Lang.format("$1$-$2$-$3$T$4$:$5$:00Z",
            [
                info.year,
                info.month.format("%02d"),
                info.day.format("%02d"),
                info.hour.format("%02d"),
                info.min.format("%02d")
            ]);
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        if (needGPS) {
	    	if (mPosition == null || mPosition.accuracy == null || mPosition.accuracy < Position.QUALITY_POOR) {
		    	mPosition = Position.getInfo();
		    }
			if (mPosition.accuracy != null && mPosition.accuracy != Position.QUALITY_NOT_AVAILABLE && mPosition.position != null) {
				if (mPosition.accuracy >= Position.QUALITY_POOR) {
                    System.println("Got acceptable position; disabling callback");
		            Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
					needGPS = false;
	    		}
	    	}
		}
        if (mPosition.position != null) {
            var loc = mPosition.position.toDegrees();
            View.findDrawableById("loc0").setText(loc[0].format("%.2f"));
            View.findDrawableById("loc1").setText(loc[1].format("%.3f"));
        }

        // Date
        var now = Time.now();
        if (mPage > 0) {
            var days = new Time.Duration(Gregorian.SECONDS_PER_DAY * mPage);
            now = now.add(days);
        }
        var dateInfo = Gregorian.info(now, Gregorian.FORMAT_MEDIUM);
        dc.drawText(120, 8, Graphics.FONT_TINY, dateInfo.month + " " + dateInfo.day.toString(), Graphics.TEXT_JUSTIFY_CENTER);

        if (mPage > 0) {
            now = Time.today();
            // today - 9 hours for timezones, DST + 2 hours for the two hour day offset
            var days = new Time.Duration(Gregorian.SECONDS_PER_DAY * mPage - Gregorian.SECONDS_PER_HOUR * 7);
            now = now.add(days);
        }

        // Draw box
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(30, 60, 180, 120);

        if (app._hilo != null) {
            if (mPage == 0) {
                // Draw 'now' line
                dc.setColor(Graphics.COLOR_DK_BLUE, Graphics.COLOR_TRANSPARENT);
                var x1 = 30.0 + 2.0 + 2.0 / 24.0 * (180 - 4);
                dc.drawLine(x1, 61, x1, 179);
            }

            // Draw graph
            var duration_2h = new Time.Duration(Gregorian.SECONDS_PER_HOUR * 2);
            var duration_22h = new Time.Duration(Gregorian.SECONDS_PER_HOUR * 22);
            graphTides(dc, 30, 60, 180, 120, now.subtract(duration_2h), now.add(duration_22h));

            if (mPage == 0) {
                // Current height
                var units = "m";
                var height = getHeightAtT(now, duration_2h, 0)[0];
                if (getUnits() == System.UNIT_STATUTE) {
                    units = "ft";
                    height *= FEET_PER_METER;
                }
                dc.drawText(120, 200, Graphics.FONT_TINY, height.format("%.1f") + units, Graphics.TEXT_JUSTIFY_CENTER);
            }
        }

        // Draw page indicator
        if (mPage >= 0 && mPage < mPageCount) {
            //mIndicatorRad.draw(dc, mPage);
            mIndicatorL.draw(dc, mPage);
        }
    }

    public function onReceive(args as Dictionary or String or Array or Null) as Void {
        //System.println("View:onRecieve() \"" + args.toString() + "\"");
        if (args instanceof String) {
            System.println("string!");
            _message = "String\n" + args;
        } else if (args instanceof Dictionary) {
            System.println("dict!");
            var keys = args.keys();
            _message = "Dict\n";
            for (var i = 0; i < keys.size(); i++) {
                _message += Lang.format("$1$: $2$\n", [keys[i], args[keys[i]]]);
            }
        } else if (args instanceof Array) {
            //System.println("Got an array!");
            app._hilo = [];
            _message = "";
            for (var i = 0; i < args.size(); i++) {
                //_message += Lang.format("$1$: $2$\n", [args[i]["eventDate"].toString(), args[i]["value"].toString()]);
                app._hilo.add([parseDateString(args[i]["eventDate"].toString()).value(), args[i]["value"].toFloat()]);
            }
            app.hilo_updated = true;
            //System.println(app._hilo.toString());
        }
        WatchUi.requestUpdate();
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
        //System.println("onHide called");
        //Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
    }
}
