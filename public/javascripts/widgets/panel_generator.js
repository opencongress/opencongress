function onSearch() {
  Element.show('search_spinner'); // spinner
}

function onSearchComplete() {
  Element.hide('search_spinner');
}

function setBillStatusBillId(billId) {
  document.getElementById('panel_bill_id').value = billId;
  updateBillStatusFields(); 
}

function setHealthCareStateAbbrev(state_abbrev) {
  document.getElementById('panel_state_abbrev').value = state_abbrev;
  updateHealthCareFields(); 
}

function setHealthCarePath(path) {
  document.getElementById('panel_path').value = path;
  updateHealthCareFields();
}

function setPanelPath(path, panelType) {
  document.getElementById('panel_path').value = path;
  updateFields(null, panelType);
}

function setIssueBillsIssueId(issueId) {
  document.getElementById('panel_issue_id').value = issueId;
  updateIssueBillsFields(); 
}

function updateSyndicatorFields(changedField) {
  updateFields(changedField, "syndicator");
}

function updateBillStatusFields(changedField) {  
  updateFields(changedField, "bill_status");
}

function updateHealthCareFields(changedField) {  
  updateFields(changedField, "healthcare");
}

function updatePanelFields(panelType) {
  updateFields(null, panelType);
}

function updateIssueBillsFields(changedField) {  
  updateFields(changedField, "issue_bills");
}

function updateMypnFields(changedField) {  
  updateFields(changedField, "mypn");
}

var passBills = '';
var dontPassBills = '';
function updateWatchingFields(changedField) {  
  updateFields(changedField, "watching");
}

function addWatchingBillId(billId, pass) {
  if (pass) {
    if (passBills == '')
      passBills += billId;
    else 
      passBills += "," + billId;
  } else {
    if (dontPassBills == '')
      dontPassBills += billId;
    else 
      dontPassBills += "," + billId;
  }

  updateFields(null, "watching")
}

function clearWatching() {
  passBills = ''
  dontPassBills = ''
  
  updateFields(null, "watching")
}

function generatorRefresh()
{
  updateFields(null, "bill_status", true);
}

function updateFields(changedField, panelType, generatorRefresh) {
  var previewQuery;
  var theIFrame;
  var frameHeight;
  var userCode;
  var scriptName;

  if (changedField != null) {
    document.getElementById(changedField).value = document.getElementById(changedField + "_select").value    
  }

  var hostname = document.getElementById('panel_hostname').value;

  var bg_color = document.getElementById('panel_bgcolor') ?
                 document.getElementById('panel_bgcolor').value : 'ffffff';
  var textcolor = document.getElementById('panel_textcolor') ?
                  document.getElementById('panel_textcolor').value : '333333';
  var bordercolor = document.getElementById('panel_bordercolor') ?
                    document.getElementById('panel_bordercolor').value : '999999';

  if (panelType == 'syndicator')
  {
    var num_items = document.getElementById('panel_number').value ?
                    document.getElementById('panel_number').value : '3';
    var item_type = document.getElementById('panel_item_type').value ?
                    document.getElementById('panel_item_type').value : 'viewed-bill';
    frameHeight = (document.getElementById('panel_number').value * 53) + 92;
  }
  else if (panelType == 'mypn') {
    var num_items = document.getElementById('panel_number').value ?
                    document.getElementById('panel_number').value : '3';
    var user = document.getElementById('panel_user').value
    frameHeight = (document.getElementById('panel_number').value * 53) + 92;
  }
  else if (panelType == 'issue_bills') {
    var issue_id = document.getElementById('panel_issue_id').value ?
                   document.getElementById('panel_issue_id').value : '4166';
    var item_type = document.getElementById('panel_item_type').value ?
                    document.getElementById('panel_item_type').value : 'new-bill';
    frameHeight = 338;
  }
  else if (panelType == 'healthcare') {
      var state_abbrev = document.getElementById('panel_state_abbrev') ?
                     document.getElementById('panel_state_abbrev').value : ''    ;
     var path = document.getElementById('panel_path') ?
                    document.getElementById('panel_path').value : 'healthcare_panel';
    frameHeight = 630;
  }
  else if (panelType == 'climate_change' || panelType == 'financial_reform') {
     var path = document.getElementById('panel_path') ?
                    document.getElementById('panel_path').value : panelType + '_panel';
    frameHeight = 630;
  }
  else if (panelType == 'bill_status')
  {
    var bill_id = document.getElementById('panel_bill_id').value ?
                  document.getElementById('panel_bill_id').value : '111-h1';
  } else if (panelType == 'watching') {
    num_pass_bills = (passBills == '' ? 0 : passBills.split(",").length);
    num_dont_pass_bills = (dontPassBills == '' ? 0 : dontPassBills.split(",").length);
    
    frameHeight = 52;
    frameHeight += (num_pass_bills + num_dont_pass_bills) * 53;
    if (num_pass_bills > 0) {
      frameHeight += 18;
    }
    if (num_dont_pass_bills > 0) {
      frameHeight += 18;
    }
  }

  previewQuery = "bg_color=" + bg_color +
                 "&textcolor=" + textcolor;

  if (panelType == 'syndicator')
  {       
    previewQuery += "&item_type=" + item_type +
                    "&num_items=" + num_items;
  } else if (panelType == 'mypn') {
    previewQuery += "&num_items=" + num_items +
                    "&user=" + user;
  } else if (panelType == 'issue_bills') {
    previewQuery += "&item_type=" + item_type +
                    "&issue_id=" + issue_id;
  } else if (panelType == 'healthcare') {
    previewQuery = "state=" + state_abbrev;
  } else if (panelType == 'watching') {
    previewQuery += "&pass_bills=" + passBills +
                    "&dont_pass_bills=" + dontPassBills;    
  } else { /* in what case is this used? */
    previewQuery += "&bill_id=" + bill_id;
  }

  theIFrame = document.getElementById(panelType + '_panel');

  oldUrl = theIFrame.src;
  theIFrame.src = document.getElementById('panel_path').value + "?" + previewQuery;

  if (panelType == 'bill_status')
  { 
    if (!generatorRefresh)
    {
      //if (theIFrame.addEventListener){
      //  theIFrame.addEventListener( "load", generatorRefresh, false); 
      //} else if (theIFrame.attachEvent){
      //  theIFrame.attachEvent( "onload", generatorRefresh);
      //}
      theIFrame.onLoad = setTimeout("parent.updateFields(null, 'bill_status', true)", 2000);
    }

    if (theIFrame.contentDocument && theIFrame.contentDocument.body.offsetHeight) //ns6 syntax
    {
      frameHeight = theIFrame.contentDocument.body.offsetHeight + 5; 
    }
    else if (theIFrame.Document && theIFrame.Document.body.scrollHeight) //ie5+ syntax
    {
      frameHeight = theIFrame.Document.body.scrollHeight;
    }
  }

  if (window.navigator.userAgent.indexOf("MSIE")) {
    theIFrame.height = frameHeight + 7;    
  } else {
    theIFrame.height = frameHeight;
  }
  theIFrame.style.borderColor = "#" + bordercolor;

  userCode = "<script type=\"text/javascript\">\n" +
            "oc_host_url = \"#HOSTNAME\";\n"
  if (panelType == 'bill_status')
  {
    userCode += "oc_bill_id = \"#BILL_ID\";\n" +
                 "oc_frame_height = \"#FRAME_HEIGHT\";\n" +
                 "oc_bgcolor = \"#BGCOLOR\";\n" + 
                 "oc_textcolor = \"#TEXTCOLOR\";\n" + 
                 "oc_bordercolor = \"#BORDERCOLOR\";\n";
    scriptName = "#HOSTNAMEjavascripts/widgets/bill_status.js";
  }
  else if (panelType == 'issue_bills') {
    userCode += "oc_issue_id = \"#ISSUE_ID\";\n" +
                 "oc_item_type = \"#ITEMTYPE\";\n" + 
                 "oc_bgcolor = \"#BGCOLOR\";\n" + 
                 "oc_textcolor = \"#TEXTCOLOR\";\n" + 
                 "oc_bordercolor = \"#BORDERCOLOR\";\n";
    scriptName = "#HOSTNAMEjavascripts/widgets/issue_bills.js";      
  }
  else if (panelType == 'watching')
  {
    userCode += "oc_pass_bills = \"#PASSBILLS\";\n" +
                 "oc_dont_pass_bills = \"#DONTPASSBILLS\";\n" +
                 "oc_bgcolor = \"#BGCOLOR\";\n" + 
                 "oc_textcolor = \"#TEXTCOLOR\";\n" + 
                 "oc_bordercolor = \"#BORDERCOLOR\";\n";
    scriptName = "#HOSTNAMEjavascripts/widgets/watching.js";
  }
  else if (panelType == 'mypn')
  {
    userCode += "oc_mypn_user = \"#USER\";\n" +
                 "oc_mypn_num_items = \"#NUM_ITEMS\";\n" +
                 "oc_mypn_bgcolor = \"#BGCOLOR\";\n" + 
                 "oc_mypn_textcolor = \"#TEXTCOLOR\";\n" + 
                 "oc_mypn_bordercolor = \"#BORDERCOLOR\";\n";
    scriptName = "#HOSTNAMEjavascripts/widgets/mypn_widget.js";
  }
  else if (panelType == 'healthcare')
  {
    if (state_abbrev) {
        userCode += "oc_state = \"#STATE_ABBREV\";\n";
    }
    userCode += "oc_path = \"#PATH\";\n";
    scriptName = "#HOSTNAMEjavascripts/widgets/healthcare.js";
  }
  else if (panelType == 'climate_change' || panelType == 'financial_reform')
  {
    userCode += "oc_path = \"#PATH\";\n";
    scriptName = "#HOSTNAMEjavascripts/widgets/" + panelType + ".js";
  }
  else
  {
    userCode += "oc_num_items = \"#NUM_ITEMS\";\n" +
                 "oc_item_type = \"#ITEMTYPE\";\n" + 
                 "oc_bgcolor = \"#BGCOLOR\";\n" + 
                 "oc_textcolor = \"#TEXTCOLOR\";\n" + 
                 "oc_bordercolor = \"#BORDERCOLOR\";\n";
    scriptName = "#HOSTNAMEjavascripts/widgets/syndicator.js";
  }
  userCode += "</script>\n" + 
               "<script type=\"text/javascript\" " +
               "src=\"" + scriptName + "\"></script>";

  userCode = userCode.replace(/#HOSTNAME/g, hostname);
  if (panelType == 'syndicator')
  {
    userCode = userCode.replace(/#ITEMTYPE/, item_type);
    userCode = userCode.replace(/#NUM_ITEMS/, num_items);
  } else if (panelType == 'mypn') {
    userCode = userCode.replace(/#NUM_ITEMS/, num_items);
    userCode = userCode.replace(/#USER/, user);
  } else if (panelType == 'issue_bills') {
    userCode = userCode.replace(/#ITEMTYPE/, item_type);
    userCode = userCode.replace(/#ISSUE_ID/, issue_id); 
  } else if (panelType == 'healthcare' || panelType == 'climate_change' || panelType == 'financial_reform') {
      userCode = userCode.replace(/#STATE_ABBREV/, state_abbrev);   
      userCode = userCode.replace(/#PATH/, path);
  } else if (panelType == 'watching') {
    userCode = userCode.replace(/#PASSBILLS/, passBills);
    userCode = userCode.replace(/#DONTPASSBILLS/, dontPassBills);
  } else {
    userCode = userCode.replace(/#BILL_ID/, bill_id);
    userCode = userCode.replace(/#FRAME_HEIGHT/, frameHeight);
  }
  userCode = userCode.replace(/#BGCOLOR/, bg_color);
  userCode = userCode.replace(/#TEXTCOLOR/, textcolor);
  userCode = userCode.replace(/#BORDERCOLOR/, bordercolor);

  document.getElementById('panel_code').value = userCode;
}


