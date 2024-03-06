import Toybox.Communications;
import Toybox.Lang;
import Toybox.System;
import Toybox.Application.Storage;
import Toybox.Background;

using Toybox.WatchUi;

(:background)
module WebRequests {    
    function getStationData(station_id as String, stationIndex as Number) as Void {
        //System.println("Getting station data...");
        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
            :headers => {
                "Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED
            },
            :context => stationIndex
        };
        Communications.makeWebRequest( 
            "https://api-iwls.dfo-mpo.gc.ca/api/v1/stations/" + station_id + "/data",
            {
                "time-series-code" => "wlp-hilo",
                "from" => DateUtil.getFromDateString(),
                "to" => DateUtil.getToDateString()
            },
            options,
            new Method(WebRequests, :onReceive)
        );
    }

    function getStationInfo(stationIndex as Number) as Void {
        //System.println("Getting station info...");
        if (StorageUtil.getStationCode(stationIndex) == null) {
            return;
        }
        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
            :headers => {
                "Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED
            },
            :context => stationIndex
        };
        Communications.makeWebRequest(
            "https://api-iwls.dfo-mpo.gc.ca/api/v1/stations/",
            {
                "code" => StorageUtil.getStationCode(stationIndex)
            },
            options,
            new Method(WebRequests, :onReceiveStationInfo)
        );
    }

    function onReceiveStationInfo(responseCode as Number, data as Dictionary?, context as Object) as Void {
        //System.println("onReceiveStationInfo called....");
        //System.println("  responseCode:" + responseCode.toString());
        if (responseCode == 200) { // OK!
            if (data instanceof Array) {
                var station = data[0] as Dictionary;
                var station_id = station["id"].toString();
                //var requested_station_data = station["officialName"].toString();
                getStationData(station_id, context as Number);
            }
        } else if (responseCode == Communications.BLE_CONNECTION_UNAVAILABLE) {
            // TODO: try Wi-Fi bulk download?
            System.println("Failed to load - BLE connection unavailable");
        } else {
            System.println("Failed to load - Error: " + responseCode.toString());
        }
    }

    function onReceive(responseCode as Number, data as Dictionary?, context as Object) as Void {
        //System.println("onReceive called....");
        //System.println("  responseCode:" + responseCode.toString());
        if (responseCode == 200) { // OK!
            onReceiveData(data, context as Number);
        } else if (responseCode == Communications.BLE_CONNECTION_UNAVAILABLE) {
            // TODO: try Wi-Fi bulk download?
            System.println("Failed to load - BLE connection unavailable");
        } else {
            System.println("Failed to load - Error: " + responseCode.toString());
        }
    }

    public function onReceiveData(args as Dictionary or String or Array or Null, stationIndex as Number) as Void {
        //System.println("View:onReceive() \"" + args.toString() + "\"");
        if (args instanceof Array) {
            var app = getApp();
            var maxTide = 0.0;
            //System.println("Got an array!");
            if (app.tideData == null) {
                app.tideData = [];
                for (var i = 0; i < 3; i++) { // FIXME: do not hard code 3
                    app.tideData.add([]);
                }
            }
            app.tideData[stationIndex] = [];
            for (var i = 0; i < args.size(); i++) {
                var eventData = args[i] as Dictionary;
                var height = eventData["value"].toFloat();
                if (height > maxTide) {
                    maxTide = height;
                }
                app.tideData[stationIndex].add([DateUtil.parseDateString(eventData["eventDate"].toString()).value(), height]);
            }
            app.tideDataValid[stationIndex] = true;
            //System.println(app.tideData[stationIndex].toString());

            Storage.setValue("tideData", app.tideData);
            StorageUtil.setMaxTide(stationIndex, maxTide);
            
            System.println("Successfully updated station '" + StorageUtil.getStationName(stationIndex) + "' data at " + Toybox.Time.now().value());
                
            if (app.background) {
                Background.exit(true);
            } else {
                Notification.showNotification(Rez.Strings.dataReceivedMessage as String, 2000);
                WatchUi.requestUpdate();
            }
        } else {
            System.println("Received unexpected data from API call.");
        }
    }
}