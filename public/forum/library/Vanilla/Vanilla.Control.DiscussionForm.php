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
* Description: The DiscussionForm control is used for adding and editing discussions and comments in Vanilla.
*/

class DiscussionForm extends PostBackControl {
	var $FatalError;		// If a fatal error occurs, only the warning messages should be displayed
	var $EditDiscussionID;
   var $Discussion;
	var $DiscussionFormattedForDisplay;
	var $DiscussionID;
	var $Comment;
	var $CommentID;
	var $Form;
	var $Title;				// The title of the form
   var $CommentFormAttributes; // Attributes added to the comment form's textarea input
   var $DiscussionFormAttributes; // Attributes added to the discussion form's textarea input
	
	function DiscussionForm(&$Context) {
		$this->Name = 'DiscussionForm';
		$this->CommentFormAttributes = '';
		$this->DiscussionFormAttributes = '';
		$this->Constructor($Context);
		$this->FatalError = 0;
		$this->EditDiscussionID = 0;
		$this->CommentID = ForceIncomingInt('CommentID', 0);
		$this->DiscussionID = ForceIncomingInt('DiscussionID', 0);
		$this->DiscussionFormattedForDisplay = 0;
		$this->ValidActions = array('SaveDiscussion', 'SaveComment', 'Reply');

		$this->CallDelegate('PreLoadData');
		
		// Check permissions and make sure that the user can add comments/discussions
      // Make sure user can post
		if ($this->DiscussionID == 0 && $this->Context->Session->UserID == 0) {
			$this->Context->WarningCollector->Add($this->Context->GetDefinition('NoDiscussionsNotSignedIn'));
			$this->FatalError = 1;
		}

		$this->Comment = $this->Context->ObjectFactory->NewContextObject($this->Context, 'Comment');
		$this->Discussion = $this->Context->ObjectFactory->NewContextObject($this->Context, 'Discussion');
		
		$cm = $this->Context->ObjectFactory->NewContextObject($this->Context, 'CommentManager');
		$dm = $this->Context->ObjectFactory->NewContextObject($this->Context, 'DiscussionManager');
		$this->DelegateParameters['CommentManager'] = &$cm;
		$this->DelegateParameters['DiscussionManager'] = &$dm;
		// If editing a comment, define it and validate the user's permissions
		if ($this->CommentID > 0) {
			$this->Comment = $cm->GetCommentById($this->CommentID, $this->Context->Session->UserID);
			if (!$this->Comment) {
				$this->FatalError = 1;
			} else {
				$this->DiscussionID = $this->Comment->DiscussionID;
				$this->Discussion = $dm->GetDiscussionById($this->Comment->DiscussionID);
				if (!$this->Discussion) {
					$this->FatalError = 1;
				} else {
					// if editing a discussion
					if (($this->Context->Session->UserID == $this->Discussion->AuthUserID || $this->Context->Session->User->Permission('PERMISSION_EDIT_DISCUSSIONS')) && $this->Discussion->FirstCommentID == $this->CommentID) {
						$this->EditDiscussionID = $this->Discussion->DiscussionID;
						$this->Discussion->Comment = $this->Comment;
					}
					// Set the page title
               $this->DiscussionFormattedForDisplay = 1;
					$this->Discussion->FormatPropertiesForDisplay();
					$this->Context->PageTitle = $this->Discussion->Name;
				}
			}
			// Ensure that this user has sufficient priviledges to edit the comment
			if ($this->Comment
				&& $this->Discussion
				&& !$this->Context->Session->User->Permission('PERMISSION_EDIT_COMMENTS')
				&& $this->Context->Session->UserID != $this->Comment->AuthUserID
				&& !($this->Discussion->FirstCommentID == $this->CommentID && $this->Context->Session->User->Permission('PERMISSION_EDIT_DISCUSSIONS'))) {
					
				$this->Context->WarningCollector->Add($this->Context->GetDefinition('ErrPermissionCommentEdit'));
				$this->FatalError = 1;
			}
		}

		$this->CallDelegate('PostLoadData');
		
		// If saving a discussion
		if ($this->PostBackAction == 'SaveDiscussion') {
			$FirstCommentID = $this->Discussion->FirstCommentID;
			$AuthUserID = $this->Discussion->AuthUserID;
			$this->Discussion->Clear();
			$this->Discussion->GetPropertiesFromForm($this->Context);
			$this->Discussion->FirstCommentID = $FirstCommentID;
			$this->Discussion->AuthUserID = $AuthUserID;

			// If we are editing a discussion, the following line
			// will make sure we save the proper discussion topic & message
			$this->Discussion->DiscussionID = $this->EditDiscussionID;
			
			if ($this->IsValidFormPostBack()) {
				$this->DelegateParameters['SaveDiscussion'] = &$this->Discussion;
				$this->CallDelegate('PreSaveDiscussion');
	
				$ResultDiscussion = $dm->SaveDiscussion($this->Discussion);
				
				$this->DelegateParameters['ResultDiscussion'] = &$ResultDiscussion;
				$this->CallDelegate('PostSaveDiscussion');
			
				if ($ResultDiscussion) {
					// Saved successfully, so send back to the discussion
					$Suffix = CleanupString($this->Discussion->Name).'/';
					header('location:'.GetUrl($this->Context->Configuration, 'comments.php', '', 'DiscussionID', $ResultDiscussion->DiscussionID, '', '', $Suffix));
					die();
				}
			}
		// If saving a comment
		} elseif ($this->PostBackAction == 'SaveComment') {
			$this->Comment->Clear();
			$this->Comment->GetPropertiesFromForm();
			$this->Comment->DiscussionID = $this->DiscussionID;
			$this->Discussion = $dm->GetDiscussionById($this->Comment->DiscussionID);
			
			if ($this->IsValidFormPostBack()) {
				// Make sure to prevent saving comments if the discussion is closed and
				// the user doesn't have permission to manage closed discussions
				if ($this->Discussion->Closed && !$this->Context->Session->User->Permission('PERMISSION_CLOSE_DISCUSSIONS')) {
					$ResultComment = false;
					$this->Context->WarningCollector->Add($this->Context->GetDefinition('ErrPermissionInsufficient'));
				} else {
					$this->DelegateParameters['SaveComment'] = &$this->Comment;
					$this->CallDelegate('PreSaveComment');
					
					$ResultComment = $cm->SaveComment($this->Comment);
				}
				
				$this->DelegateParameters['ResultComment'] = &$ResultComment;
				$this->CallDelegate('PostSaveComment');
				
				if ($ResultComment) {
					// Reload the discussion so the "lastpage" property is recalculated with the new comment in the math.
					$this->Discussion = $dm->GetDiscussionById($this->Comment->DiscussionID);
					// Saved successfully, so send back to the discussion
					// print_r($this->Discussion);
					$Suffix = CleanupString($this->Discussion->Name).'/';
					$Url = GetUrl($this->Context->Configuration, 'comments.php', '', 'DiscussionID', $ResultComment->DiscussionID, $this->Discussion->LastPage, ($ResultComment->CommentID > 0 ? '#Comment_'.$ResultComment->CommentID:'#pgbottom'), $Suffix);
					$UrlParts = explode("?", $Url);
					$QS = "";
					if (array_key_exists(1, $UrlParts)) $QS = str_replace("&amp;", "&", $UrlParts[1]);
					$Url = $UrlParts[0];
					if ($QS != "") $Url .= "?".str_replace("&amp;", "&", $UrlParts[1]);
					header('location:'.$Url);
					die();
				}
			}
		} elseif ($this->PostBackAction == 'Reply') {
			if ($this->Comment) $this->Comment->GetPropertiesFromForm();
		}
		
		if (!$this->IsPostBack && $this->Comment->DiscussionID == 0 && $this->Comment->CommentID == 0) {
			if (!$this->Discussion->Comment) $this->Discussion->Comment = $this->Context->ObjectFactory->NewContextObject($this->Context, 'Comment');
			
			$this->Discussion->Comment->FormatType = $this->Context->Session->User->DefaultFormatType;
			if ($this->Comment) $this->Comment->FormatType = $this->Context->Session->User->DefaultFormatType;
		}

		if ($this->Comment) $this->PostBackParams->Set('CommentID', $this->Comment->CommentID);
		$this->PostBackParams->Set('DiscussionID', $this->DiscussionID);
		$this->Title = $this->Context->GetDefinition('StartANewDiscussion');
		if ($this->EditDiscussionID > 0 || ($this->CommentID == 0 && $this->DiscussionID == 0)) {
			$this->Form = 'DiscussionForm';
		} else {
			$this->Form = 'CommentForm';
			if ($this->Comment && $this->Comment->CommentID > 0) {
				$this->Title = $this->Context->GetDefinition('EditYourComments');
			} else {
				$this->Title = $this->Context->GetDefinition('AddYourComments');
			}
		}
		$this->Context->PageTitle = $this->Title;
		$this->CallDelegate('PostSaveData');
	}
	
	function GetCommentForm($Comment) {
		$this->DelegateParameters['Comment'] = &$Comment;
		$this->CallDelegate('CommentForm_PreRender');
		
		// Encode everything properly
      $Comment->FormatPropertiesForDisplay(1);
		
		$this->PostBackParams->Set('PostBackAction', 'SaveComment');
		$this->PostBackParams->Set('UserCommentCount', $this->Context->Session->User->CountComments);
		$this->PostBackParams->Set('AuthUserID', $Comment->AuthUserID);

		include(ThemeFilePath($this->Context->Configuration, 'comment_form.php'));
		
		$this->CallDelegate('CommentForm_PostRender');
	}
	
	function GetDiscussionForm($Discussion) {
		$this->DelegateParameters['Discussion'] = &$Discussion;
		$this->CallDelegate('DiscussionForm_PreRender');
		
		if (!$this->DiscussionFormattedForDisplay) $Discussion->FormatPropertiesForDisplay();
		$Discussion->Comment->FormatPropertiesForDisplay(1);
		
		// Load the category selector
		$cm = $this->Context->ObjectFactory->NewContextObject($this->Context, 'CategoryManager');
		$CategoryData = $cm->GetCategories(0, 1);
		$cs = $this->Context->ObjectFactory->NewObject($this->Context, 'Select');
		$cs->Name = 'CategoryID';
		$cs->CssClass = 'CategorySelect';
		$cs->SelectedValue = ForceIncomingInt('CategoryID', $Discussion->CategoryID);
		$cat = $this->Context->ObjectFactory->NewObject($this->Context, 'Category');
		$LastBlocked = -1;
		while ($Row = $this->Context->Database->GetRow($CategoryData)) {
			$cat->Clear();
			$cat->GetPropertiesFromDataSet($Row);
			if ($cat->Blocked != $LastBlocked && $LastBlocked != -1) {
				$cs->AddOption("-1", "---", " disabled=\"true\"");
			}
			$cs->AddOption($cat->CategoryID, $cat->Name);
			$LastBlocked = $cat->Blocked;
		}
		
		$this->PostBackParams->Set('CommentID', $Discussion->FirstCommentID);
		$this->PostBackParams->Set('AuthUserID', $Discussion->AuthUserID);
		$this->PostBackParams->Set('UserDiscussionCount', $this->Context->Session->User->CountDiscussions);
		$this->PostBackParams->Set('PostBackAction', 'SaveDiscussion');
		
		include(ThemeFilePath($this->Context->Configuration, 'discussion_form.php'));
		
		$this->CallDelegate('DiscussionForm_PostRender');
	}
	
	function GetPostFormatting($SelectedFormatType) {
		$FormatCount = count($this->Context->StringManipulator->Formatters);
		$f = $this->Context->ObjectFactory->NewObject($this->Context, 'Radio');
		$f->Name = 'FormatType';
		$f->CssClass = 'FormatTypeRadio';
		$f->SelectedID = $SelectedFormatType;
		
		$this->DelegateParameters['FormatRadio'] = &$f;
		$ItemAppend = '';
		while (list($Name, $Object) = each($this->Context->StringManipulator->Formatters)) {
			$this->DelegateParameters['RadioItemName'] = &$Name;
			$this->DelegateParameters['RadioItemAppend'] = &$ItemAppend;
			$this->CallDelegate('PreFormatRadioItemAdd');
			$f->AddOption($Name, $this->Context->GetDefinition($Name), $ItemAppend);
			$ItemAppend = '';
		}
		$this->CallDelegate('PreFormatRadioRender');
		
		$sReturn = '';
		include(ThemeFilePath($this->Context->Configuration, 'post_formatter.php'));
		return $sReturn;
	}
	
	function Render() {
		if ($this->FatalError) {
			$this->Render_Warnings();
		} else {
			if ($this->Form == 'DiscussionForm') {
				$this->GetDiscussionForm($this->Discussion);
			} elseif ($this->Form == 'CommentForm') {
				$this->GetCommentForm($this->Comment);
			}
		}
	}
}
?>