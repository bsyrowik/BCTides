using Toybox.WatchUi;

class DownloadDataConfirmationDelegate extends WatchUi.ConfirmationDelegate {    
    var mDelegate = null;

    function initialize(d as BCTidesDelegate) {
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