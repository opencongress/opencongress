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
* Description: The PreferencesForm control allows users to alter their customizable forum preferences.
*/

class PreferencesForm extends PostBackControl {
	var $UserManager;
	var $User;
	var $Preferences;		// An array of preference options
	
	function PreferencesForm(&$Context, &$UserManager, $User) {
		$this->Name = 'PreferencesForm';
		$this->ValidActions = array('Functionality');
		$this->Constructor($Context);
		if ($this->IsPostBack) {
			$this->Preferences = array();
			$this->UserManager = &$UserManager;
			$this->User = $User;
			
			// Add the default preferences
         $this->AddPreference('DiscussionIndex', 'JumpToLastReadComment', 'JumpToLastReadComment');
         $this->AddPreference('CommentsForm', 'ShowFormatTypeSelector', 'ShowFormatSelector');

			if ($this->Context->Session->User->Permission('PERMISSION_RECEIVE_APPLICATION_NOTIFICATION')) {
	         $this->AddPreference('NewUsers', 'NewApplicantNotifications', 'SendNewApplicantNotifications', 0, 1);
			}
			if ($this->Context->Session->User->Permission('PERMISSION_VIEW_HIDDEN_DISCUSSIONS')) $this->AddPreference('HiddenInformation', 'DisplayHiddenDiscussions', 'ShowDeletedDiscussions', 0);
			if ($this->Context->Session->User->Permission('PERMISSION_VIEW_HIDDEN_COMMENTS')) $this->AddPreference('HiddenInformation', 'DisplayHiddenComments', 'ShowDeletedComments', 0);
		}
		$this->CallDelegate('Constructor');
	}
	
	function AddPreference($SectionLanguageCode, $PreferenceLanguageCode, $PreferenceName, $RefreshPageAfterSetting = '0', $IsUserProperty = '0') {
		if (!array_key_exists($SectionLanguageCode, $this->Preferences)) $this->Preferences[$SectionLanguageCode] = array();
		$Preference = array();
		$Preference['LanguageCode'] = $PreferenceLanguageCode;
		$Preference['Name'] = $PreferenceName;
		$Preference['RefreshPageAfterSetting'] = $RefreshPageAfterSetting;
		$Preference['IsUserProperty'] = $IsUserProperty;
		$this->Preferences[$SectionLanguageCode][] = $Preference;		
	}
	
	function Render() {
		if ($this->IsPostBack) {
			$this->CallDelegate('PreRender');
			include(ThemeFilePath($this->Context->Configuration, 'account_preferences_form.php'));
			$this->CallDelegate('PostRender');
		}
	}
}
?>