import Toybox.WatchUi;
import Toybox.Graphics;

(:glance)
class BCTidesGlanceView extends WatchUi.GlanceView {
    var app;

    function initialize(the_app) {
        app = the_app;
        GlanceView.initialize();    	         
    }

    function drawNoDataMessage(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(0, 10, Graphics.FONT_GLANCE_NUMBER, "No tide data available.", Graphics.TEXT_JUSTIFY_LEFT);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(0, 30, Graphics.FONT_GLANCE, "Open app to load data.", Graphics.TEXT_JUSTIFY_LEFT);
    }

    function onUpdate(dc as Dc) {
		dc.setColor(Graphics.COLOR_BLACK,Graphics.COLOR_BLACK);
		dc.clear();
		dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_TRANSPARENT);
        var units = "m";
        var now = Time.now().value();

        // TODO: get this data dynamically
        var next_event = TideUtil.getNextEvent(now, app);
        if (next_event[0] == null) {
            drawNoDataMessage(dc);
            return;
        }
        var current_height = 2.1;
        var next_event_height = next_event[1];
        var next_event_time = (next_event[0] - now) / 60; //"2H 27M";
        var next_event_type = next_event[2]; //"H";
        var current_direction = next_event_type.equals("H") ? "rising" : "falling";
        var current_station = TideUtil.current_station_name;


        if (app._hilo != null) {
            current_height = TideUtil.getHeightAtT(now, 1200, 0, app)[0];
            if (current_height == null) {
                drawNoDataMessage(dc);
                return;
            }
        }


        if (PropUtil.getUnits() == System.UNIT_STATUTE) {
            units = "ft";
            next_event_height *= TideUtil.FEET_PER_METER;
            current_height *= TideUtil.FEET_PER_METER;
        }

        var lineHeight = dc.getFontHeight(Graphics.FONT_GLANCE); // FONT_GLANCE:  FR745: 19 FR965: 42     FONT_GLANCE_NUMBER:  FR745: 19 FR965: 53
        lineHeight *= 0.85; // FR745: 16
        //System.println("FontHeight FONT_GLANCE: " + lineHeight);
        //System.println("FontHeight FONT_GLANCE_NUMBER: " + dc.getFontHeight(Graphics.FONT_GLANCE_NUMBER));

		dc.drawText(0, 0, Graphics.FONT_GLANCE, next_event_height.format("%.1f") + units + " " + next_event_type + " in " + next_event_time + "min", Graphics.TEXT_JUSTIFY_LEFT);
        // TODO
        //dc.drawBitmap(0, 16, "location2.png");

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
        // The FONT_GLANCE_NUMBER is much larger!
        //System.print("dc height: "); System.println(dc.getHeight());
        // Height is 63 pixels
    } 
}
