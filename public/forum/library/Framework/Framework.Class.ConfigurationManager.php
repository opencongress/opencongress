<?php
/*
* Copyright 2003 Mark O'Sullivan
* This file is part of Lussumo's Software Library.
* Lussumo's Software Library is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
* Lussumo's Software Library is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
* You should have received a copy of the GNU General Public License along with Vanilla; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
* The latest source code is available at www.lussumo.com
* Contact Mark O'Sullivan at mark [at] lussumo [dot] com
* 
* Description: Manages retrieving and setting configuration properties
*/

class ConfigurationManager {
   
   var $Context;
   var $Settings;
   var $_settings;
   
   function ConfigurationManager(&$Context) {
      $this->Context = &$Context;
      $this->Settings = $this->Context->Configuration;
      $this->_settings = array();
   }
   
   function DefineSetting($Name, $Value, $ForSaving = "0") {
      if (!$ForSaving) $Value = $this->EncodeSettingValue($Value);
      $this->_settings[$Name] = $Value;
   }
   
   function EncodeSettingValue($Value) {
      return htmlentities($Value, ENT_QUOTES);
   }
   
   function EncodeSettingValueForSaving($Value) {
      $Value = str_replace('\\', '\\', html_entity_decode($Value, ENT_QUOTES));
      return str_replace(array("'", "\n", "\r"), array('\\\'', '\\\n', '\\\r'), $Value);
   }
   
   function GetSetting($SettingName) {
      if (array_key_exists($SettingName, $this->Settings)) {
         return str_replace(array('"', '\\n', '\\r'), array('&quot;', "\n", "\r"), $this->Settings[$SettingName]);
      } else {
         return "";
      }
   }
   
   function UpdateConfigurationFileContents($File) {
      $Lines = @file($File);
      if (!$Lines) {
         $this->Context->WarningCollector->Add($this->Context->GetDefinition('ErrReadFileSettings')
            .$File
            .($php_errormsg != '' ? '<code>'.$php_errormsg.'</code>' : ''));
      } else {
         $CurrentLine = '';
         $CurrentSetting = '';
         $LineCount = count($Lines);
         $i = 0;
         for ($i = 0; $i < $LineCount; $i++) {
            $CurrentLine = trim($Lines[$i]);
            $Comments = "";
            if (substr($CurrentLine, 0, 16) == "\$Configuration['") {
               $CommentPosition = strpos($CurrentLine, '";');
               if ($CommentPosition !== false) {
                  $Comments = substr($CurrentLine, $CommentPosition+6);
                  $CurrentLine = substr($CurrentLine, 0, $CommentPosition+6);
               }
               $CurrentLine = str_replace("\$Configuration['", "", $CurrentLine);
               $CurrentLine = str_replace("';", '', $CurrentLine);
               $Values = explode("'] = '", $CurrentLine);
               if (count($Values) == 2) {
                  $CurrentSetting = trim(str_replace('"', '', $Values[0]));
                  if (array_key_exists($CurrentSetting, $this->_settings)) {
                     $Lines[$i] = "\$Configuration['"
                        .$CurrentSetting."'] = '"
                        .$this->EncodeSettingValueForSaving($this->_settings[$CurrentSetting])
                        ."'; "
                        .$Comments
                        ."\n";
                     $this->RemoveSetting($CurrentSetting);
                  }
               }               
            } elseif (substr($CurrentLine, 0, 2) == '?>') {
               $Lines[$i] = '';
            }
         }
         // Now add the remaining settings in the _settings array that are different from the existing Settings
         while (list($Name, $Value) = each($this->_settings)) {
            if (array_key_exists($Name, $this->Settings)) {
               if ($this->Settings[$Name] != $Value) {
                  $Lines[] = "\$Configuration['"
                  .$Name."'] = '"
                  .$this->EncodeSettingValueForSaving($this->_settings[$Name])
                  ."';\n";
               }               
            }            
         }
         $Lines[] = '?>';
      }
      if ($Lines) {
         return implode('', $Lines);
      } else {
         return false;
      }
   }
   
   function GetSettingsFromFile($File) {
         $Lines = @file($File);
      if (!$Lines) {
         $this->Context->WarningCollector->Add($this->Context->GetDefinition('ErrReadFileSettings')
            .$File
            .($php_errormsg != '' ? '<code>'.$php_errormsg.'</code>' : ''));
      } else {
         $CurrentLine = '';
         $CurrentSetting = '';
         $LineCount = count($Lines);
         $i = 0;
         for ($i = 0; $i < $LineCount; $i++) {
            $CurrentLine = trim($Lines[$i]);
            $Comments = "";
            if (substr($CurrentLine, 0, 16) == "\$Configuration['") {
               $CommentPosition = strpos($CurrentLine, '";');
               if ($CommentPosition !== false) {
                  $Comments = substr($CurrentLine, $CommentPosition+6);
                  $CurrentLine = substr($CurrentLine, 0, $CommentPosition+6);
               }
               $CurrentLine = str_replace("\$Configuration['", "", $CurrentLine);
               $CurrentLine = str_replace("';", '', $CurrentLine);
               $Values = explode("'] = '", $CurrentLine);
               if (count($Values) == 2) {
                  $this->Settings[trim(str_replace('"', '', $Values[0]))] = trim(str_replace('"', '', $Values[1]));
               }               
            }
         }
      }
   }
   
   function GetSettingsFromForm($TemplateFile) {
      // First define the constants again
      while (list($Name, $OriginalValue) = each($this->Settings)) {
         if (isset($_POST[$Name])) {
            $Value = ForceIncomingString($Name, "");
         } else {
            $Value = $OriginalValue;
         }
         $this->DefineSetting($Name, $Value, 1);
      }
   }

   function RemoveSetting($Name) {
      $this->_settings = $this->RemoveItemFromArray($this->_settings, $Name);
   }
   
   function RemoveItemFromArray($Array, $ItemName) {
      $key_index = array_keys(array_keys($Array), $ItemName); 
		if (count($key_index) > 0) array_splice($Array, $key_index[0], 1);
      return $Array;
   }
   
   function SaveSettingsToFile($File) {
      // Open for writing only.
      // Place the file pointer at the beginning of the file and truncate the file to zero length. 
      // If the file does not exist, attempt to create it.
      $FileContents = $this->UpdateConfigurationFileContents($File);
      if ($this->Context->WarningCollector->Iif()) {
         $FileHandle = @fopen($File, "wb");
         if (!$FileHandle) {
            $this->Context->WarningCollector->Add(str_replace("//1", $File, $this->Context->GetDefinition("ErrOpenFile")));
         } else {
            if (!@fwrite($FileHandle, $FileContents)) $this->Context->WarningCollector->Add($this->Context->GetDefinition("ErrWriteFile"));
         }
         @fclose($FileHandle);
      }
      return $this->Context->WarningCollector->Iif();
   }
   
}
?>