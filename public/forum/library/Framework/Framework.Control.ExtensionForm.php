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
* Description: The ExtensionForm control is used to turn extensions on and off in Vanilla.
*/

class ExtensionForm extends PostBackControl {
	
	var $Extensions;
		
	function SwitchExtension($ExtensionKey) {
		// Don't do anything unless this user has permission to do so...
		if (!$this->Context->Session->User->Permission("PERMISSION_MANAGE_EXTENSIONS")) {
			$this->Context->WarningCollector->Add($this->Context->GetDefinition("ErrPermissionInsufficient"));
		} else {
			$this->Extensions = DefineExtensions($this->Context);
			$Extension = false;
			$ExtensionInUse = false;
			
			// Grab that extension from the extension array
			if (array_key_exists($ExtensionKey, $this->Extensions)) {
				$Extension = $this->Extensions[$ExtensionKey];
				$this->DelegateParameters["ExtensionName"] = $ExtensionKey;
				if ($Extension->Enabled) {
					$this->CallDelegate("PreExtensionDisable");
				} else {
					$this->CallDelegate("PreExtensionEnable");
				}
			} else {
				$this->Context->WarningCollector->Add($this->Context->GetDefinition("ErrExtensionNotFound"));
			}
			if ($Extension) {
				// Open the extensions file for editing
				$ExtensionsFile = $this->Context->Configuration["APPLICATION_PATH"]."conf/extensions.php";
				$CurrentExtensions = @file($ExtensionsFile);
				if (!$CurrentExtensions) {
					$this->Context->WarningCollector->Add($this->Context->GetDefinition("ErrReadFileExtensions")." ".$this->Context->Configuration["APPLICATION_PATH"]."conf/extensions.php");
				} else {
					// Loop through the lines
					$ExtensionCount = count($CurrentExtensions);
					for ($j = 0; $j < $ExtensionCount; $j++) {
						if ($Extension->Enabled) {
							if (trim($CurrentExtensions[$j]) == 'include($Configuration[\'EXTENSIONS_PATH\']."'.$Extension->FileName.'");') {
								// If the extension is currently in use, remove it
								array_splice($CurrentExtensions, $j, 1);
								$j = count($CurrentExtensions);
							}
						} elseif (trim($CurrentExtensions[$j]) == "?>") {
							// If the extension is NOT currently in use, add it
							$CurrentExtensions[$j] = 'include($Configuration[\'EXTENSIONS_PATH\']."'.$Extension->FileName.'");'."\r\n";
							$CurrentExtensions[] = "?>";
							$j = count($CurrentExtensions);
						}
					}
					// Save the extensions file
					// Open for writing only.
					// Place the file pointer at the beginning of the file and truncate the file to zero length. 
					$FileHandle = @fopen($ExtensionsFile, "wb");
					$FileContents = implode("", $CurrentExtensions);
					if (!$FileHandle) {
						$this->Context->WarningCollector->Add(str_replace("//1", $ExtensionsFile, $this->Context->GetDefinition("ErrOpenFile")));
					} else {
						if (!@fwrite($FileHandle, $FileContents)) $this->Context->WarningCollector->Add($this->Context->GetDefinition("ErrWriteFile"));
					}
					@fclose($FileHandle);					
				}
			}
		}
		// If everything was successful, return true;
		if ($this->Context->WarningCollector->Iif()) {
			return true;
		} else {
			return false;
		}		
	}
	
	function ExtensionForm(&$Context) {
      $this->Name = "ExtensionForm";
		$this->ValidActions = array("Extensions", "ProcessExtension");
		$this->Constructor($Context);
		if (!$this->Context->Session->User->Permission("PERMISSION_MANAGE_EXTENSIONS")) {
			$this->IsPostBack = 0;
		} elseif ($this->IsPostBack) {
			$this->Context->PageTitle = $this->Context->GetDefinition('ManageExtensions');
	      $this->Extensions = DefineExtensions($this->Context);
		}
      $this->CallDelegate("Constructor");
	}
	
	function Render() {
		if ($this->IsPostBack) {
			$this->CallDelegate("PreRender");
			include(ThemeFilePath($this->Context->Configuration, 'settings_extensions.php'));
			$this->CallDelegate("PostRender");
		}
	}
}
?>