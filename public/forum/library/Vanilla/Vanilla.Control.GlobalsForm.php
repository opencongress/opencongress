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
* Description: The GlobalsForm control is used to alter global configuration settings defined in appg/settings.php. Changes are saved to conf/settings.php.
*/

class GlobalsForm extends PostBackControl {
	
	var $ConfigurationManager;

	function GlobalsForm(&$Context) {
		$this->Name = 'GlobalsForm';
		$this->ValidActions = array('Globals', 'ProcessGlobals');
		$this->Constructor($Context);
		if (!$this->Context->Session->User->Permission('PERMISSION_CHANGE_APPLICATION_SETTINGS')) {
			$this->IsPostBack = 0;
		} elseif ($this->IsPostBack) {
			$this->Context->PageTitle = $this->Context->GetDefinition('ApplicationSettings');
			
			$SettingsFile = $this->Context->Configuration['APPLICATION_PATH'].'conf/settings.php';
			
			$this->ConfigurationManager = $this->Context->ObjectFactory->NewContextObject($this->Context, 'ConfigurationManager');
			if ($this->PostBackAction == 'ProcessGlobals' && $this->IsValidFormPostBack()) {
				$this->ConfigurationManager->GetSettingsFromForm($SettingsFile);
				// Checkboxes aren't posted back if unchecked, so make sure that they are saved properly
            $this->ConfigurationManager->DefineSetting('ENABLE_WHISPERS', ForceIncomingBool('ENABLE_WHISPERS', 0), 0);
            $this->ConfigurationManager->DefineSetting('ALLOW_NAME_CHANGE', ForceIncomingBool('ALLOW_NAME_CHANGE', 0), 0);
            $this->ConfigurationManager->DefineSetting('PUBLIC_BROWSING', ForceIncomingBool('PUBLIC_BROWSING', 0), 0);
            $this->ConfigurationManager->DefineSetting('USE_CATEGORIES', ForceIncomingBool('USE_CATEGORIES', 0), 0);
            $this->ConfigurationManager->DefineSetting('LOG_ALL_IPS', ForceIncomingBool('LOG_ALL_IPS', 0), 0);
				// And save everything
				if ($this->ConfigurationManager->SaveSettingsToFile($SettingsFile)) {
					header('location: '.GetUrl($this->Context->Configuration, 'settings.php', '', '', '', '', 'PostBackAction=Globals&Success=1'));
				} else {
					$this->PostBackAction = 'Globals';
				}
			}
		}
      $this->CallDelegate('Constructor');
	}
	
	function Render() {
		if ($this->IsPostBack) {
         $this->CallDelegate('PreRender');
			$this->PostBackParams->Clear();
			$this->PostBackParams->Set('PostBackAction', 'ProcessGlobals');
         include(ThemeFilePath($this->Context->Configuration, 'settings_globals_form.php'));
         $this->CallDelegate('PostRender');
		}
	}
}
?>