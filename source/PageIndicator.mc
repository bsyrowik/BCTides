//
// Copyright 2015-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;

public enum Align {
    ALIGN_CENTER_LEFT,
    ALIGN_CENTER_RIGHT,
    ALIGN_BOTTOM_CENTER,
    ALIGN_TOP_CENTER
}

class PageIndicatorArc {
    private var _size as Number;
//    private var _color as ColorType;
    private var _alignment as Align;
    private var _margin as Number;

    //! Constructor
    //! @param size Number of pages
    //! @param color Color to use for the selected page
    //! @param alignment How to align the graphic
    //! @param margin Amount of margin for the graphic
    public function initialize(size as Number, color as ColorValue, alignment as Align, margin as Number) {
        _size = size;
//        _color = color;
        _alignment = alignment;
        _margin = margin;
    }

    //! Draw the indicator
    //! @param dc Device context
    //! @param selectedIndex The index of the current page
    public function draw(dc as Dc, selectedIndex as Number) as Void {
        var diameter = 3;
        var spacing = 1;

        var radius = dc.getWidth() / 2 - _margin;
        var spacing_deg = diameter + spacing;
        var sweep_deg = diameter * _size + spacing * (_size - 1);

        var start_deg = 0.0f;
        if (_alignment == $.ALIGN_CENTER_RIGHT)  { start_deg = 30f   + sweep_deg / 2; }
        if (_alignment == $.ALIGN_TOP_CENTER)    { start_deg = 135f  + sweep_deg / 2; }
        if (_alignment == $.ALIGN_CENTER_LEFT)   { start_deg = 180f - sweep_deg / 2; }
        if (_alignment == $.ALIGN_BOTTOM_CENTER) { start_deg = 270f - sweep_deg / 2; }

        if(dc has :setAntiAlias) {
            dc.setAntiAlias(true);
        }
        for (var i = 0; i < _size; i++) {
            if (i == selectedIndex) {
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            } else {
                dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            }
            var degreeStart = 0.0f;
            if (_alignment == $.ALIGN_BOTTOM_CENTER || _alignment == $.ALIGN_CENTER_LEFT) {
                degreeStart = start_deg + i * spacing_deg + diameter;
            } else if (_alignment == $.ALIGN_TOP_CENTER || _alignment == $.ALIGN_CENTER_RIGHT) {
                degreeStart = start_deg - i * spacing_deg;
            }

            for (var j = 0; j < 4; j++) {
                dc.drawArc(dc.getWidth() / 2, dc.getHeight() / 2, radius - j, Graphics.ARC_CLOCKWISE, degreeStart, degreeStart - diameter);
            }

        }
    }

}
class PageIndicatorRad {
    private var _size as Number;
    private var _color as ColorType;
    private var _alignment as Align;
    private var _margin as Number;

    //! Constructor
    //! @param size Number of pages
    //! @param color Color to use for the selected page
    //! @param alignment How to align the graphic
    //! @param margin Amount of margin for the graphic
    public function initialize(size as Number, color as ColorValue, alignment as Align, margin as Number) {
        _size = size;
        _color = color;
        _alignment = alignment;
        _margin = margin;
    }

    //! Draw the indicator
    //! @param dc Device context
    //! @param selectedIndex The index of the current page
    public function draw(dc as Dc, selectedIndex as Number) as Void {
        var diameter = dc.getWidth() * 0.03334;
        var spacing = diameter / 2;
        var x = 0;
        var y = 0;

        var radius = dc.getWidth() / 2 - _margin - diameter / 2; // FIXME: what if width and height are not the same??  Probably want a way to support non-circular devices?
        var spacing_rad = Math.atan2(diameter + spacing, radius);
        var sweep_rad = spacing_rad * _size;

        var start_deg = 0.0f;
        if (_alignment == $.ALIGN_CENTER_RIGHT)  { start_deg = 0.0f + sweep_rad / 2; }
        if (_alignment == $.ALIGN_TOP_CENTER)    { start_deg = Math.PI / 2 + sweep_rad / 2; }
        if (_alignment == $.ALIGN_BOTTOM_CENTER) { start_deg = -Math.PI / 2 - sweep_rad / 2; }
        if (_alignment == $.ALIGN_CENTER_LEFT)   { start_deg = Math.PI - sweep_rad / 2; }

        dc.setColor(_color, Graphics.COLOR_TRANSPARENT);
        for (var i = 0; i < _size; i++) {
            var deg = 0.0f;
            if (_alignment == $.ALIGN_BOTTOM_CENTER || _alignment == $.ALIGN_CENTER_LEFT) {
                deg = start_deg + i * spacing_rad + spacing_rad / 2;
            } else if (_alignment == $.ALIGN_TOP_CENTER || _alignment == $.ALIGN_CENTER_RIGHT) {
                deg = start_deg - i * spacing_rad - spacing_rad / 2;
            }
            x = dc.getWidth()  / 2 + radius * Math.cos(deg);
            y = dc.getHeight() / 2 - radius * Math.sin(deg);

            if (i == selectedIndex) {
                dc.fillCircle(x, y, diameter / 2);
            } else {
                dc.drawCircle(x, y, diameter / 2);
            }
        }
    }

}
//! Draws a graphic indicating which page the user is currently on
class PageIndicator {
    private var _size as Number;
    private var _color as ColorType;
    private var _alignment as Align;
    private var _margin as Number;

    //! Constructor
    //! @param size Number of pages
    //! @param color Color to use for the selected page
    //! @param alignment How to align the graphic
    //! @param margin Amount of margin for the graphic
    public function initialize(size as Number, color as ColorValue, alignment as Align, margin as Number) {
        _size = size;
        _color = color;
        _alignment = alignment;
        _margin = margin;
    }

    //! Draw the indicator
    //! @param dc Device context
    //! @param selectedIndex The index of the current page
    public function draw(dc as Dc, selectedIndex as Number) as Void {
        var diameter = 8;
        var spacing = 4;
        var length = _size * diameter + (_size - 1) * spacing;
        var x = 0;
        var y = 0;

        if (_alignment == $.ALIGN_BOTTOM_CENTER) {
            x = (dc.getWidth() / 2) - (length / 2);
            y = dc.getHeight() - diameter / 2 - _margin;
        } else if (_alignment == $.ALIGN_TOP_CENTER) {
            x = (dc.getWidth() / 2) - (length / 2);
            y = 0 + _margin + diameter / 2;
        } else if (_alignment == $.ALIGN_CENTER_LEFT) {
            x = 0 + _margin + diameter / 2;
            y = (dc.getHeight() / 2) - (length / 2);
        } else if (_alignment == $.ALIGN_CENTER_RIGHT) {
            x = dc.getWidth() - diameter / 2 - _margin;
            y = (dc.getHeight() / 2) - (length / 2);
        }

        dc.setColor(_color, Graphics.COLOR_TRANSPARENT);
        for (var i = 0; i < _size; i++) {
            var tempX = x;
            var tempY = y;
            if (_alignment == $.ALIGN_CENTER_LEFT || _alignment == $.ALIGN_CENTER_RIGHT) {
                tempY = (y + (i * diameter)) + diameter / 2 + spacing * i;
            } else {
                tempX = (x + (i * diameter)) + diameter / 2 + spacing * i;
            }
            if (i == selectedIndex) {
                dc.fillCircle(tempX, tempY, diameter / 2);
            } else {
                dc.drawCircle(tempX, tempY, diameter / 2);
            }
        }
    }

}
