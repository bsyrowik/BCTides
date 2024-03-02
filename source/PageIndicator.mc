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

        var radius = dc.getWidth() / 2 - _margin - diameter / 2;
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
