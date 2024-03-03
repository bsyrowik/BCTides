import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application.Properties;

    // Convert a result produced by distanceSquaredApproximation() to a distance in km
    function mdistance(d2 as Float) as Float {
        var d = Toybox.Math.sqrt(d2);
        var r = 6371;  // Radius of earth in km
        return d * r;
    }
    function pushWrapCustomBottom(h as HeapOfPair, depth as Number) as Void {
        var stationList = RezUtil.getStationData() as Array<Dictionary>;
        
        var stationsToShow = 7;
        var menu = new LoadMoreMenu("Page " + depth,
            "Page " + (depth + 1), 90, Graphics.COLOR_WHITE, {
                :foreground=>new Rez.Drawables.MenuForeground()
            });
        var allowWrap = true;
        for (var i = 0; i < stationsToShow; i++) {
            var p = h.heapExtractMin();
            if (p == null) {
                menu.disableFooter();
                allowWrap = false;
                break;
            }
            var dist = mdistance(p.distance);
            menu.addItem(
                new BasicCustomMenuItem(
                    stationList[p.index]["code"],
                    stationList[p.index]["name"],
                    dist.format("%.2f") + "km"
                )
            );
        }

        var delegate = new WrapTopCustomDelegate(h, depth, allowWrap);
        WatchUi.pushView(menu, delegate, WatchUi.SLIDE_IMMEDIATE);
    }

class WrapTopCustomDelegate extends SelectStationMenuDelegate {
    private var _h as HeapOfPair;
    private var _depth as Number;
    private var _wrap as Boolean;
    public function initialize(h as HeapOfPair, depth as Number, wrap as Boolean) {
        SelectStationMenuDelegate.initialize();
        _h = h;
        _depth = depth;
        _wrap = wrap;
    }

    public function onBack() as Void {
        for (var i = 0; i < _depth; i++) {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        }
    }

    //! Handle the user navigating off the end of the menu
    //! @param key The key triggering the menu wrap
    //! @return true if wrap is allowed, false otherwise
    public function onWrap(key as Key) as Boolean {
        if (_wrap) {
            if (key == WatchUi.KEY_DOWN) {
                pushWrapCustomBottom(_h, _depth + 1);
            }
        }
        return false;
    }

    //! Handle the footer being selected
    public function onFooter() as Void {
        if (_wrap) {
            pushWrapCustomBottom(_h, _depth + 1);
        }
    }
}

class LoadMoreMenu extends WatchUi.CustomMenu {
    private var _title;
    private var _footer;
    public function initialize(title as String, footer as String, itemHeight as Number,
    backgroundColor as ColorType, options) {
        CustomMenu.initialize(itemHeight, backgroundColor, options);
        _title = title;
        _footer = footer;
    }

    public function disableFooter() as Void {
        _footer = null;
    }

    public function drawTitle(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        // Text
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2, Graphics.FONT_MEDIUM, _title, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    public function drawFooter(dc as Dc) as Void {
        if (_footer == null) {
            return;
        }
        var height = dc.getHeight();
        var centerX = dc.getWidth() / 2;

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        // Text
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() / 3, Graphics.FONT_MEDIUM, _footer, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        // Arrow
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.fillPolygon([[centerX, height - 10] as Array<Number>,
                        [centerX + 5, height - 15] as Array<Number>,
                        [centerX - 5, height - 15] as Array<Number>] as Array< Array<Number> >);
    }
}

class CustomMenuTitle extends WatchUi.Drawable {
    private var _title as String;

    public function initialize(title as String) {
        Drawable.initialize({});
        _title = title;
    }

    public function draw(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2, Graphics.FONT_MEDIUM, _title, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}

class BasicCustomMenuItem extends WatchUi.CustomMenuItem {
    private var _label as String or Symbol;
    private var _subLabel as String or Null;

    public function initialize(id as Number, label as String or Symbol, subLabel as String or Symbol or Null) {
        CustomMenuItem.initialize(id, {});
        _label = label;
        setSubLabel(subLabel);
    }

    public function draw(dc as Dc) as Void {
        var sLabel = _label instanceof String ? _label : WatchUi.loadResource(_label) as String;
        var font = Graphics.FONT_SMALL;
        if (isFocused()) {
            font = Graphics.FONT_LARGE;
        }

        //if (isSelected()) {
        //    dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_BLUE);
        //    dc.clear();
        //}

        // Line
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.drawLine(0, 0, dc.getWidth(), 0);
        dc.drawLine(0, dc.getHeight() - 1, dc.getWidth(), dc.getHeight() - 1);

        // Text
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        if (isFocused() && _subLabel != null) {
            dc.drawText(dc.getWidth() / 2, dc.getHeight() * .3, font, sLabel, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            dc.drawText(dc.getWidth() / 2, dc.getHeight() * .7, Graphics.FONT_SMALL, _subLabel, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        } else {
            dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2, font, sLabel, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    public function setSubLabel(subLabel as String or Symbol or Null) {
        if (subLabel == null || subLabel instanceof String) {
            _subLabel = subLabel;
        } else {
            _subLabel = WatchUi.loadResource(subLabel);
        }
    }
}

class MultiToggleMenuItem extends BasicCustomMenuItem {
    private var _subLabelOptions as Array<Symbol>;
    private var _propName as String;
    private var _index as Number;

    public function initialize(label as Symbol,
                               subLabelOptions as Array<Symbol>,
                               identifier as Number,
                               propName as String) {
        BasicCustomMenuItem.initialize(identifier, label, null);
        _subLabelOptions = subLabelOptions;
        _propName = propName;
        _index = Properties.getValue(_propName);
        if (_index instanceof Boolean) {
            _index = _index ? 1 : 0;
        }
        setSubLabel(_subLabelOptions[_index]);
    }

    public function next() {
        _index = (_index + 1) % _subLabelOptions.size();
        Properties.setValue(_propName, _index);
        setSubLabel(_subLabelOptions[_index]);
    }
}