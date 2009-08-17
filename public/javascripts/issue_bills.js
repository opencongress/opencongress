var fHeight = 340;
if (window.navigator.userAgent.indexOf("MSIE")) {
	fHeight += 7;
}
document.write('<iframe name="oc_issue_bills_frame" width="176" height="' + fHeight + '" scrolling="no" frameborder="0" style="border-style: solid; border-width: 1px; border-color: #' + window.bordercolor + '" allowtransparency="true" hspace="0" vspace="0" marginheight="0" marginwidth="0" src="' + window.oc_host_url + 'resources/issue_bills_panel?bg_color=' + window.oc_bgcolor + '&textcolor=' + window.oc_textcolor + '&issue_id=' + window.oc_issue_id + '&item_type='+ window.oc_item_type + '"></iframe>');

