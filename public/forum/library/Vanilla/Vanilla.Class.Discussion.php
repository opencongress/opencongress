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
* Description: Discussion class
*/

class Discussion extends Delegation {
	var $DiscussionID;
	var $FirstCommentID;
	var $CategoryID;
	var $Category;
	var $AuthUserID;
	var $AuthUsername;		// Display purposes only - The user's username
	var $LastUserID;		// The user that last added comments to the Discussion
	var $LastUsername;		// Display purposes only - The user's username
	var $Active;			// Boolean value indicating if the Discussion is visible to non-administrators
	var $Closed;			// Boolean value indicating if the Discussion will allow any further Comments to be added
	var $Sticky;			// Boolean value indicating if the Discussion should appear at the top of the list
	var $Bookmarked;		// Boolean value indicating if the Discussion has been bookmared by the current user
   var $Sink;				// Boolean value indicating if the discussion should sink (ie. allow comments to be added, but not stay at the top of the list).
	var $Name;
	var $DateCreated;
	var $DateLastActive;
	var $CountComments;		// Number of Comments currently in this Discussion
   var $CountReplies;		// Number of replies currently in this Discussion (one less than the Comment count)
	var $Comment;				// Only used when creating/editing a discussion
   var $LastViewed;
	var $LastViewCountComments;
	var $NewComments;
	var $Status;
	var $LastPage;				// The last page of the discussion
  	// Used to prevent double posts and "back button" posts
   var $UserDiscussionCount;
	var $WhisperUserID;	// If this discussion was whispered to a particular user
	var $WhisperUsername;		// Display purposes only - The user's username
	var $CountWhispersTo;
	var $CountWhispersFrom;

	
	// Clears all properties
	function Clear() {
		$this->DiscussionID = 0;
		$this->FirstCommentID = 0;
		$this->CategoryID = 0;
		$this->Category = '';
		$this->AuthUserID = 0;
		$this->AuthUsername = '';
		$this->LastUserID = 0;
		$this->LastUsername = '';
		$this->Active = 0;
		$this->Closed = 0;
		$this->Sticky = 0;
		$this->Bookmarked = 0;
		$this->Sink = 0;
		$this->Name = '';
		$this->DateCreated = '';
		$this->DateLastActive = '';
		$this->CountComments = 0;
		$this->CountReplies = 0;
		$this->Comment = 0;
		$this->LastViewed = '';
		$this->LastViewCountComments = 0;
		$this->NewComments = 0;
		$this->Status = 'Unread';
		$this->LastPage = 1;
		$this->UserDiscussionCount = 0;
		$this->WhisperUserID = 0;
		$this->WhisperUsername = '';
		$this->CountWhispersTo = 0;
		$this->CountWhispersFrom = 0;
	}
	
	function Discussion(&$Context) {
		$this->Name = 'Discussion';
		$this->Delegation($Context);
		$this->Clear();
	}

	// Retrieve properties from current DataRowSet
	function GetPropertiesFromDataSet($DataSet, $Configuration) {
		$this->DiscussionID = @$DataSet['DiscussionID'];
		$this->FirstCommentID = @$DataSet['FirstCommentID'];
		$this->CategoryID = @$DataSet['CategoryID'];
		$this->Category = @$DataSet['Category'];
		$this->AuthUserID = @$DataSet['AuthUserID'];
		$this->AuthUsername = @$DataSet['AuthUsername'];
		$this->LastUserID = @$DataSet['LastUserID'];
		$this->LastUsername = @$DataSet['LastUsername'];
		$this->Active = @$DataSet['Active'];
		$this->Closed = @$DataSet['Closed'];
		$this->Sticky = @$DataSet['Sticky'];
		$this->Bookmarked = @$DataSet['Bookmarked'];
		$this->Sink = @$DataSet['Sink'];
		$this->Name = @$DataSet['Name'];
		$this->DateCreated = UnixTimestamp(@$DataSet['DateCreated']);
		$this->DateLastActive = UnixTimestamp(@$DataSet['DateLastActive']);
		$this->CountComments = @$DataSet['CountComments'];
		
		if ($Configuration['ENABLE_WHISPERS']) {		
         $this->WhisperUserID = @$DataSet['WhisperUserID'];
         $this->WhisperUsername = @$DataSet['WhisperUsername'];
         
         $WhisperFromDateLastActive = UnixTimestamp(@$DataSet['WhisperFromDateLastActive']);
         $WhisperFromLastUserID = @$DataSet['WhisperFromLastUserID'];
         $WhisperFromLastFullName = @$DataSet['WhisperFromLastFullName'];
         $WhisperFromLastUsername = @$DataSet['WhisperFromLastUsername'];
         $this->CountWhispersFrom = @$DataSet['CountWhispersFrom'];
         
         $WhisperToDateLastActive = UnixTimestamp(@$DataSet['WhisperToDateLastActive']);
         $WhisperToLastUserID = @$DataSet['WhisperToLastUserID'];
         $WhisperToLastFullName = @$DataSet['WhisperToLastFullName'];
         $WhisperToLastUsername = @$DataSet['WhisperToLastUsername'];
         $this->CountWhispersTo = @$DataSet['CountWhispersTo'];
         
         $this->CountComments += $this->CountWhispersFrom;
         $this->CountComments += $this->CountWhispersTo;
         $this->CountReplies = $this->CountComments - 1;
         if ($this->CountReplies < 0) $this->CountReplies = 0;
         
         if ($WhisperFromDateLastActive != '') {
            if ($this->DateLastActive < $WhisperFromDateLastActive) {
               $this->DateLastActive = $WhisperFromDateLastActive;
               $this->LastUserID = $WhisperFromLastUserID;
               $this->LastFullName = $WhisperFromLastFullName;
               $this->LastUsername = $WhisperFromLastUsername;
            }
         }
         if ($WhisperToDateLastActive != '') {
            if ($this->DateLastActive < $WhisperToDateLastActive) {
               $this->DateLastActive = $WhisperToDateLastActive;
               $this->LastUserID = $WhisperToLastUserID;
               $this->LastFullName = $WhisperToLastFullName;
               $this->LastUsername = $WhisperToLastUsername;
            }
         }
		}

		$this->CountReplies = $this->CountComments - 1;
		if ($this->CountReplies < 0) $this->CountReplies = 0;
		$this->LastViewed = UnixTimestamp(@$DataSet['LastViewed']);
		$this->LastViewCountComments = @$DataSet['LastViewCountComments'];
		if ($this->LastViewed != '') {
			$this->NewComments = $this->CountComments - $this->LastViewCountComments;
			if ($this->NewComments < 0) $this->NewComments = 0;
		} else {
			$this->NewComments = $this->CountComments;
		}
		$this->Status = $this->GetStatus();
		
		// Define the last page
      $TmpCount = ($this->CountComments / $Configuration['COMMENTS_PER_PAGE']);
		$RoundedCount = intval($TmpCount);
		if ($TmpCount > 1) {
			if ($TmpCount > $RoundedCount) {
				$this->LastPage = $RoundedCount + 1;
			} else {
				$this->LastPage = $RoundedCount;
			}
		} else {
			$this->LastPage = 1;
		}
		
		$this->DelegateParameters['DataSet'] = &$DataSet;
		$this->CallDelegate('PostGetPropertiesFromDataSet');
	}	

	// Retrieve a properties from incoming form variables
	function GetPropertiesFromForm(&$Context) {
		$this->DiscussionID = ForceIncomingInt('DiscussionID', 0);
		$this->CategoryID = ForceIncomingInt('CategoryID', 0);
		$this->Name = ForceIncomingString('Name', '');
		$this->UserDiscussionCount = ForceIncomingInt('UserDiscussionCount', 0);
		
		$this->WhisperUsername = ForceIncomingString('WhisperUsername', '');
		$this->WhisperUsername = Strip_Slashes($this->WhisperUsername);

		// Load the comment
      $this->Comment = $Context->ObjectFactory->NewContextObject($Context, 'Comment');
		$this->Comment->GetPropertiesFromForm();
	}
	
	function GetStatus() {
		$sReturn = '';
		if (!$this->Active) $sReturn = ' Hidden';
      if ($this->WhisperUserID > 0) $sReturn .= ' Whispered';
		if ($this->Closed) $sReturn .= ' Closed';
		if ($this->Sticky) $sReturn .= ' Sticky';
		if ($this->Bookmarked) $sReturn .= ' Bookmarked';
		if ($this->Sink) $sReturn .= ' Sink';
		if ($this->LastViewed != '') {
			$sReturn .= ' Read';
		} else {
			$sReturn .= ' Unread';
		}
		if ($this->NewComments > 0) {
			$sReturn .= ' NewComments';
		} else {
			$sReturn .= ' NoNewComments';
		}
		$this->DelegateParameters['StatusString'] = &$sReturn;
		$this->CallDelegate('GetStatus');
		return $sReturn;
	}
	
	function FormatPropertiesForDisplay() {
      $this->WhisperUsername = FormatStringForDisplay($this->WhisperUsername);
		$this->AuthUsername = FormatStringForDisplay($this->AuthUsername);
		$this->LastUsername = FormatStringForDisplay($this->LastUsername);
		$this->Category = FormatStringForDisplay($this->Category);
		$this->Name = FormatStringForDisplay($this->Name, 0);
		$this->CallDelegate('PostFormatPropertiesForDisplay');
	}
}
?>