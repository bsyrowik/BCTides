import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Application.Properties;
import Toybox.System;
using Toybox.Time;
using Toybox.Position;
using Toybox.System;
using Toybox.Time.Gregorian;

import Toybox.Application.Storage;

using Toybox.Graphics as Gfx;
using Toybox.Position as Position;




class CanTideView extends WatchUi.View {

    hidden var mIndicatorRad;
    hidden var mIndicatorL;
    hidden var mPosition = null;
    hidden var needGPS = true;
    private var _message = "";
    var app;

    var mPage = 0;
    var mPageCount = 6;
    var mPageUpdated = true;

    var mDelegate = null;

    function setDelegate(d as CanTideDelegate) as Void {
        mDelegate = d;
    }

    function initialize(the_app) {
        app = the_app;
        View.initialize();
        //mIndicatorRad = new PageIndicatorArc(mPageCount, Gfx.COLOR_WHITE, ALIGN_CENTER_RIGHT, /*margin*/3);
        mIndicatorL   = new PageIndicatorRad(mPageCount, Gfx.COLOR_WHITE, ALIGN_CENTER_LEFT, /*margin*/5);
    }

    function onPosition(info as Position.Info) as Void {
        mPosition = info;
        if (mPosition == null || mPosition.accuracy < Position.QUALITY_POOR) {
            System.println("got position update but accuracy sucks!");
        } else {
            System.println("got position and accuracy is acceptable.");
        }
        WatchUi.requestUpdate();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {

		//mPosition = Position.getInfo();
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

    function drawNoDataWarning(dc as Dc, x as Number, y as Number, message as Array<String>) {
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        for (var i = 0; i < message.size(); i++) {
            dc.drawText(x, y + (30 * i), Graphics.FONT_SMALL, message[i], Graphics.TEXT_JUSTIFY_LEFT);
        }

        if (!mPageUpdated) {
            return;
        }

        var prompt = "";
        for (var i = 0; i < message.size(); i++) {
            prompt += message[i] + "\n";
        }
        prompt += "Download data?";
        var dialog = new WatchUi.Confirmation(prompt);
        WatchUi.pushView(
            dialog,
            new DownloadDataConfirmationDelegate(mDelegate),
            WatchUi.SLIDE_IMMEDIATE
        );

        return;
    }

    function graphTides(dc as Dc, x as Number, y as Number, w as Number, h as Number, start as Time.Moment, end as Time.Moment) as Boolean {
        //System.println("Graphing tides from " + formatDateStringShort(start) + " to " + formatDateStringShort(end));
        // graphs tide height 0 at bottom, tide height 6m at top
        var margin = 1;
        var increment = 4;
        var duration_per_increment = end.subtract(start).divide(w - margin * 2).multiply(increment).value();       

        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);

        var start_x = x + margin;
        var last_label_x = 0;
        var current_t = start.value();
        var height = TideUtil.getHeightAtT(current_t, duration_per_increment, 0, app)[0];
        if (height == null) {
            drawNoDataWarning(dc, x, y, ["No data available", "for date."]);
            return false;
        }
        var last_y = y + h - (height / 6.0f) * h;
        var last_x = start_x;
        //System.println("[" + start_x.toString() + "] height at " + formatDateStringShort(start) + " is " + height.toString());
        //for (var i = start_x + 1; i < x + w - margin; i++) {
        for (var i = start_x + 1; i < x + w - margin; i = i + increment) {
            var this_x = i;
            current_t += duration_per_increment;
            var l = TideUtil.getHeightAtT(current_t, duration_per_increment, 0, app);//(i > 115 && i < 125));
            height = l[0];
            if (height == null) {
                drawNoDataWarning(dc, x, y, ["Ran out of data!"]);
                return true;
            }
            //if (i < 125 && i > 115) {
                //System.println("[" + i.toString() + "] height at " + formatDateStringShort(current_t) + " is " + height.toString());
            //}
            var this_y = y + h - (height / 6.0f) * h;
            //var l = getLabelForT(current_t, duration_per_increment);
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

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x,       y, Graphics.FONT_SMALL, "Time PST", Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(x + 102, y, Graphics.FONT_SMALL, "Height (" + units + ")", Graphics.TEXT_JUSTIFY_LEFT);
        y = y + 26;
        var i;
        var entries_for_date = 0;
        for (i = 0; i < TideUtil.tideData(app).size(); i++) {
            var time = TideUtil.tideData(app)[i][0];
            var height = TideUtil.tideData(app)[i][1];
            if (time > end.value()) {
                return;
            }
            if (time >= start.value()) {
                // Add a row
                var m = new Time.Moment(time);
                dc.drawText(x + 30,  y, Graphics.FONT_TINY, DateUtil.formatTimeStringShort(m), Graphics.TEXT_JUSTIFY_LEFT);
                dc.drawText(x + 162, y, Graphics.FONT_TINY, (height * height_multiplier).format("%.2f"), Graphics.TEXT_JUSTIFY_RIGHT);
                y = y + 22;
                entries_for_date++;
            }
        }
        if (i >= TideUtil.tideData(app).size()) {
            drawNoDataWarning(dc, x, y, (entries_for_date > 0 ? ["Ran out of data!"] : ["No data available", "for date."]));
        }
    }


    function updateLocationText(position as Position.Location) as Void {
        TideUtil.currentPosition = position;
        var loc = position.toDegrees();
        var loc0 = View.findDrawableById("loc0") as Text;
        loc0.setText(loc[0].format("%.3f"));
        var loc1 = View.findDrawableById("loc1") as Text;
        loc1.setText(loc[1].format("%.3f"));
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

        var stationLabel = View.findDrawableById("stationTitle") as Text;
        stationLabel.setText(PropUtil.getStationName());

        // Date
        var today = Time.today();  // Time-zone adjusted!
        var now = Time.now();

        if (mPage > 0) {
            var days = new Time.Duration(Gregorian.SECONDS_PER_DAY * mPage);
            today = today.add(days);
        }

        var dateInfo = Gregorian.info(today, Time.FORMAT_MEDIUM);
        dc.drawText(120, 8, Graphics.FONT_TINY, dateInfo.month + " " + dateInfo.day.toString(), Graphics.TEXT_JUSTIFY_CENTER);


        if (app._hilo != null) {

            if (PropUtil.getDisplayType() == PropUtil.DISPLAY_PROP_GRAPH) {
                // Draw box
                dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
                dc.drawRectangle(30, 60, 180, 120);

                // Draw graph
                var duration_24h = new Time.Duration(Gregorian.SECONDS_PER_HOUR * 24);
                var success = graphTides(dc, 30, 60, 180, 120, today, today.add(duration_24h));

                if (success && mPage == 0) {
                    // Draw 'now' line
                    var offset = (now.value() - today.value()) * (180 - 4) / Gregorian.SECONDS_PER_DAY;
                    dc.setColor(Graphics.COLOR_DK_BLUE, Graphics.COLOR_TRANSPARENT);
                    var x1 = 30.0 + 2.0 + offset;
                    dc.drawLine(x1, 61, x1, 179);
                }
            } else {
                // Draw table
                var duration_24h = new Time.Duration(Gregorian.SECONDS_PER_HOUR * 24);
                tableTides(dc, 22, 60, 180, 120, today, today.add(duration_24h));
            }

            if (mPage == 0) {
                // Current height
                var units = "m";
                var duration_2h = new Time.Duration(Gregorian.SECONDS_PER_HOUR * 2);
                var height = TideUtil.getHeightAtT(now.value(), duration_2h.value(), 0, app)[0];
                if (height != null) {
                    if (PropUtil.getUnits() == System.UNIT_STATUTE) {
                        units = "ft";
                        height *= TideUtil.FEET_PER_METER;
                    }
                    dc.setColor(Graphics.COLOR_DK_BLUE, Graphics.COLOR_TRANSPARENT);
                    dc.drawText(120, 200, Graphics.FONT_TINY, height.format("%.1f") + units, Graphics.TEXT_JUSTIFY_CENTER);
                }
            }
        }

        // Draw page indicator
        if (mPage >= 0 && mPage < mPageCount) {
            //mIndicatorRad.draw(dc, mPage);
            mIndicatorL.draw(dc, mPage);
        }
        mPageUpdated = false;
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
                var eventData = args[i] as Dictionary;
                app._hilo.add([DateUtil.parseDateString(eventData["eventDate"].toString()).value(), eventData["value"].toFloat()]);
                            }
            app.hilo_updated = true;
            //System.println(app._hilo.toString());

            if (app._hilo != null) {
                Storage.setValue("kits_hilo", app._hilo);
            }

            var gotDataView = new GotDataView();
            WatchUi.pushView(
                gotDataView,
                new GotDataViewDelegate(gotDataView),
                WatchUi.SLIDE_IMMEDIATE
            );
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