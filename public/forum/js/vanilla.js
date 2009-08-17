/*
* Copyright 2003 - 2006 Mark O'Sullivan
* This file is part of Vanilla.
* Vanilla is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
* Vanilla is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
* You should have received a copy of the GNU General Public License along with Vanilla; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
* The latest source code for Vanilla is available at www.lussumo.com
* Contact Mark O'Sullivan at mark [at] lussumo [dot] com
* 
* Description: Utility functions specific to Vanilla
*/
  
// Add a new custom name/value pair input to the account form
function AddLabelValuePair() {
	var Counter = document.getElementById('LabelValuePairCount');
	var Container = document.getElementById('CustomInfo');
	if (Counter && Container) {
		Counter.value++;

		var Label = document.createElement("li");
		var LabelInput = document.createElement("input");
		LabelInput.type = "text";
		LabelInput.name = "Label"+Counter.value;
		LabelInput.maxLength = "20";
		LabelInput.className = "LVLabelInput";
		
		// Create the value container		
		var Value = document.createElement("li");
		var ValueInput = document.createElement("input");
		ValueInput.type = "text";
		ValueInput.name = "Value"+Counter.value;
		ValueInput.maxLength = "200";
		ValueInput.className = "LVValueInput";
		
		// Add the items to the page
		Label.appendChild(LabelInput);
		Value.appendChild(ValueInput);
		Container.appendChild(Label);
		Container.appendChild(Value);
	}
}

function DiscussionSwitch(AjaxUrl, SwitchType, DiscussionID, SwitchValue, SenderID, PostBackKey) {
	var Sender = document.getElementById(SenderID);
	if (Sender) Sender.className = 'Progress';
	var Parameters = "Type="+SwitchType+"&DiscussionID="+DiscussionID+"&Switch="+SwitchValue+"&PostBackKey="+PostBackKey;
	var dm = new DataManager();
	dm.RequestCompleteEvent = RefreshPageWhenAjaxComplete;
	dm.RequestFailedEvent = HandleFailure;
	dm.LoadData(AjaxUrl+"?"+Parameters);
}

function HideComment(AjaxUrl, Switch, DiscussionID, CommentID, ShowText, HideText, SenderID, PostBackKey) {
	var ConfirmText = (Switch==1?HideText:ShowText);
	if (confirm(ConfirmText)) {
		var Sender = document.getElementById(SenderID);
		if (Sender) {
			Sender.innerHTML = '&nbsp;';
			Sender.className = 'HideProgress';
		}
		var dm = new DataManager();
		dm.RequestCompleteEvent = RefreshPageWhenAjaxComplete;
		dm.RequestFailedEvent = HandleFailure;
		dm.LoadData(AjaxUrl+"?Type=Comment&Switch="+Switch+"&DiscussionID="+DiscussionID+"&CommentID="+CommentID+"&PostBackKey="+PostBackKey);
	}
}

// Apply or remove a bookmark
function SetBookmark(AjaxUrl, CurrentSwitchVal, Identifier, BookmarkText, UnbookmarkText, PostBackKey) {
	var Sender = document.getElementById('SetBookmark');
	if (Sender) {
		Sender.className = 'Progress';
		var Switch = Sender.name == '' ? CurrentSwitchVal : Sender.name;
		var FlipSwitch = Switch == 1 ? 0 : 1;
		Sender.name = FlipSwitch;
		var dm = new DataManager();
		dm.Param = (FlipSwitch == 0 ? BookmarkText : UnbookmarkText);
		dm.RequestCompleteEvent = BookmarkComplete;
		dm.RequestFailedEvent = BookmarkFailed;
		dm.LoadData(AjaxUrl+"?Type=Bookmark&Switch="+FlipSwitch+"&DiscussionID="+Identifier+"&PostBackKey="+PostBackKey);
	}
}
function ApplyBookmark(Element, ClassName, Text) {
	var Button = document.getElementById(Element);
	if (Button) {
		Button.className = ClassName;
		Button.innerHTML = Text;
	}	
}
function BookmarkComplete(Request) {
	setTimeout("ApplyBookmark('SetBookmark', 'Complete', '"+this.Param+"');", 400);
}
function BookmarkFailed(Request) {
	var Button = document.getElementById('SetBookmark');
	if (Button) {
		Button.className = 'Complete';
		alert("Failed: ("+Request.status+") "+Request.statusText);
	}
}
function ShowAdvancedSearch() {
	var SearchSimple = document.getElementById("SearchSimpleFields");
	var SearchDiscussions = document.getElementById("SearchDiscussionFields");
	var SearchComments = document.getElementById("SearchCommentFields");
	var SearchUsers = document.getElementById("SearchUserFields");
	
	if (SearchSimple && SearchDiscussions && SearchComments && SearchUsers ) {
		SearchSimple.style.display = "none";
		SearchDiscussions.style.display = "block";
		SearchComments.style.display = "block";
		SearchUsers.style.display = "block";
	}
}
function ShowSimpleSearch() {
	var SearchSimple = document.getElementById("SearchSimpleFields");
	var SearchDiscussions = document.getElementById("SearchDiscussionFields");
	var SearchComments = document.getElementById("SearchCommentFields");
	var SearchUsers = document.getElementById("SearchUserFields");
	
	if (SearchSimple && SearchDiscussions && SearchComments && SearchUsers ) {
		SearchSimple.style.display = "block";
		SearchDiscussions.style.display = "none";
		SearchComments.style.display = "none";
		SearchUsers.style.display = "none";
	}
}

function ToggleCategoryBlock(AjaxUrl, CategoryID, Block, SenderID, PostBackKey) {
	var Sender = document.getElementById(SenderID);
	if (Sender) {
		Sender.innerHTML = '&nbsp;';
		Sender.className = 'HideProgress';
	}
	var Parameters = "BlockCategoryID="+CategoryID+"&Block="+Block+'&PostBackKey='+PostBackKey;
   var dm = new DataManager();
	dm.RequestCompleteEvent = RefreshPageWhenAjaxComplete;
	dm.RequestFailedEvent = HandleFailure;
	dm.LoadData(AjaxUrl+"?"+Parameters);
}

function ToggleCommentBox(AjaxUrl, SmallText, BigText, PostBackKey) {
   SwitchElementClass('CommentBox', 'CommentBoxController', 'SmallCommentBox', 'LargeCommentBox', BigText, SmallText);
	var SwitchVal = 0;
	var CommentBox = document.getElementById("CommentBox");
	if (CommentBox) {
		if (CommentBox.className == "LargeCommentBox") SwitchVal = 1;
		
		var Parameters = "Type=ShowLargeCommentBox&Switch="+SwitchVal+"&PostBackKey="+PostBackKey;
		var dm = new DataManager();
		dm.RequestCompleteEvent = ToggleCommentBoxComplete;
		dm.RequestFailedEvent = HandleFailure;
		dm.LoadData(AjaxUrl+"?"+Parameters);		
	}
}
function ToggleCommentBoxComplete(Request) {
	// Don't do anything.
}

function WhisperBack(DiscussionID, WhisperTo, BaseUrl) {
	var frm = document.getElementById("frmPostComment");
	if (!frm) {
		document.location = BaseUrl + "post.php?PostBackAction=Reply&DiscussionID="+DiscussionID+"&WhisperUsername="+escape(WhisperTo);
	} else {
		frm.WhisperUsername.value = WhisperTo;
		frm.Body.focus();
	}
}