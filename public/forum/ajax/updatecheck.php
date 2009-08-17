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
* Description: File used by the Extension management form to handle turning extensions on and off
*/

include('../appg/settings.php');
include('../appg/init_ajax.php');

// Process the ajax request
$PostBackKey = ForceIncomingString('PostBackKey', '');
$ExtensionKey = ForceIncomingString('ExtensionKey', '');
$RequestName = ForceIncomingString('RequestName', '');
if ($PostBackKey != $Context->Session->GetVariable('SessionPostBackKey', 'string')) {
   echo $RequestName.'|[ERROR]'.$Context->GetDefinition('ErrPostBackKeyInvalid');
} else if ($RequestName == 'Core') {
   // Ping the Lussumo server with core version information
   $VersionStatus = OpenUrl($Context->Configuration['UPDATE_URL']
      .'?Application=VanillaCore'
      .'&Version='.APPLICATION_VERSION
      .'&Language='.$Context->Configuration['LANGUAGE']
      .'&RequestUrl='.$Context->Configuration['BASE_URL'],
      $Context);
      
   // Also record that the check occurred
   $SettingsFile = $Context->Configuration['APPLICATION_PATH'].'conf/settings.php';
   $ConfigurationManager = $Context->ObjectFactory->NewContextObject($Context, "ConfigurationManager");
   $ConfigurationManager->DefineSetting('LAST_UPDATE', mktime(), 1);
   $ConfigurationManager->SaveSettingsToFile($SettingsFile);
   
   // Spit out the core message
   if ($VersionStatus == "GOOD") {
      echo 'First|'.$Context->GetDefinition('ApplicationStatusGood');
   } else {
      $aVersionStatus = explode("|", $VersionStatus);
      if (count($aVersionStatus) == 2) {
         echo 'First|[OLD]'.str_replace(array('\\1','\\2'), array($aVersionStatus[0], $aVersionStatus[1]), $Context->GetDefinition('NewVersionAvailable'));
      } else {
         // There was some kind of error
         echo 'First|[ERROR]'.$VersionStatus;
      }
   }
} else {
   // Load all extensions for version information
   $Extensions = DefineExtensions($Context);
   if (!is_array($Extensions)) {
      echo $RequestName.'|[ERROR]'.$Context->WarningCollector->GetPlainMessages();
   } elseif (count($Extensions) > 0) {
      // All of the extensions were loaded successfully.
      // Ping the Lussumo server with the next extension
      $CheckExtension = '';
      while (list($ExtensionKey, $Extension) = each($Extensions)) {
         if ($RequestName == 'First') {
            $CheckExtension = $ExtensionKey;
            $RequestName = '';
            break;
         } else if ($RequestName == $ExtensionKey) {
            $RequestName = '[NEXT]';
         } else if ($RequestName == '[NEXT]') {
            $CheckExtension = $ExtensionKey;
            $RequestName = '';
            break;
         }
      }
      
      // Ping the CheckExtension value if it isn't empty
      if ($CheckExtension != '') {
         $Extension = $Extensions[$CheckExtension];
         // Ping the Lussumo server with extension version information
         $VersionStatus = OpenUrl($Context->Configuration['UPDATE_URL']
            .'?Extension='.unhtmlspecialchars($Extension->Name)
            .'&Version='.unhtmlspecialchars($Extension->Version),
            $Context);
         if ($VersionStatus == "GOOD") {
            echo $CheckExtension.'|[GOOD]'.$Context->GetDefinition('ExtensionStatusGood');
         } elseif ($VersionStatus == "UNKNOWN") {
            echo $CheckExtension.'|[UNKNOWN]'.$Context->GetDefinition('ExtensionStatusUnknown');
         } else {
            // If an item is out of date, it contains two bits of information
            // separated by pipes
            // eg. Version|URL
            $aVersionStatus = explode("|", $VersionStatus);
            if (count($aVersionStatus) == 2) {
               echo $CheckExtension.'|[OLD]'.str_replace(array('\\1','\\2'), array($aVersionStatus[0], $aVersionStatus[1]), $Context->GetDefinition('NewVersionAvailable'));
            } else {
               // There was some kind of error
               echo $CheckExtension.'|[ERROR]'.$VersionStatus;
            }
         }
      } else {
         if ($RequestName == '[NEXT]') {
            echo 'COMPLETE';
         } else {
            echo $RequestName.'Failed to get extension name from ajax call.';
         }
      }
   } else {
      echo 'COMPLETE';
   }
}
$Context->Unload();
?>