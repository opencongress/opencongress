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
* Description: The UpdateCheck control is used to ping the lussumo.com server to check for upgrades to Vanilla.
*/

class UpdateCheck extends PostBackControl {
	
	var $Extensions;
	var $ReminderSelect;
   
	function UpdateCheck(&$Context) {
      $this->Name = 'UpdateCheck';
		$this->ValidActions = array('UpdateCheck', 'ProcessUpdateCheck', 'ProcessUpdateReminder');
		$this->Constructor($Context);
		
		if (!$this->Context->Session->User->Permission('PERMISSION_CHECK_FOR_UPDATES')) {
			$this->IsPostBack = 0;
		}
		
		if ($this->IsPostBack) {
			$this->Context->PageTitle = $this->Context->GetDefinition('UpdatesAndReminders');
			$this->ReminderSelect = $this->Context->ObjectFactory->NewObject($this->Context, 'Select');
			$this->ReminderSelect->Name = 'ReminderRange';
			$this->ReminderSelect->AddOption('', $this->Context->GetDefinition('Never'));
			$this->ReminderSelect->AddOption('Weekly', $this->Context->GetDefinition('Weekly'));
			$this->ReminderSelect->AddOption('Monthly', $this->Context->GetDefinition('Monthly'));
			$this->ReminderSelect->AddOption('Quarterly', $this->Context->GetDefinition('Quarterly'));
			$this->ReminderSelect->SelectedValue = $this->Context->Configuration['UPDATE_REMINDER'];

			$SettingsFile = $this->Context->Configuration['APPLICATION_PATH'].'conf/settings.php';
		}
		
		if ($this->IsPostBack && $this->PostBackAction == 'ProcessUpdateCheck') {
			// Load the extensions
         $this->Extensions = DefineExtensions($this->Context);
			// Add an onload event to the document body
         $this->Context->BodyAttributes .= " onload=\"UpdateCheck('".$this->Context->Configuration['WEB_ROOT']."ajax/updatecheck.php', 'Core', '".$this->Context->Session->GetVariable("SessionPostBackKey", "string")."');\"";
			// Report that the postback is validated
         $this->PostBackValidated = 1;

		} elseif ($this->IsPostBack && $this->PostBackAction == 'ProcessUpdateReminder' && $this->IsValidFormPostBack()) {
			$ReminderRange = ForceIncomingString('ReminderRange', '');
			if (!in_array($ReminderRange, array('Weekly','Monthly','Quarterly'))) $ReminderRange = '';
			
			// Set the Reminder configuration option
			$ConfigurationManager = $this->Context->ObjectFactory->NewContextObject($this->Context, "ConfigurationManager");
			$ConfigurationManager->DefineSetting('UPDATE_REMINDER', $ReminderRange, 1);
			if ($ConfigurationManager->SaveSettingsToFile($SettingsFile)) {
				// If everything was successful, Redirect back with saved changes message
				if ($this->Context->WarningCollector->Iif()) {
					header("Location:".GetUrl($this->Context->Configuration, $this->Context->SelfUrl, "", "", "", "", "PostBackAction=UpdateCheck&Saved=1"));
					die();
				}
			}
		}
      $this->CallDelegate('Constructor');
	}

	function Render() {
		if ($this->IsPostBack) {
			$this->CallDelegate('PreRender');
			// Call different render methods based on the PostBack state.
			if ($this->PostBackValidated) {
				$this->Render_ValidPostBack();
			} else {
				$this->Render_NoPostBack();
			}
			$this->CallDelegate('PostRender');
		}
	}
	
	function Render_ValidPostBack() {
      $this->CallDelegate('PreValidPostBackRender');
      include(ThemeFilePath($this->Context->Configuration, 'settings_update_check_validpostback.php'));
      $this->CallDelegate('PostValidPostBackRender');
	}
	
	function Render_NoPostBack() {
		if ($this->IsPostBack) {
         $this->CallDelegate('PreNoPostBackRender');
			$this->PostBackParams->Clear();
			$this->PostBackParams->Set('PostBackAction', 'ProcessUpdateCheck');
         include(ThemeFilePath($this->Context->Configuration, 'settings_update_check_nopostback.php'));
         $this->CallDelegate('PostNoPostBackRender');
		}
	}
}
?>