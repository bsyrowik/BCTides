import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application.Properties;

class LoadMoreMenuDelegate extends SelectStationMenuDelegate {
    private var _data as Object;
    private var _depth as Number;
    private var _wrap as Boolean;
    private var _callback as Method;

    public function initialize(callback as Method, data as Object, depth as Number, wrap as Boolean) {
        SelectStationMenuDelegate.initialize();
        _callback = callback;
        _data = data;
        _depth = depth;
        _wrap = wrap;
    }

    public function onBack() as Void {
        for (var i = 0; i < _depth; i++) {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        }
    }

    // Handle navigating off the end of the menu
    public function onWrap(key as Key) as Boolean {
        if (key == WatchUi.KEY_DOWN) {
            onFooter();
        }
        return false;
    }

    public function onSelect(item) {
        SelectStationMenuDelegate.onSelect(item);
        for (var i = 0; i < _depth - 1; i++) {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        }
    }

    // Handle footer being selected
    public function onFooter() as Void {
        if (_wrap) {
            _callback.invoke("Page " + (_depth + 1), _data, _depth + 1);
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

    public function initialize(title as String or Symbol) {
        Drawable.initialize({});
        if (title instanceof String) {
            _title = title;
        } else {
            _title = WatchUi.loadResource(title) as String;
        }
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

        // Line
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.drawLine(0, 0, dc.getWidth(), 0);
        dc.drawLine(0, dc.getHeight() - 1, dc.getWidth(), dc.getHeight() - 1);

        // Text
        // FIXME: use a TextArea instead so we get auto-wrapping!!!  Especially important for localizations.
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        if (isFocused() && _subLabel != null) {
            dc.drawText(dc.getWidth() / 2, dc.getHeight() * .3, font, sLabel, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            dc.drawText(dc.getWidth() / 2, dc.getHeight() * .7, Graphics.FONT_SMALL, _subLabel, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        } else {
            dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2, font, sLabel, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    public function getLabel() as String {
        return _label instanceof String ? _label : WatchUi.loadResource(_label) as String;
    }

    public function setSubLabel(subLabel as String or Symbol or Null) {
        if (subLabel == null || subLabel instanceof String) {
            _subLabel = subLabel;
        } else {
            _subLabel = WatchUi.loadResource(subLabel) as String;
        }
        if (_subLabel != null && _subLabel.length() == 0) {
            _subLabel = null;
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