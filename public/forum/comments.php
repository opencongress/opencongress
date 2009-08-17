<?php
/*
* Copyright 2003 Mark O'Sullivan
* This file is part of Vanilla.
* Vanilla is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
* Vanilla is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
* You should have received a copy of the GNU General Public License along with Vanilla; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
* The latest source code for Vanilla is available at www.lussumo.com
* Contact Mark O'Sullivan at mark [at] lussumo [dot] com
*
* Description: Display, add, and manipulate discussion comments
*/

include("appg/settings.php");
$Configuration['SELF_URL'] = 'comments.php';
include("appg/init_vanilla.php");

// 1. DEFINE VARIABLES AND PROPERTIES SPECIFIC TO THIS PAGE
$SessionPostBackKey = $Context->Session->GetVariable('SessionPostBackKey', 'string');

// Ensure the user is allowed to view this page
$Context->Session->Check($Context);

// Instantiate data managers to be used in this page
$DiscussionManager = $Context->ObjectFactory->NewContextObject($Context, "DiscussionManager");

// Create the comment grid
$DiscussionID = ForceIncomingInt("DiscussionID", 0);
$CommentGrid = $Context->ObjectFactory->CreateControl($Context, "CommentGrid", $DiscussionManager, $DiscussionID);

// Create the comment form
if ($CommentGrid->ShowForm) {
	$CommentForm = $Context->ObjectFactory->CreateControl($Context, 'DiscussionForm');
	$CommentForm->Discussion = &$CommentGrid->Discussion;
	$CommentFoot = $Context->ObjectFactory->CreateControl($Context, 'Filler', 'comments_foot.php');
}

// Define properties of the page controls that are specific to this page
$Head->BodyId = 'CommentsPage';
$Menu->CurrentTab = "discussions";
$Panel->CssClass = "CommentPanel";
$Panel->BodyCssClass = "Comments";
$Context->PageTitle = $CommentGrid->Discussion->Name;

// 2. BUILD PAGE CONTROLS

	// Add discussion options to the panel
	if ($Context->Session->UserID > 0) {
		$Options = $Context->GetDefinition("Options");
		$Panel->AddList($Options, 5);
		$BookmarkText = $Context->GetDefinition($CommentGrid->Discussion->Bookmarked ? "UnbookmarkThisDiscussion" : "BookmarkThisDiscussion");
		$Panel->AddListItem($Options,
			$BookmarkText,
			"./",
			"",
			"id=\"SetBookmark\" onclick=\"SetBookmark('".$Configuration['WEB_ROOT']."ajax/switch.php', ".$CommentGrid->Discussion->Bookmarked.", '".$CommentGrid->Discussion->DiscussionID."', '".$Context->GetDefinition("BookmarkText")."', '".$Context->GetDefinition("UnbookmarkThisDiscussion")."', '".$SessionPostBackKey."'); ".$Context->PassThruVars['SetBookmarkOnClick']."return false;\"");

		if ($Context->Session->User->Permission("PERMISSION_HIDE_DISCUSSIONS")) {
			$HideText = $Context->GetDefinition(($CommentGrid->Discussion->Active?"Hide":"Unhide")."ThisDiscussion");
			$Panel->AddListItem($Options,
				$HideText,
				"./",
				"",
				"id=\"HideDiscussion\" onclick=\"if (confirm('".$Context->GetDefinition($CommentGrid->Discussion->Active?"ConfirmHideDiscussion":"ConfirmUnhideDiscussion")."')) DiscussionSwitch('".$CommentGrid->Context->Configuration['WEB_ROOT']."ajax/switch.php', 'Active', '".$CommentGrid->Discussion->DiscussionID."', '".FlipBool($CommentGrid->Discussion->Active)."', 'HideDiscussion', '".$SessionPostBackKey."'); return false;\"");
		}
		if ($Context->Session->User->Permission("PERMISSION_CLOSE_DISCUSSIONS")) {		
			$CloseText = $Context->GetDefinition(($CommentGrid->Discussion->Closed?"ReOpen":"Close")."ThisDiscussion");
			$Panel->AddListItem($Options,
				$CloseText,
				"./",
				"",
				"id=\"CloseDiscussion\" onclick=\"if (confirm('".$Context->GetDefinition($CommentGrid->Discussion->Closed?"ConfirmReopenDiscussion":"ConfirmCloseDiscussion")."')) DiscussionSwitch('".$CommentGrid->Context->Configuration['WEB_ROOT']."ajax/switch.php', 'Closed', '".$CommentGrid->Discussion->DiscussionID."', '".FlipBool($CommentGrid->Discussion->Closed)."', 'CloseDiscussion', '".$SessionPostBackKey."'); return false;\"");
		}
		if ($Context->Session->User->Permission("PERMISSION_STICK_DISCUSSIONS")) {
			$StickyText = $Context->GetDefinition("MakeThisDiscussion".($CommentGrid->Discussion->Sticky?"Unsticky":"Sticky"));
			$Panel->AddListItem($Options,
				$StickyText,
				"./",
				"",
				"id=\"StickDiscussion\" onclick=\"if (confirm('".$Context->GetDefinition($CommentGrid->Discussion->Sticky?"ConfirmUnsticky":"ConfirmSticky")."')) DiscussionSwitch('".$CommentGrid->Context->Configuration['WEB_ROOT']."ajax/switch.php', 'Sticky', '".$CommentGrid->Discussion->DiscussionID."', '".FlipBool($CommentGrid->Discussion->Sticky)."', 'StickDiscussion', '".$SessionPostBackKey."'); return false;\"");
		}
		if ($Context->Session->User->Permission("PERMISSION_SINK_DISCUSSIONS")) {
			$SinkText = $Context->GetDefinition("MakeThisDiscussion".($CommentGrid->Discussion->Sink?"UnSink":"Sink"));
			$Panel->AddListItem($Options,
				$SinkText,
				"./",
				"",
				"id=\"SinkDiscussion\" onclick=\"if (confirm('".$Context->GetDefinition($CommentGrid->Discussion->Sink?"ConfirmUnSink":"ConfirmSink")."')) DiscussionSwitch('".$CommentGrid->Context->Configuration['WEB_ROOT']."ajax/switch.php', 'Sink', '".$CommentGrid->Discussion->DiscussionID."', '".FlipBool($CommentGrid->Discussion->Sink)."', 'SinkDiscussion', '".$SessionPostBackKey."'); return false;\"");
		}
	}
	
	// Create the comment footer
	$CommentFoot = $Context->ObjectFactory->CreateControl($Context, "CommentFoot");

// 3. ADD CONTROLS TO THE PAGE

	$Page->AddRenderControl($Head, $Configuration["CONTROL_POSITION_HEAD"]);
	$Page->AddRenderControl($Menu, $Configuration["CONTROL_POSITION_MENU"]);
	$Page->AddRenderControl($Panel, $Configuration["CONTROL_POSITION_PANEL"]);
	$Page->AddRenderControl($NoticeCollector, $Configuration['CONTROL_POSITION_NOTICES']);
	$Page->AddRenderControl($CommentGrid, $Configuration["CONTROL_POSITION_BODY_ITEM"]);
	if ($CommentGrid->ShowForm) {
		$Page->AddRenderControl($CommentForm, $Configuration["CONTROL_POSITION_BODY_ITEM"] + 10);
		$Page->AddRenderControl($CommentFoot, $Configuration["CONTROL_POSITION_BODY_ITEM"] + 11);
	}
	$Page->AddRenderControl($Foot, $Configuration["CONTROL_POSITION_FOOT"]);
	$Page->AddRenderControl($PageEnd, $Configuration["CONTROL_POSITION_PAGE_END"]);

// 4. FIRE PAGE EVENTS
	$Page->FireEvents();
?>