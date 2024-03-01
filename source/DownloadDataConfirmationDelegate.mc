using Toybox.WatchUi;
using Toybox.System;

class DownloadDataConfirmationDelegate extends WatchUi.ConfirmationDelegate {    
    var mDelegate = null;

    function initialize(d as CanTideDelegate) {
        mDelegate = d;
        ConfirmationDelegate.initialize();
    }

    function onResponse(response) {
        if (response == WatchUi.CONFIRM_YES) {
            mDelegate.getStationInfo();
        }
        return true;
    }
}