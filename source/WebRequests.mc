import Toybox.Communications;
import Toybox.Lang;
import Toybox.System;
import Toybox.Application.Storage;
import Toybox.Background;

using Toybox.WatchUi;

(:background)
module WebRequests {    
    function getStationData(station_id as String, ndx as Number) as Void {
        //System.println("Getting station data...");
        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
            :headers => {
                "Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED
            },
            :context => ndx
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

    function getStationInfo(ndx as Number) as Void {
        //System.println("Getting station info...");
        if (StorageUtil.getStationCode(ndx) == null) {
            return;
        }
        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
            :headers => {
                "Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED
            },
            :context => ndx
        };
        Communications.makeWebRequest(
            "https://api-iwls.dfo-mpo.gc.ca/api/v1/stations/",
            {
                "code" => StorageUtil.getStationCode(ndx)
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

    public function onReceiveData(args as Dictionary or String or Array or Null, ndx as Number) as Void {
        //System.println("View:onReceive() \"" + args.toString() + "\"");
        if (args instanceof Array) {
            var app = getApp();
            var maxTide = 0.0;
            //System.println("Got an array!");
            if (app._hilo == null) {
                app._hilo = [];
                for (var i = 0; i < 3; i++) { // FIXME: do not hard code 3
                    app._hilo.add([]);
                }
            }
            app._hilo[ndx] = [];
            for (var i = 0; i < args.size(); i++) {
                var eventData = args[i] as Dictionary;
                var height = eventData["value"].toFloat();
                if (height > maxTide) {
                    maxTide = height;
                }
                app._hilo[ndx].add([DateUtil.parseDateString(eventData["eventDate"].toString()).value(), height]);
            }
            app.tideDataValid[ndx] = true;
            //System.println(app._hilo[ndx].toString());

            Storage.setValue("tideData", app._hilo);
            StorageUtil.setMaxTide(ndx, maxTide);
            
            System.println("Successfully updated station '" + StorageUtil.getStationName(ndx) + "' data at " + Toybox.Time.now().value());
                
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