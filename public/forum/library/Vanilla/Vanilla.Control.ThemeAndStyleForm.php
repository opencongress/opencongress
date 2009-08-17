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
* Description: The ThemeAndStyleForm control is used to change the theme and style of Vanilla.
*/


class ThemeAndStyleForm extends PostBackControl {
	var $Themes;
	var $Styles;
	var $ThemeSelect;
	var $StyleSelect;
	
	function DefineThemes() {
		$ThemeRoot = $this->Context->Configuration['APPLICATION_PATH'].'themes/';
      $FolderHandle = @opendir($ThemeRoot);
      if (!$FolderHandle) {
         $this->Context->WarningCollector->Add(str_replace("//1", $ThemeRoot, $this->Context->GetDefinition("ErrOpenDirectoryThemes")));
      } else {
			$this->Themes = array();
         
         // Loop through each file
         while (false !== ($Item = readdir($FolderHandle))) {
            // Retrieve theme names (folders which are not system folders or hidden folders
            if (!in_array($Item, array('.', '..'))
					&& is_dir($ThemeRoot.$Item)
					&& substr($Item, 0, 1) != '_'
					&& substr($Item, 0, 1) != '.') $this->Themes[] = $Item;
         }
      }
   }
	
	function DefineStyles($ThemePath) {
		$StyleRoot = $ThemePath.'styles/';
      $FolderHandle = @opendir($StyleRoot);
      if (!$FolderHandle) {
         $this->Context->WarningCollector->Add(str_replace("//1", $StyleRoot, $this->Context->GetDefinition("ErrOpenDirectoryStyles")));
      } else {
			$this->Styles = array();
         
         // Loop through each file
         while (false !== ($Item = readdir($FolderHandle))) {
            // Retrieve style names (folders which are not system folders or hidden folders
            if (!in_array($Item, array('.', '..'))
					&& is_dir($StyleRoot.$Item)
					&& substr($Item, 0, 1) != '_'
					&& substr($Item, 0, 1) != '.') $this->Styles[] = $Item;
         }
      }
	}
	
	function ThemeAndStyleForm(&$Context) {
		$this->Name = 'ThemeAndStyleForm';
		$this->ValidActions = array('ThemeChange', 'ProcessThemeChange', 'ProcessStyleChange');
		$this->Constructor($Context);
		
		if (!$this->Context->Session->User->Permission("PERMISSION_MANAGE_THEMES")
			&& !$this->Context->Session->User->Permission("PERMISSION_MANAGE_STYLES")) {
			$this->IsPostBack = 0;
		} elseif ($this->IsPostBack) {
			$this->Context->PageTitle = $this->Context->GetDefinition('ManageThemeAndStyle');
			$this->DefineThemes();
			
			// Get the name of the current theme folder
         $CurrentThemeKey = ForceIncomingString('Theme', '');
			if ($CurrentThemeKey != '') {
				$CurrentTheme = $this->Themes[ForceInt($CurrentThemeKey, 0)];

			} else {
				$CurrentThemePath = str_replace('\\', '/', $this->Context->Configuration['THEME_PATH']);
				if (substr($CurrentThemePath, strlen($CurrentThemePath)-1, 1) == '/') $CurrentThemePath = substr($CurrentThemePath, 0, strlen($CurrentThemePath)-1);
				$CurrentThemeParts = explode('/', $CurrentThemePath);
				$CurrentTheme = $CurrentThemeParts[count($CurrentThemeParts)-1];
			}
			
			$this->DefineStyles($this->Context->Configuration['APPLICATION_PATH'].'themes/'.$CurrentTheme.'/');
			
			// Create the theme dropdown
			if ($this->Context->Session->User->Permission("PERMISSION_MANAGE_THEMES")) {
				$this->ThemeSelect = $this->Context->ObjectFactory->NewObject($Context, "Select");
				$this->ThemeSelect->Name = "Theme";				
				$this->ThemeSelect->Attributes = " id=\"ddTheme\" onchange=\"document.location='".GetUrl($this->Context->Configuration, $this->Context->SelfUrl, '', '', '', '', 'PostBackAction=ThemeChange&amp;Theme=')."'+this.options[this.selectedIndex].value;\"";
				for ($i = 0; $i < count($this->Themes); $i++) {
					$this->ThemeSelect->AddOption($i, $this->Themes[$i]);
					if ($this->Themes[$i] == $CurrentTheme) $this->ThemeSelect->SelectedValue = $i;
				}				
			}
			
			// Create the style dropdown
			if ($this->Context->Session->User->Permission("PERMISSION_MANAGE_STYLES")) {
				$this->StyleSelect = $this->Context->ObjectFactory->NewObject($Context, "Select");
				$this->StyleSelect->Name = "Style";
				$this->StyleSelect->Attributes = ' id="ddStyle"';
				for ($i = 0; $i < count($this->Styles); $i++) {
					$this->StyleSelect->AddOption($i, $this->Styles[$i]);
					if ($this->Context->Configuration['WEB_ROOT'].'themes/'.$CurrentTheme.'/styles/'.$this->Styles[$i].'/' == $this->Context->Configuration['DEFAULT_STYLE']) $this->StyleSelect->SelectedValue = $i;
				}				
			}

			$SettingsFile = $this->Context->Configuration['APPLICATION_PATH'].'conf/settings.php';
			
			if ($this->PostBackAction == "ProcessThemeChange" && $this->IsValidFormPostBack()) {
				$Theme = $this->Themes[ForceIncomingInt('Theme', 0)];
				
				// Set the theme configuration option
				if ($this->Context->Session->User->Permission("PERMISSION_MANAGE_THEMES")) {
					$ConfigurationManager = $this->Context->ObjectFactory->NewContextObject($this->Context, "ConfigurationManager");
					$ConfigurationManager->DefineSetting('THEME_PATH', $this->Context->Configuration['APPLICATION_PATH'].'themes/'.$Theme.'/', 1);
					$ConfigurationManager->SaveSettingsToFile($SettingsFile);
				}
				

				if ($this->Context->Session->User->Permission("PERMISSION_MANAGE_STYLES")) {
					// Set the style configuration option
					$StyleKey = ForceIncomingString("Style", '');
					$NewStyleName = $this->Styles[$StyleKey];
					$NewStylePath = $this->Context->Configuration['WEB_ROOT'].'themes/'.$CurrentTheme.'/styles/'.$NewStyleName.'/';
					
					$ConfigurationManager = $this->Context->ObjectFactory->NewContextObject($this->Context, "ConfigurationManager");
					$ConfigurationManager->DefineSetting('DEFAULT_STYLE', $NewStylePath, 1);
					$ConfigurationManager->SaveSettingsToFile($SettingsFile);
					
					// See if this style exists in the database yet
               $s = $this->Context->ObjectFactory->NewContextObject($this->Context, 'SqlBuilder');
					$s->SetMainTable('Style', 's');
					$s->AddSelect('StyleID', 's');
					$s->AddWhere('s', 'Url', '', $NewStylePath, '=');
					
					$StyleData = $this->Context->Database->Select($s, $this->Name, 'Constructor', 'An error occurred while attempting to retrieve information from the database about the selected style.');
					$StyleID = 0;
					while ($rows = $this->Context->Database->GetRow($StyleData)) {
						$StyleID = ForceInt($rows['StyleID'], 0);
					}
					
					// If the style doesn't exist yet, add it
               if ($StyleID == 0) {
						$s->Clear();
						$s->SetMainTable('Style', 's');
						$s->AddFieldNameValue('Name', $NewStyleName);
						$s->AddFieldNameValue('Url', $NewStylePath);
						$s->AddFieldNameValue('PreviewImage', 'preview.gif');
						
						$StyleID = $this->Context->Database->Insert($s, $this->Name, 'Constructor', 'An error occurred while adding the style to the database.');
					}
					
					// Now that the style has been properly defined, apply it to all users if required
               if ($StyleID > 0 && ForceIncomingBool('ApplyStyleToUsers', 0)) {
						$s->Clear();
						$s->SetMainTable('User', 'u');
						$s->AddFieldNameValue('StyleID', $StyleID);
						$this->Context->Database->Update($s, $this->Name, 'Constructor', 'An error occurred while applying the style to the user accounts.');
					}

				}
				if ($this->Context->WarningCollector->Count() == 0) {
					// If everything was successful, mark the postback as validated
					if ($this->Context->WarningCollector->Iif()) {
						header("Location:".GetUrl($this->Context->Configuration, $this->Context->SelfUrl, "", "", "", "", "PostBackAction=ThemeChange&Saved=1"));
						die();
					}
				}
			}

		}
		$this->CallDelegate("Constructor");
	}

	
	function Render() {
		if ($this->IsPostBack) {
			$this->PostBackParams->Set('PostBackAction', 'ProcessThemeChange');
			$this->CallDelegate('PreNoPostBackRender');
			include(ThemeFilePath($this->Context->Configuration, 'settings_theme_and_style_form.php'));
			$this->CallDelegate('PostNoPostBackRender');
		}
	}
}


?>
