import Toybox.WatchUi;
import Toybox.Graphics;
using Toybox.Timer;

// Behaviour Delegate that pops the view on any input
class GotDataViewDelegate extends WatchUi.BehaviorDelegate {
    function initialize() { BehaviorDelegate.initialize(); }
    function onKey(event) { WatchUi.popView(WatchUi.SLIDE_IMMEDIATE); return true; }
    function onTap(event) { WatchUi.popView(WatchUi.SLIDE_IMMEDIATE); return true; }
    function onFlick(event) { WatchUi.popView(WatchUi.SLIDE_IMMEDIATE); return true; }
    function onSwipe(event) { WatchUi.popView(WatchUi.SLIDE_IMMEDIATE); return true; }
}

class GotDataView extends WatchUi.View {

    function timerCallback() as Void {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }

    function initialize() {
        View.initialize();
        var theTimer = new Timer.Timer();
        theTimer.start(method(:timerCallback), 2000, false);
    }

    public function onLayout( dc as Dc ) as Void {
        setLayout( Rez.Layouts.GotDataPrompt( dc ) );
    }

    public function onUpdate( dc as Dc) as Void {
        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate( dc );
    }
}