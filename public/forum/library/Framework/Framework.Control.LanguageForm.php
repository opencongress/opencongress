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
* Description: The LanguageForm control is used to change the included language dictionary from the available dictionaries in the /languages folder
*/


class LanguageForm extends PostBackControl {
	var $Languages;
	var $LanguageSelect;
	var $CurrentLanguageKey;
	
	function DefineLanguages() {
      // Look in the provided path for files
      $FolderHandle = @opendir($this->Context->Configuration["LANGUAGES_PATH"]);
      if (!$FolderHandle) {
         $this->Context->WarningCollector->Add(str_replace("//1", $this->Context->Configuration["LANGUAGES_PATH"], $this->Context->GetDefinition("ErrOpenDirectoryLanguages")));
      } else {
			$this->Languages = array();
         
         // Loop through each file
         while (false !== ($Item = readdir($FolderHandle))) {
            if (is_dir($this->Context->Configuration["LANGUAGES_PATH"].$Item)
					&& $Item != '.'
					&& $Item != '..'
					&& substr($Item, 0, 1) != '_') {
               // Retrieve languages names
               if (substr($Item, 0, 1) != ".") $this->Languages[] = $Item;
            }
         }
      }
   }
	function LanguageForm(&$Context) {
		$this->Name = "LanguageForm";
		$this->ValidActions = array("LanguageChange", "ProcessLanguageChange");
		$this->Constructor($Context);
		if (!$this->Context->Session->User->Permission("PERMISSION_MANAGE_LANGUAGE")) {
			$this->IsPostBack = 0;
		} elseif ($this->IsPostBack) {
			$this->Context->PageTitle = $this->Context->GetDefinition('LanguageManagement');
			$this->DefineLanguages();
			$this->LanguageSelect = $this->Context->ObjectFactory->NewObject($Context, "Select");
			$this->LanguageSelect->Name = "LanguageKey";
			$this->LanguageSelect->Attributes = ' id="ddLanguage"';
			for ($i = 0; $i < count($this->Languages); $i++) {
				$this->LanguageSelect->AddOption($i, $this->Languages[$i]);
				if ($this->Languages[$i] == $this->Context->Configuration['LANGUAGE']) $this->LanguageSelect->SelectedValue = $i;
			}
			if ($this->PostBackAction == "ProcessLanguageChange" && $this->IsValidFormPostBack()) {
				$LanguageKey = ForceIncomingInt("LanguageKey", 0);
				// Grab that language from the languages array
            $Language = $this->Languages[$LanguageKey];
				if ($Language) {
					// Set the language configuration option
               $ConfigurationManager = $this->Context->ObjectFactory->NewContextObject($this->Context, "ConfigurationManager");
	            $ConfigurationManager->DefineSetting('LANGUAGE', $Language, 1);
					$SettingsFile = $this->Context->Configuration['APPLICATION_PATH'].'conf/settings.php';
					if ($ConfigurationManager->SaveSettingsToFile($SettingsFile)) {
						// If everything was successful, mark the postback as validated
						if ($this->Context->WarningCollector->Iif()) {
							header("Location:".GetUrl($this->Context->Configuration, $this->Context->SelfUrl, "", "", "", "", "PostBackAction=LanguageChange&Saved=1"));
							die();
						}
					}
				}
			} elseif ($this->PostBackAction == "LanguageChange" && ForceIncomingBool("Saved", 0) == 1) {
				$this->PostBackValidated = 1;
			}
		}
		$this->CallDelegate("Constructor");
	}
	
	function Render() {
		if ($this->IsPostBack) {
			$this->CallDelegate("PreNoPostBackRender");
			include(ThemeFilePath($this->Context->Configuration, 'settings_language_form.php'));
			$this->CallDelegate("PostNoPostBackRender");
		}
	}
}


?>
