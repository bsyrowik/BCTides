import Toybox.Application.Properties;
import Toybox.Application.Storage;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

using Toybox.Position;
using Toybox.System;
using Toybox.Time;
using Toybox.Time.Gregorian;

class BCTidesView extends WatchUi.View {
    hidden var mIndicatorL;
    hidden var mPosition = null;
    hidden var needGPS = true;
    var app;

    var mPage = 0;
    var mPageCount = 6;
    var mPageUpdated = true;

    var mDelegate = null;

    function setDelegate(d as BCTidesDelegate) as Void {
        mDelegate = d;
    }

    function initialize(the_app) {
        app = the_app;
        View.initialize();
        mIndicatorL = new PageIndicatorRad(mPageCount, Graphics.COLOR_WHITE, ALIGN_CENTER_LEFT, /*margin*/5);
    }

    function onPosition(info as Position.Info) as Void {
        mPosition = info;
        if (mPosition == null || mPosition.accuracy < Position.QUALITY_POOR) {
            System.println("got position update but accuracy not good!");
        } else {
            System.println("got position and accuracy is acceptable.");
        }
        WatchUi.requestUpdate();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
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

    function drawNoDataWarning(dc as Dc, x as Number, y as Number, message as Array<String>, showConfirmation as Boolean) as Void {
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        for (var i = 0; i < message.size(); i++) {
            dc.drawText(x, y, Graphics.FONT_SMALL, message[i], Graphics.TEXT_JUSTIFY_LEFT);
            y += dc.getFontHeight(Graphics.FONT_SMALL) * 0.8 as Number;
        }

        if (!mPageUpdated || !showConfirmation) {
            return;
        }

        WatchUi.pushView(
            new WatchUi.Confirmation(WatchUi.loadResource(Rez.Strings.downloadDataPrompt) as String),
            new DownloadDataConfirmationDelegate(mDelegate),
            WatchUi.SLIDE_IMMEDIATE
        );
    }

    function graphTides(dc as Dc, x as Number, y as Number, w as Number, h as Number, start as Time.Moment, end as Time.Moment) as Boolean {
        // graphs tide height 0 at bottom, tide height "maxTide" at top
        var margin = 1;
        var increment = 4;
        var duration_per_increment = end.subtract(start).divide(w - margin * 2).multiply(increment).value();       

        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);

        var max_tide = Storage.getValue("maxTide");
        if (max_tide == null) {
            max_tide = 6.0;
        }
        var max_height = max_tide * 1.15;

        var start_x = x + margin;
        var last_label_x = 0;
        var current_t = start.value();
        var height = TideUtil.getHeightAtT(current_t, duration_per_increment, 0, app)[0];
        if (height == null) {
            drawNoDataWarning(dc, x, y, RezUtil.getNoDataForDateString(), true);
            return false;
        }
        var last_y = y + h - (height / max_height) * h;
        var last_x = start_x;
        
        for (var i = start_x + 1; i < x + w - margin; i = i + increment) {
            var this_x = i;
            current_t += duration_per_increment;
            var l = TideUtil.getHeightAtT(current_t, duration_per_increment, 0, app);
            height = l[0];       
            if (height == null) {
                drawNoDataWarning(dc, x, y, RezUtil.getRanOutOfDataString(), true);
                return true;
            }
            var this_y = y + h - (height / max_height) * h;
            if (l[1] != null && (this_x - last_label_x > 10)) {
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                var h_label = l[2];
                if (PropUtil.getUnits() == System.UNIT_STATUTE) {
                    h_label *= TideUtil.FEET_PER_METER;
                }
                var label_string = h_label.format("%.1f");
                if (PropUtil.graphLabelType() == PropUtil.DATA_LABEL_PROP_TIME) {
                    var m = new Time.Moment(l[3]);
                    label_string = DateUtil.formatTimeStringShort(m);
                } else if (PropUtil.graphLabelType() == PropUtil.DATA_LABEL_PROP_NONE) {
                    label_string = "";
                }
                if (l[1] || height < 1) {
                    dc.drawText(this_x, this_y - 22, Graphics.FONT_XTINY, label_string, Graphics.TEXT_JUSTIFY_CENTER);
                } else {
                    dc.drawText(this_x, this_y + 1, Graphics.FONT_XTINY, label_string, Graphics.TEXT_JUSTIFY_CENTER);
                }
                last_label_x = this_x;
                dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
            }
            dc.drawLine(last_x, last_y, this_x, this_y);
            last_y = this_y;
            last_x = this_x;
        }
        return true;
    }

    function tableTides(dc as Dc, x as Number, y as Number, w as Number, h as Number, start as Time.Moment, end as Time.Moment) as Void {
        var units = "m";
        var height_multiplier = 1.0f;
        if (PropUtil.getUnits() == System.UNIT_STATUTE) {
            units = "ft";
            height_multiplier = TideUtil.FEET_PER_METER;
        }

        var col1 = x + w / 4;
        var col2 = x + 3 * w / 4;
        var startY = y;

        // Heading
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(col1, y, Graphics.FONT_SMALL, WatchUi.loadResource(Rez.Strings.tableHeadingTime) as String, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(col2, y, Graphics.FONT_SMALL, WatchUi.loadResource(Rez.Strings.tableHeadingHeight) as String, Graphics.TEXT_JUSTIFY_CENTER);
        y += dc.getFontHeight(Graphics.FONT_SMALL) - 3;

        // Sub-heading
        dc.drawText(col1, y, Graphics.FONT_XTINY, WatchUi.loadResource(Rez.Strings.tableHeadingTimeSpecifier) as String, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(col2, y, Graphics.FONT_XTINY, "(" + units + ")", Graphics.TEXT_JUSTIFY_CENTER);
        y += dc.getFontHeight(Graphics.FONT_XTINY);

        // Heading underline
        dc.drawLine(x, y - 1, x + w, y - 1);
        
        var i;
        var entries_for_date = 0;
        for (i = 0; i < TideUtil.tideData(app).size(); i++) {
            var time = TideUtil.tideData(app)[i][0];
            var height = TideUtil.tideData(app)[i][1];
            if (time > end.value()) {
                break;
            }
            if (time >= start.value()) {
                // Add a row
                var m = new Time.Moment(time);
                dc.drawText(col1,  y, Graphics.FONT_TINY, DateUtil.formatTimeStringShort(m), Graphics.TEXT_JUSTIFY_CENTER);
                dc.drawText(col2, y, Graphics.FONT_TINY, (height * height_multiplier).format("%.2f"), Graphics.TEXT_JUSTIFY_CENTER);
                y = y + dc.getFontHeight(Graphics.FONT_TINY) - 4; // 22 for FR745
                entries_for_date++;
            }
        }

        // Center line
        dc.drawLine(x + w / 2, startY + 5, x + w / 2, y);

        if (i >= TideUtil.tideData(app).size()) {
            drawNoDataWarning(dc, x, y, (entries_for_date > 0 ? RezUtil.getRanOutOfDataString() : RezUtil.getNoDataForDateString()), true);
        }
    }

    (:debug)
    function updateLocationText(position as Position.Location) as Void {
        TideUtil.currentPosition = position;
        var loc = position.toDegrees();
        var loc0 = View.findDrawableById("loc0") as Text;
        loc0.setText(loc[0].format("%.2f"));
        var loc1 = View.findDrawableById("loc1") as Text;
        loc1.setText(loc[1].format("%.2f"));
        loc0.setText(""); // FIXME
        loc1.setText(""); // FIXME
    }
    
    (:release)
    function updateLocationText(position as Position.Location) as Void {
        var loc0 = View.findDrawableById("loc0") as Text;
        loc0.setText("");
        var loc1 = View.findDrawableById("loc1") as Text;
        loc1.setText("");
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        if (needGPS) {
	    	if (mPosition == null || mPosition.accuracy == null || mPosition.accuracy < Position.QUALITY_POOR) {
		    	mPosition = Position.getInfo();
                System.println("setting mPosition in onUpdate()");
		    }
            System.print("accuracy: " + mPosition.accuracy);
            System.println(" position: " + mPosition.position.toDegrees());
			if (mPosition.accuracy != null && mPosition.accuracy != Position.QUALITY_NOT_AVAILABLE && mPosition.position != null) {
				if (mPosition.accuracy >= Position.QUALITY_POOR) {
                    System.println("Got acceptable position; disabling callback");
		            Position.enableLocationEvents(Position.LOCATION_DISABLE, self.method(:onPosition));
					needGPS = false;
	    		}
	    	}
		}
        if (mPosition.position != null) {
            updateLocationText(mPosition.position);
        }
        if (mPosition == null || mPosition.position == null || mPosition.accuracy == Position.QUALITY_NOT_AVAILABLE) {
            var cc = Toybox.Weather.getCurrentConditions() as Toybox.Weather.CurrentConditions;
            //System.println("Trying to get position from weather...");
            //System.println(cc);
            if (cc != null) {
                var pos = cc.observationLocationPosition as Position.Location;
                if (pos != null) {
                    updateLocationText(pos);
                    System.println("Got position from weather: " + pos.toDegrees()[0] + " " + pos.toDegrees()[1]);
                }
            }
        }

        dc.drawText(dc.getWidth() / 2, dc.getWidth() * 0.13, Graphics.FONT_XTINY, PropUtil.getStationName(), Graphics.TEXT_JUSTIFY_CENTER);
        
        // Date
        var today = Time.today();  // Time-zone adjusted!
        var now = Time.now();

        if (mPage > 0) {
            var days = new Time.Duration(Gregorian.SECONDS_PER_DAY * mPage);
            today = today.add(days);
        }

        var dateInfo = Gregorian.info(today, Time.FORMAT_MEDIUM);
        dc.drawText(dc.getWidth() / 2, 8, Graphics.FONT_TINY, dateInfo.month + " " + dateInfo.day.toString(), Graphics.TEXT_JUSTIFY_CENTER);


        var offset_x = dc.getWidth() * 0.1 as Number;
        var offset_y = dc.getHeight() / 4;
        if (TideUtil.tideData(app) != null && TideUtil.dataValid) {

            var width = dc.getWidth() * 0.8 as Number;
            var height = dc.getHeight() / 2;
            if (PropUtil.getDisplayType() == PropUtil.DISPLAY_PROP_GRAPH) {
                // Draw box
                dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
                dc.drawRectangle(offset_x, offset_y, width, height);

                // Draw graph
                var duration_24h = new Time.Duration(Gregorian.SECONDS_PER_HOUR * 24);
                var success = graphTides(dc, offset_x, offset_y, width, height, today, today.add(duration_24h));

                if (success && mPage == 0) {
                    // Draw 'now' line
                    var offset = (now.value() - today.value()) * (width - 4) / Gregorian.SECONDS_PER_DAY;
                    dc.setColor(Graphics.COLOR_DK_BLUE, Graphics.COLOR_TRANSPARENT);
                    var x1 = offset_x + 2.0 + offset;
                    dc.drawLine(x1, offset_y + 1, x1, offset_y + height - 2);
                }
            } else {
                // Draw table
                var duration_24h = new Time.Duration(Gregorian.SECONDS_PER_HOUR * 24);
                tableTides(dc, offset_x, offset_y - 10, width, height, today, today.add(duration_24h));
            }

            if (mPage == 0) {
                // Current height
                var units = "m";
                var duration_2h = new Time.Duration(Gregorian.SECONDS_PER_HOUR * 2);
                var tideHeight = TideUtil.getHeightAtT(now.value(), duration_2h.value(), 0, app)[0];
                if (tideHeight != null) {
                    if (PropUtil.getUnits() == System.UNIT_STATUTE) {
                        units = "ft";
                        tideHeight *= TideUtil.FEET_PER_METER;
                    }
                    dc.setColor(Graphics.COLOR_DK_BLUE, Graphics.COLOR_TRANSPARENT);
                    dc.drawText(dc.getWidth() / 2, dc.getHeight() * 0.8, Graphics.FONT_SMALL, tideHeight.format("%.1f") + units, Graphics.TEXT_JUSTIFY_CENTER);
                }
            }
        } else if (PropUtil.getStationCode() == null) {
            drawNoDataWarning(dc, offset_x, offset_y, [WatchUi.loadResource(Rez.Strings.noStationSelectedMessage) as String], false);
        } else {
            drawNoDataWarning(dc, offset_x, offset_y, RezUtil.getNoDataForStationString(), true);
        }

        // Draw page indicator
        if (mPage >= 0 && mPage < mPageCount) {
            mIndicatorL.draw(dc, mPage);
        }
        mPageUpdated = false;
    }

    public function onReceive(args as Dictionary or String or Array or Null) as Void {
        //System.println("View:onReceive() \"" + args.toString() + "\"");
        if (args instanceof Array) {
            var maxTide = 0.0;
            //System.println("Got an array!");
            app._hilo = [];
            for (var i = 0; i < args.size(); i++) {
                var eventData = args[i] as Dictionary;
                var height = eventData["value"].toFloat();
                if (height > maxTide) {
                    maxTide = height;
                }
                app._hilo.add([DateUtil.parseDateString(eventData["eventDate"].toString()).value(), height]);
            }
            app.hilo_updated = true;
            //System.println(app._hilo.toString());

            Storage.setValue("hiloData", app._hilo);
            Storage.setValue("maxTide", maxTide);
            TideUtil.dataValid = true;

            Notification.showNotification(Rez.Strings.dataReceivedMessage as String, 2000);
        } else {
            System.println("Received unexpected data from API call.");
        }
        WatchUi.requestUpdate();
    }
}
