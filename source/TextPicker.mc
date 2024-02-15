using Toybox.WatchUi;
import Toybox.Lang;

// A string to display on the screen
var screenMessage = "Press Menu to Enter Text";
var lastText = "";

class MyTextPickerDelegate extends WatchUi.TextPickerDelegate {
    function initialize() {
        TextPickerDelegate.initialize();
    }

    function onTextEntered(text, changed) as Boolean {
        screenMessage = text + "\n" + "Changed: " + changed;
        lastText = text;
        return false;
    }

    function onCancel() as Boolean {
        screenMessage = "Canceled";
        return false;
    }
}

class MyInputDelegate extends WatchUi.InputDelegate {
    function initialize() {
        InputDelegate.initialize();
    }

    function onKey(key) {
        if (WatchUi has :TextPicker) {
            if (key.getKey() == WatchUi.KEY_MENU) {
                WatchUi.pushView(
                    new WatchUi.TextPicker(lastText),
                    new MyTextPickerDelegate(),
                    WatchUi.SLIDE_DOWN
                );
            }
        }
        return true;
    }
}