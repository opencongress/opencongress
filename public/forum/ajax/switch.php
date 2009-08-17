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
* Description: File used by Dynamic Data Management object to handle any type of boolean switch
*/

include('../appg/settings.php');
include('../appg/init_ajax.php');

$PostBackKey = ForceIncomingString('PostBackKey', '');
$ExtensionKey = ForceIncomingString('ExtensionKey', '');
if ($PostBackKey != '' && $PostBackKey == $Context->Session->GetVariable('SessionPostBackKey', 'string')) {
	$Type = ForceIncomingString('Type', '');
	$Switch = ForceIncomingBool('Switch', 0);
	$DiscussionID = ForceIncomingInt('DiscussionID', 0);
	$CommentID = ForceIncomingInt('CommentID', 0);
	
	// Don't create unnecessary objects
	if (in_array($Type, array('Active', 'Closed', 'Sticky', 'Sink'))) {
		$dm = $Context->ObjectFactory->NewContextObject($Context, 'DiscussionManager');
	} elseif ($Type == 'Comment') {
		$cm = $Context->ObjectFactory->NewContextObject($Context, 'CommentManager');
	} else {
		// This will allow the switch class to be used to add new custom user settings
		$um = $Context->ObjectFactory->NewContextObject($Context, 'UserManager');
	}
	// Handle the switches
	if ($Type == 'Bookmark' && $DiscussionID > 0) {
		if ($Context->Session->UserID == 0) die();	
		if ($Switch) {
			$um->AddBookmark($Context->Session->UserID, $DiscussionID);
		} else {
			$um->RemoveBookmark($Context->Session->UserID, $DiscussionID);
		}
	} elseif ($DiscussionID > 0 && (
		($Type == 'Active' && $Context->Session->User->Permission('PERMISSION_HIDE_DISCUSSIONS'))
		|| ($Type == 'Closed' && $Context->Session->User->Permission('PERMISSION_CLOSE_DISCUSSIONS'))
		|| ($Type == 'Sticky' && $Context->Session->User->Permission('PERMISSION_STICK_DISCUSSIONS'))
		|| ($Type == 'Sink' && $Context->Session->User->Permission('PERMISSION_SINK_DISCUSSIONS'))
		)) {
		$dm->SwitchDiscussionProperty($DiscussionID, $Type, $Switch);
	} elseif ($Type == 'Comment' && $CommentID > 0 && $DiscussionID > 0 && $Context->Session->User->Permission('PERMISSION_HIDE_COMMENTS')) {
		$cm->SwitchCommentProperty($CommentID, $DiscussionID, $Switch);
	} elseif ($Type == 'SendNewApplicantNotifications') {
		$um->SwitchUserProperty($Context->Session->UserID, $Type, $Switch);
	} elseif ($Type != '') {
		$um->SwitchUserPreference($Type, $Switch);
	}
	
	echo 'Complete';
} else {
	echo $Context->GetDefinition('ErrPostBackKeyInvalid');
}
$Context->Unload();
?>
