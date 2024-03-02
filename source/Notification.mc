import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.WatchUi;

module Notification {
    function showNotification(message as String, timeout as Number or Null) as Void {
        var notificationView = new NotificationView(message, timeout);
        WatchUi.pushView(
            notificationView,
            new NotificationViewDelegate(notificationView),
            WatchUi.SLIDE_IMMEDIATE
        );
    }

    // Behavior Delegate that pops the view on any input
    class NotificationViewDelegate extends WatchUi.BehaviorDelegate {
        private var mView;
        
        function initialize(view as NotificationView) {
            mView = view;
            BehaviorDelegate.initialize();
        }
        
        // Helper function - all events produce same behavior
        private function processEvent(event) as Boolean {
            mView.disableTimer();
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
        private var mTimer = null;
        private var mText;

        function disableTimer() as Void {
            if (mTimer != null) {
                mTimer.stop();
            }
        }

        function timerCallback() as Void {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        }

        function initialize(message as String, timeout as Number or Null) {
            View.initialize();
            mText = message;
            if (timeout != null) {
                mTimer = new Timer.Timer();
                mTimer.start(method(:timerCallback), timeout, false);  // Auto-dismiss after 'timeout' milliseconds
            }
        }

        public function onLayout( dc as Dc ) as Void {
            setLayout(Rez.Layouts.NotificationLayout(dc));
            var notificationText = View.findDrawableById("notificationText") as Text;
            notificationText.setText(mText);
        }

        public function onUpdate( dc as Dc) as Void {
            View.onUpdate(dc);
        }
    }
}