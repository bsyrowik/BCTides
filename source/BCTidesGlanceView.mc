import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

(:glance)
class BCTidesGlanceView extends WatchUi.GlanceView {
    private var _app as BCTidesApp;

    function initialize(the_app as BCTidesApp) {
        _app = the_app;
        GlanceView.initialize();
    }

    function drawNoDataMessage(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(0, 0, Graphics.FONT_GLANCE_NUMBER, "No tide data available.", Graphics.TEXT_JUSTIFY_LEFT);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(0, dc.getFontHeight(Graphics.FONT_GLANCE_NUMBER), Graphics.FONT_GLANCE, "Open app to load data.", Graphics.TEXT_JUSTIFY_LEFT);
    }

    function drawGlanceNew(dc as Dc, current_height as Number, next_event_height as Number, next_event_time as Number, next_event_type as String, current_station as String) as Void {
        //var current_direction = next_event_type.equals("H") ? "rising" : "falling";
        
        var units = PropUtil.units();
        var heightMultiplier = PropUtil.heightMultiplier();
        next_event_height *= heightMultiplier;
        current_height *= heightMultiplier;

        var lineHeight = dc.getFontHeight(Graphics.FONT_GLANCE); // FONT_GLANCE:  FR745: 19 FR965: 42     FONT_GLANCE_NUMBER:  FR745: 19 FR965: 53
        lineHeight *= 0.85; // FR745: 16

        var numHeight = dc.getFontHeight(Graphics.FONT_NUMBER_MEDIUM);


		dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);

        // Height with units
        var heightString = current_height.format("%.1f");
        dc.drawText(0, - numHeight * 0.19, Graphics.FONT_NUMBER_MEDIUM, heightString, Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(dc.getTextWidthInPixels(heightString, Graphics.FONT_NUMBER_MEDIUM), numHeight * 0.72 - dc.getFontHeight(Graphics.FONT_LARGE), Graphics.FONT_LARGE, units, Graphics.TEXT_JUSTIFY_LEFT);

		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        // Draw position indicator
        var radius = lineHeight * .25;
        var center_x = lineHeight * 0.4375;
        var center_y = numHeight * 0.66 + lineHeight * .5;
        var line_length = lineHeight * .8125;
        dc.drawCircle(center_x, center_y, radius);
        dc.drawLine(1, center_y, line_length + 1, center_y); // horizontal
        dc.drawLine(center_x, center_y - line_length / 2, center_x, center_y + line_length / 2); // vertical line

        // Station Name
        dc.drawText(line_length * 1.3, numHeight * 0.66, Graphics.FONT_GLANCE, current_station, Graphics.TEXT_JUSTIFY_LEFT);
    }

    function drawGlance(dc as Dc, current_height as Number, next_event_height as Number, next_event_time as Number, next_event_type as String, current_station as String) as Void {
        var current_direction = next_event_type.equals("H") ? "rising" : "falling";
        
        var units = PropUtil.units();
        var heightMultiplier = PropUtil.heightMultiplier();
        next_event_height *= heightMultiplier;
        current_height *= heightMultiplier;

        var lineHeight = dc.getFontHeight(Graphics.FONT_GLANCE); // FONT_GLANCE:  FR745: 19 FR965: 42     FONT_GLANCE_NUMBER:  FR745: 19 FR965: 53
        lineHeight *= 0.85; // FR745: 16
        //System.println("FontHeight FONT_GLANCE: " + lineHeight);
        //System.println("FontHeight FONT_GLANCE_NUMBER: " + dc.getFontHeight(Graphics.FONT_GLANCE_NUMBER));

        dc.drawText(0, 0, Graphics.FONT_GLANCE, next_event_height.format("%.1f") + units + " " + next_event_type + " in " + next_event_time + "min", Graphics.TEXT_JUSTIFY_LEFT);

        // Draw position indicator
        // Numbers are a bit odd; this is just what looks good.
        var radius = lineHeight * .25;
        var center_x = lineHeight * 0.4375;
        var center_y = lineHeight * 1.61;
        var line_length = lineHeight * .8125;
        dc.drawCircle(center_x, center_y, radius);
        dc.drawLine(1, center_y, line_length + 1, center_y); // horizontal
        dc.drawLine(center_x, center_y - line_length / 2 + 1, center_x, center_y + line_length / 2 + 1); // vertical line

        dc.drawText(line_length * 1.3, lineHeight, Graphics.FONT_GLANCE, current_station, Graphics.TEXT_JUSTIFY_LEFT);

		dc.setColor(Graphics.COLOR_BLUE,Graphics.COLOR_TRANSPARENT);
        dc.drawText(0, lineHeight * 2, Graphics.FONT_GLANCE, current_height.format("%.1f") + units + " and " + current_direction, Graphics.TEXT_JUSTIFY_LEFT);
    }

    function onUpdate(dc as Dc) {
		var now = Time.now().value();

        var next_event = TideUtil.getNextEvent(now, _app, 0);
        if (next_event[0] == null) {
            drawNoDataMessage(dc);
            return;
        }

        if (TideUtil.tideData(_app, 0) != null) {
            var current_height = TideUtil.getHeightAtT(now, 1200, 0, _app, 0)[0];
            if (current_height == null) {
                drawNoDataMessage(dc);
                return;
            }

            var next_event_height = next_event[1];
            var next_event_time = (next_event[0] - now) / 60;
            var next_event_type = next_event[2]; // "H" or "L"
            var current_station = StorageUtil.getStationName(0);

            drawGlanceNew(dc, current_height, next_event_height, next_event_time, next_event_type, current_station);
        }
    } 
}
