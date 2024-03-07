import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

(:glance)
class BCTidesGlanceView extends WatchUi.GlanceView {
    function initialize() {
        GlanceView.initialize();
    }

    function drawNoDataMessage(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(0, 0, Graphics.FONT_GLANCE_NUMBER, "No tide data available.", Graphics.TEXT_JUSTIFY_LEFT);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(0, dc.getFontHeight(Graphics.FONT_GLANCE_NUMBER), Graphics.FONT_GLANCE, "Open app to load data.", Graphics.TEXT_JUSTIFY_LEFT);
    }

    function drawGlanceNew(dc as Dc, currentHeight as Number, nextEventHeight as Number, nextEventTime as Number, nextEventType as String, currentStation as String) as Void {
        //var currentDirection = nextEventType.equals("H") ? "rising" : "falling";
        
        var units = PropUtil.units();
        var heightMultiplier = PropUtil.heightMultiplier();
        nextEventHeight *= heightMultiplier;
        currentHeight *= heightMultiplier;

        var lineHeight = dc.getFontHeight(Graphics.FONT_GLANCE); // FONT_GLANCE:  FR745: 19 FR965: 42     FONT_GLANCE_NUMBER:  FR745: 19 FR965: 53
        lineHeight *= 0.85; // FR745: 16

        var numHeight = dc.getFontHeight(Graphics.FONT_NUMBER_MEDIUM);


		dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);

        // Height with units
        var heightString = currentHeight.format("%.1f");
        dc.drawText(0, - numHeight * 0.19, Graphics.FONT_NUMBER_MEDIUM, heightString, Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(dc.getTextWidthInPixels(heightString, Graphics.FONT_NUMBER_MEDIUM), numHeight * 0.72 - dc.getFontHeight(Graphics.FONT_LARGE), Graphics.FONT_LARGE, units, Graphics.TEXT_JUSTIFY_LEFT);

		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        // Draw position indicator
        var radius = lineHeight * .25;
        var center_x = lineHeight * 0.4375;
        var center_y = numHeight * 0.66 + lineHeight * .5;
        var lineLength = lineHeight * .8125;
        dc.drawCircle(center_x, center_y, radius);
        dc.drawLine(1, center_y, lineLength + 1, center_y); // horizontal
        dc.drawLine(center_x, center_y - lineLength / 2, center_x, center_y + lineLength / 2); // vertical line

        // Station Name
        dc.drawText(lineLength * 1.3, numHeight * 0.66, Graphics.FONT_GLANCE, currentStation, Graphics.TEXT_JUSTIFY_LEFT);
    }

    function drawGlance(dc as Dc, currentHeight as Number, nextEventHeight as Number, nextEventTime as Number, nextEventType as String, currentStation as String) as Void {
        var currentDirection = nextEventType.equals("H") ? "rising" : "falling";
        
        var units = PropUtil.units();
        var heightMultiplier = PropUtil.heightMultiplier();
        nextEventHeight *= heightMultiplier;
        currentHeight *= heightMultiplier;

        var lineHeight = dc.getFontHeight(Graphics.FONT_GLANCE); // FONT_GLANCE:  FR745: 19 FR965: 42     FONT_GLANCE_NUMBER:  FR745: 19 FR965: 53
        lineHeight *= 0.85; // FR745: 16
        //System.println("FontHeight FONT_GLANCE: " + lineHeight);
        //System.println("FontHeight FONT_GLANCE_NUMBER: " + dc.getFontHeight(Graphics.FONT_GLANCE_NUMBER));

        dc.drawText(0, 0, Graphics.FONT_GLANCE, nextEventHeight.format("%.1f") + units + " " + nextEventType + " in " + nextEventTime + "min", Graphics.TEXT_JUSTIFY_LEFT);

        // Draw position indicator
        // Numbers are a bit odd; this is just what looks good.
        var radius = lineHeight * .25;
        var center_x = lineHeight * 0.4375;
        var center_y = lineHeight * 1.61;
        var lineLength = lineHeight * .8125;
        dc.drawCircle(center_x, center_y, radius);
        dc.drawLine(1, center_y, lineLength + 1, center_y); // horizontal
        dc.drawLine(center_x, center_y - lineLength / 2 + 1, center_x, center_y + lineLength / 2 + 1); // vertical line

        dc.drawText(lineLength * 1.3, lineHeight, Graphics.FONT_GLANCE, currentStation, Graphics.TEXT_JUSTIFY_LEFT);

		dc.setColor(Graphics.COLOR_BLUE,Graphics.COLOR_TRANSPARENT);
        dc.drawText(0, lineHeight * 2, Graphics.FONT_GLANCE, currentHeight.format("%.1f") + units + " and " + currentDirection, Graphics.TEXT_JUSTIFY_LEFT);
    }

    function onUpdate(dc as Dc) {
		var now = Time.now().value();

        var nextEvent = TideUtil.getNextEvent(now, /*stationIndex*/0);
        if (nextEvent[:eventTime] == null) {
            drawNoDataMessage(dc);
            return;
        }

        if (TideUtil.tideData(0) != null) {
            var currentHeight = TideUtil.getHeightAtT(now, 1200, 0)[:height];
            if (currentHeight == null) {
                drawNoDataMessage(dc);
                return;
            }

            var nextEventHeight = nextEvent[:eventHeight];
            var nextEventTime = (nextEvent[:eventHeight] - now) / 60;
            var nextEventType = nextEvent[:eventType]; // "H" or "L"
            var currentStation = StorageUtil.getStationName(0);

            drawGlanceNew(dc, currentHeight, nextEventHeight, nextEventTime, nextEventType, currentStation);
        }
    } 
}
