function DataManager() {
	// Properties
	var self = this;
	self.RequestCompleteEvent = null;
	this.RequestCompleteEvent = self.RequestCompleteEvent;
	self.RequestFailedEvent = null;
	this.RequestFailedEvent = self.RequestFailedEvent;
	// Param is a property where you can store information which you may require
	// once the datahandler is complete. For example, the translation of the
	// word "complete" for alerting that something is finished. It can be
	// referenced from within the RequestCompleteEvent or RequestFailedEvent
	// events with this.Param.
	self.Param = null;
	this.Param = self.Param;
	
	// Methods
	this.CreateDataHandler = function(Request) {
		var DataHandler = function() {
			if (Request.readyState == 4) {
				if (Request.status == 200) {
					self.RequestCompleteEvent(Request);
				} else {
					self.RequestFailedEvent(Request);
				}
			}
		}
		DataHandler.Request = Request;
		DataHandler.RequestCompleteEvent = self.RequestCompleteEvent;
		DataHandler.RequestFailedEvent = self.RequestFailedEvent;
		DataHandler.Param = self.Param;
		return DataHandler;
	}
	this.InitiateXmlHttpRequest = function() {
		var Request = null;
		try {
			Request = new ActiveXObject("Msxml2.XMLHTTP");
		} catch(e) {
			try {
				Request = new ActiveXObject("Microsoft.XMLHTTP");
			} catch(oc) {
				Request = null;
			}
		}
		if (!Request && typeof(XMLHttpRequest) != "undefined") Request = new XMLHttpRequest();
		if (!Request) alert("Failed to create new ajax request.");
		return Request;
	}
	this.LoadData = function(DataSource) {
		// Debug
		// document.location = DataSource;
		var Request = this.InitiateXmlHttpRequest();
		if (Request != null) {
			try {
				Request.onreadystatechange = this.CreateDataHandler(Request);
				Request.open("GET", DataSource, true);
				Request.send(null);
			} catch(oc) {
				alert(oc);
			}
		}
	}
}
function HandleFailure(Request) {
	alert("Failed: ("+Request.status+") "+Request.statusText);
}