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
    hidden var app;

    private var mPage = 0;
    private var mPageCount = 7;
    private var mPageUpdated = true;

    public function nextPage() as Void {
        mPage = (mPage + 1) % mPageCount;
        mPageUpdated = true;
    }

    public function prevPage() as Void {
        mPage = (mPage + mPageCount - 1) % mPageCount;
        mPageUpdated = true;
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
            //System.println("onLayout: requesting position!");
            Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
		}
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

    function drawNoDataWarning(dc as Dc, x as Number, y as Number, w as Number, h as Number, message as String or Symbol, showConfirmation as Boolean) as Void {
        message = message instanceof String ? message : WatchUi.loadResource(message) as String;

        var maxY = getApp().screenHeight * 0.57;
        y = y > maxY ? maxY : y;

        var textArea = new WatchUi.TextArea({
            :text => message,
            :color => Graphics.COLOR_RED,
            :backgroundColor => Graphics.COLOR_TRANSPARENT,
            :font => Graphics.FONT_SMALL,
            :justification => Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER,
            :locX => x,
            :locY => y,
            :width => w,
            :height => h
            });
        textArea.draw(dc);
        
        if (!mPageUpdated || !showConfirmation) {
            return;
        }

        WatchUi.pushView(
            new WatchUi.Confirmation(WatchUi.loadResource(Rez.Strings.downloadDataPrompt) as String),
            new DownloadDataConfirmationDelegate(),
            WatchUi.SLIDE_IMMEDIATE
        );
    }

    function graphTides(dc as Dc, x as Number, y as Number, w as Number, h as Number, start as Time.Moment, end as Time.Moment) as Boolean {
        // graphs tide height 0 at bottom, tide height "maxTide" at top
        var margin = 1;
        var increment = 4;
        var duration_per_increment = end.subtract(start).divide(w - margin * 2).multiply(increment).value();       
        var heightMultiplier = PropUtil.heightMultiplier();

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
            drawNoDataWarning(dc, x, y, w, h, Rez.Strings.noDataAvailableForDate, true);
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
                drawNoDataWarning(dc, x, y, w, h, Rez.Strings.ranOutOfData, true);
                return true;
            }
            var this_y = y + h - (height / max_height) * h;
            if (l[1] != null && (this_x - last_label_x > 10)) {
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                var h_label = l[2] * heightMultiplier;
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
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        
        var units = PropUtil.units();
        var heightMultiplier = PropUtil.heightMultiplier();

        var col1 = x + w / 4;
        var col2 = x + 3 * w / 4;
        var startY = y;

        // Heading
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
                dc.drawText(col2, y, Graphics.FONT_TINY, (height * heightMultiplier).format("%.2f"), Graphics.TEXT_JUSTIFY_CENTER);
                y = y + dc.getFontHeight(Graphics.FONT_TINY) - 4; // 22 for FR745
                entries_for_date++;
            }
        }

        // Center line between columns
        dc.drawLine(x + w / 2, startY + 5, x + w / 2, y);

        // Issue out of data warning
        if (i >= TideUtil.tideData(app).size()) {
            drawNoDataWarning(dc, x, y, w, h, (entries_for_date > 0 ? Rez.Strings.ranOutOfData : Rez.Strings.noDataAvailableForDate), true);
        }
    }

    function drawTableTimeTicks(dc as Dc, offset_x as Number, width as Number, offset_y as Number, height as Number) {
        // Bottom
        dc.drawLine(offset_x + width * 1 / 8, offset_y + height - 5, offset_x + width * 1 / 8, offset_y + height);
        dc.drawLine(offset_x + width * 2 / 8, offset_y + height - 8, offset_x + width * 2 / 8, offset_y + height);
        dc.drawLine(offset_x + width * 3 / 8, offset_y + height - 5, offset_x + width * 3 / 8, offset_y + height);
        dc.drawLine(offset_x + width * 4 / 8, offset_y + height - 8, offset_x + width * 4 / 8, offset_y + height);
        dc.drawLine(offset_x + width * 5 / 8, offset_y + height - 5, offset_x + width * 5 / 8, offset_y + height);
        dc.drawLine(offset_x + width * 6 / 8, offset_y + height - 8, offset_x + width * 6 / 8, offset_y + height);
        dc.drawLine(offset_x + width * 7 / 8, offset_y + height - 5, offset_x + width * 7 / 8, offset_y + height);
        // Top
        dc.drawLine(offset_x + width * 1 / 8, offset_y + 5, offset_x + width * 1 / 8, offset_y);
        dc.drawLine(offset_x + width * 2 / 8, offset_y + 8, offset_x + width * 2 / 8, offset_y);
        dc.drawLine(offset_x + width * 3 / 8, offset_y + 5, offset_x + width * 3 / 8, offset_y);
        dc.drawLine(offset_x + width * 4 / 8, offset_y + 8, offset_x + width * 4 / 8, offset_y);
        dc.drawLine(offset_x + width * 5 / 8, offset_y + 5, offset_x + width * 5 / 8, offset_y);
        dc.drawLine(offset_x + width * 6 / 8, offset_y + 8, offset_x + width * 6 / 8, offset_y);
        dc.drawLine(offset_x + width * 7 / 8, offset_y + 5, offset_x + width * 7 / 8, offset_y);
    }

    function drawTideGraphBox(dc as Dc, offset_x as Number, offset_y as Number, width as Number, height as Number) {
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(offset_x, offset_y, width, height);

        drawTableTimeTicks(dc, offset_x, width, offset_y, height);
    }

    function drawCurrentHeight(dc as Dc) {
        // Current height string
        if (mPage != 0) {
            return; // Only display current height on today's page
        }
        var units = PropUtil.units();
        var duration_2h = new Time.Duration(Gregorian.SECONDS_PER_HOUR * 2);
        var tideHeight = TideUtil.getHeightAtT(Time.now().value(), duration_2h.value(), 0, app)[0];
        if (tideHeight != null) {
            tideHeight *= PropUtil.heightMultiplier();
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(dc.getWidth() / 2, dc.getHeight() * 0.88, Graphics.FONT_MEDIUM, tideHeight.format("%.1f") + units, Graphics.TEXT_JUSTIFY_CENTER | Graphics. TEXT_JUSTIFY_VCENTER);
        }
    }

    function drawNowLine(dc as Dc, today as Time.Moment, offset_x as Number, offset_y as Number, width as Number, height as Number) {
        // Draw 'now' line
        if (mPage != 0) {
            return; // Only draw 'now' line on today's page
        }
        var offset = (Time.now().value() - today.value()) * (width - 4) / Gregorian.SECONDS_PER_DAY;
        dc.setColor(Graphics.COLOR_DK_BLUE, Graphics.COLOR_TRANSPARENT);
        var x1 = offset_x + 2.0 + offset;
        dc.drawLine(x1, offset_y + 1, x1, offset_y + height - 1);
        dc.drawLine(x1 - 1, offset_y + 1, x1 - 1, offset_y + height - 1);
    }

    function drawDateString(dc as Dc, selectedDay as Time.Moment) {
        var dateInfo = Gregorian.info(selectedDay, Time.FORMAT_MEDIUM);
        dc.drawText(dc.getWidth() / 2, 8, Graphics.FONT_TINY, dateInfo.month + " " + dateInfo.day.toString(), Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawStationName(dc as Dc) {
        dc.drawText(dc.getWidth() / 2, dc.getWidth() * 0.13, Graphics.FONT_XTINY, StorageUtil.getStationName(), Graphics.TEXT_JUSTIFY_CENTER);
    }

    function updateLocation(position as Position.Location) as Void {
        TideUtil.currentPosition = position;
    }

    function dealWithPosition() {
        if (needGPS) {
	    	if (mPosition == null || mPosition.accuracy == null || mPosition.accuracy < Position.QUALITY_POOR) {
		    	mPosition = Position.getInfo();
                //System.println("setting mPosition in onUpdate()");
		    }
            //System.print("accuracy: " + mPosition.accuracy);
            //System.println(" position: " + mPosition.position.toDegrees());
			if (mPosition.accuracy != null && mPosition.accuracy != Position.QUALITY_NOT_AVAILABLE && mPosition.position != null) {
				if (mPosition.accuracy >= Position.QUALITY_POOR) {
                    //System.println("Got acceptable position; disabling callback");
		            Position.enableLocationEvents(Position.LOCATION_DISABLE, self.method(:onPosition));
					needGPS = false;
	    		}
	    	}
		}
        if (mPosition.position != null) {
            updateLocation(mPosition.position);
        }
        if (mPosition == null || mPosition.position == null || mPosition.accuracy == Position.QUALITY_NOT_AVAILABLE) {
            var cc = Toybox.Weather.getCurrentConditions() as Toybox.Weather.CurrentConditions;
            //System.println("Trying to get position from weather...");
            if (cc != null) {
                var pos = cc.observationLocationPosition as Position.Location;
                if (pos != null) {
                    updateLocation(pos);
                    System.println("Got position from weather: " + pos.toDegrees()[0] + " " + pos.toDegrees()[1]);
                }
            }
        }
    }

    function onUpdate(dc as Dc) as Void {
        View.onUpdate(dc);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        dealWithPosition();

        // Date
        var selectedDay = Time.today().add(new Time.Duration(Gregorian.SECONDS_PER_DAY * mPage));
        drawDateString(dc, selectedDay);

        // Station Name
        drawStationName(dc);

        // Draw page indicator
        mIndicatorL.draw(dc, mPage);

        var offset_x = dc.getWidth() * 0.1 as Number;
        var offset_y = dc.getHeight() / 4;
        var width = dc.getWidth() * 0.8 as Number;
        var height = dc.getHeight() / 2;
        if (TideUtil.tideData(app) != null && app.tideDataValid) {
            var duration_24h = new Time.Duration(Gregorian.SECONDS_PER_HOUR * 24);
            if (PropUtil.getDisplayType() == PropUtil.DISPLAY_PROP_GRAPH) {
                drawTideGraphBox(dc, offset_x, offset_y, width, height);
                drawNowLine(dc, selectedDay, offset_x, offset_y, width, height);
                graphTides(dc, offset_x, offset_y, width, height, selectedDay, selectedDay.add(duration_24h));
            } else {
                tableTides(dc, offset_x, offset_y - 10, width, height, selectedDay, selectedDay.add(duration_24h));
            }
            drawCurrentHeight(dc);
        } else if (StorageUtil.getStationCode() == null) {
            drawNoDataWarning(dc, offset_x, offset_y, width, height, Rez.Strings.noStationSelectedMessage, false);
        } else {
            drawNoDataWarning(dc, offset_x, offset_y, width, height, Rez.Strings.noDataAvailableForStation, true);
        }

        mPageUpdated = false;
    }
}
