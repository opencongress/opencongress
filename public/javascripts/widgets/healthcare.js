var fHeight = 418;
if (window.navigator.userAgent.indexOf("MSIE")) {
	fHeight += 7;
}
document.write('<iframe id="healthcare_panel" name="oc_healthcare_frame" width="348" height="' + fHeight + '" scrolling="no" frameborder="0" style="border: 0;" allowtransparency="true" hspace="0" vspace="0" marginheight="0" marginwidth="0" src="' + window.oc_host_url + 'resources/healthcare_panel?state=' + window.oc_state + '"></iframe>');
