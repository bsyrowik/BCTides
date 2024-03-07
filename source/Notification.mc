import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.WatchUi;

module Notification {
    function showNotification(message as String or Symbol, timeout as Number?) as Void {
        var notificationView = new NotificationView(message, timeout);
        WatchUi.pushView(
            notificationView,
            new NotificationViewDelegate(notificationView),
            WatchUi.SLIDE_IMMEDIATE
        );
    }

    // Behavior Delegate that pops the view on any input
    class NotificationViewDelegate extends WatchUi.BehaviorDelegate {
        private var _view;
        
        function initialize(view as NotificationView) {
            _view = view;
            BehaviorDelegate.initialize();
        }
        
        // Helper function - all events produce same behavior
        private function processEvent(event) as Boolean {
            _view.disableTimer();
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            return true;
        }
        
        function onKey(event) { return processEvent(event); }
        function onTap(event) { return processEvent(event); }
        function onFlick(event) { return processEvent(event); }
        function onSwipe(event) { return processEvent(event); }
    }

    // View to display a message
    class NotificationView extends WatchUi.View {
        private var _timer = null;
        private var _text;

        function disableTimer() as Void {
            if (_timer != null) {
                _timer.stop();
            }
        }

        function timerCallback() as Void {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        }

        function initialize(message as String or Symbol, timeout as Number?) {
            View.initialize();
            _text = message instanceof String ? message : Application.loadResource(message);
            if (timeout != null) {
                _timer = new Timer.Timer();
                _timer.start(method(:timerCallback), timeout, false);  // Auto-dismiss after 'timeout' milliseconds
            }
        }

        public function onLayout( dc as Dc ) as Void {
            setLayout(Rez.Layouts.NotificationLayout(dc));
            var notificationText = View.findDrawableById("notificationText") as Text;
            notificationText.setText(_text);
        }

        public function onUpdate( dc as Dc) as Void {
            View.onUpdate(dc);
        }
    }
}