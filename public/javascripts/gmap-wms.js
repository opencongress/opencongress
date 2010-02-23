CustomGetTileUrl = function(a, b, c) {
	if (typeof(window['this.myMercZoomLevel']) == "undefined") this.myMercZoomLevel = 0;
	if (typeof(window['this.myStyles']) == "undefined") this.myStyles = "";
	var lULP = new GPoint(a.x * 256, (a.y + 1) * 256);
	var lLRP = new GPoint((a.x + 1) * 256, a.y * 256);
	var lUL = G_NORMAL_MAP.getProjection().fromPixelToLatLng(lULP, b, c);
	var lLR = G_NORMAL_MAP.getProjection().fromPixelToLatLng(lLRP, b, c);
	// switch between Mercator and DD if merczoomlevel is set
	//if (this.myMercZoomLevel != 0 && map.getZoom() < this.myMercZoomLevel) {
	//	var lBbox = dd2MercMetersLng(lUL.lngDegrees) + "," + dd2MercMetersLat(lUL.latDegrees) + "," + dd2MercMetersLng(lLR.lngDegrees) + "," + dd2MercMetersLat(lLR.latDegrees);
		var lSRS = "EPSG:54004";
	//} else {
		var lBbox = lUL.x + "," + lUL.y + "," + lLR.x + "," + lLR.y;
	//	var lSRS = "EPSG:4326";
	//}
	var lURL = this.myBaseURL;
	lURL += "&REQUEST=GetMap";
	lURL += "&SERVICE=WMS";
	lURL += "&VERSION=" + this.myVersion;
	lURL += "&LAYERS=" + this.myLayers;
	lURL += "&STYLES=" + this.myStyles;
	lURL += "&FORMAT=" + this.myFormat;
	lURL += "&BGCOLOR=" + this.myBgColor;
	lURL += "&TRANSPARENT=TRUE";
	lURL += "&SRS=" + lSRS;
	lURL += "&BBOX=" + lBbox;
	lURL += "&WIDTH=256";
	lURL += "&HEIGHT=256";
	lURL += "&reaspect=false";
	return lURL;
}

function createWMSTileLayer(wmsURL, wmsLayers, wmsStyles, wmsFormat, wmsVersion, wmsBgColor, wmsSrs, opacity, copyright) {
	var copyCollection;
	if (window.GCopyrightCollection) { // not available for mapplets
		copyCollection = new GCopyrightCollection('');
		if (copyright != null) {
			var c = new GCopyright(1, new GLatLngBounds(new GLatLng(-90, -180), new GLatLng(90, 180)), 0, copyright);
			copyCollection.addCopyright(c);
		}
	}
	
	var tile = new GTileLayer(copyCollection, 1, 17);
	tile.myLayers = wmsLayers;
	tile.myStyles = (wmsStyles ? wmsStyles : "");
	;
	tile.myFormat = (wmsFormat ? wmsFormat : "image/gif");
	;
	tile.myVersion = (wmsVersion ? wmsVersion : "1.1.1");
	tile.myBgColor = (wmsBgColor ? wmsBgColor : "0xFFFFFF");
	tile.myBaseURL = wmsURL;
	tile.getTileUrl = CustomGetTileUrl;

	if (opacity) { tile.getOpacity = function() { return opacity; } }

	return tile;
}

function createWMSMapType(layer, gName) {
	var mapType = new GMapType([layer], G_SATELLITE_MAP.getProjection(), gName, G_SATELLITE_MAP);
	return mapType;
}

function createWMSOverlayMapType(layers, gName) {
	return new GMapType(layers, G_SATELLITE_MAP.getProjection(), gName);

}

// Clients use old variable names despite Google deprecating
// an old API version. We help them out.
var G_MAP_TYPE = G_NORMAL_MAP;
var G_SATELLITE_TYPE = G_SATELLITE_MAP;
