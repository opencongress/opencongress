function addLoadEvent(func) {    
    var oldonload = window.onload;
    if (typeof window.onload != 'function') {
        window.onload = func;
    } 
    else {
        window.onload = function() {
            oldonload();
            func();
        }
    }
}

function distmap(element_id, multipolygon) {
    addLoadEvent(function() {
    	var map = new GMap2(document.getElementById(element_id))
    	map.addControl(new GSmallZoomControl())
    	var poly, mypoly, coordinates
    	var minlat = Infinity
    	var minlng = Infinity
    	var maxlat = -Infinity
    	var maxlng = -Infinity
        for (mypoly in multipolygon['coordinates']) {
            mypoly = multipolygon['coordinates'][mypoly]
            coordinates = []
            for (coord in mypoly) {
                coord = mypoly[coord]
                coordinates.push(new GLatLng(coord[1], coord[0]))
            }
            poly = new GPolygon(coordinates, '#520099', 2, 0.5, '#B866FF', 0.5)
            map.addOverlay(poly)
            minlat = Math.min(minlat, poly.getBounds().getSouthWest().lat())
            maxlat = Math.max(maxlat, poly.getBounds().getNorthEast().lat())
            minlng = Math.min(minlng, poly.getBounds().getSouthWest().lng())
            maxlng = Math.max(maxlng, poly.getBounds().getNorthEast().lng())
        }
        var bounds = new GLatLngBounds(new GLatLng(minlat, minlng), new GLatLng(maxlat, maxlng))
        map.setCenter(bounds.getCenter(), map.getBoundsZoomLevel(bounds))
    })
}

function distcenter(element_id, districtid, center, mapinfo) {
  addLoadEvent(function() {
    var map = new GMap2(document.getElementById(element_id));
    map.addControl(new GSmallZoomControl());
    
    var WMS_URL = 'http://www.govtrack.us/perl/wms-cd.cgi?';
    var dist_or_state = districtid.length == 2 ? "state" : "district";
    var G_MAP_LAYER_FILLED = createWMSTileLayer(WMS_URL, "cd-filled," + dist_or_state + "=" + districtid, null, "image/gif", null, null, null, .25);
    var G_MAP_LAYER_OUTLINES = createWMSTileLayer(WMS_URL, "cd-outline," + dist_or_state + "=" + districtid, null, "image/gif", null, null, null, .66, "Data from GovTrack.us");
    var G_MAP_OVERLAY = createWMSOverlayMapType([G_NORMAL_MAP.getTileLayers()[0], G_MAP_LAYER_FILLED, G_MAP_LAYER_OUTLINES], "Overlay");

    map.addMapType(G_MAP_OVERLAY);
    map.setCenter(new GLatLng(center[0], center[1]), center[2]);
    map.setMapType(G_MAP_OVERLAY);
    
    if (mapinfo !== undefined) {
        document.getElementById(mapinfo).style.display = 'none';
        var marker = new GMarker(new GLatLng(center[0], center[1]));
       	map.addOverlay(marker);
        GEvent.addListener(marker, "click", function() {
            marker.openInfoWindowHtml(document.getElementById(mapinfo).innerHTML);
        });
       	marker.openInfoWindowHtml(document.getElementById(mapinfo).innerHTML);
    }
  });
}
