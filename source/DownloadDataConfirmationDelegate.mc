using Toybox.WatchUi;

class DownloadDataConfirmationDelegate extends WatchUi.ConfirmationDelegate {    
    function initialize() {
        ConfirmationDelegate.initialize();
    }

    function onResponse(response) {
        if (response == WatchUi.CONFIRM_YES) {
            WebRequests.getStationInfo();
        }
        return true;
    }
}