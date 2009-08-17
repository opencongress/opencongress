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
* Description: Instantiates objects. Allows developer's to clone and change existing classes and have their objects used throughout the application, instead of the application default objects.
* Applications utilizing this file: Vanilla;
*/
class ObjectFactory {
	var $ClassIndex;        // An array containing name/value pairs mapping labels to class names

	// Private (used internally - should use NewObject or NewContextObject externally)
   function CreateObject(&$Context, $ClassLabel, $IsContextObject, $Param1 = '', $Param2 = '', $Param3 = '', $Param4 = '', $Param5 = '', $Param6 = '', $Param7 = '', $Param8 = '', $Param9 = '', $Param10 = '') {
      if (!array_key_exists($ClassLabel, $this->ClassIndex)) {
         // If the class has not yet been defined, assume the class label is the class name
         $ClassName = $ClassLabel;
      } else {
         $ClassName = $this->ClassIndex[$ClassLabel];
      }
      if (!class_exists($ClassName)) {
			$PrefixArray = $Context->Configuration['LIBRARY_NAMESPACE_ARRAY'];
			$PrefixArrayCount = count($PrefixArray);
			$i = 0;
			for ($i = 0; $i < $PrefixArrayCount; $i++) {
            $File = $Context->Configuration['LIBRARY_PATH'].$PrefixArray[$i].'/'.$PrefixArray[$i].'.Class.'.$ClassName.'.php';
				if (file_exists($File)) {
					include($File);
					break;
				}
			}
	
			// If it failed to find the class, throw a fatal error
			if (!class_exists($ClassName)) $Context->ErrorManager->AddError($Context, 'ObjectFactory', 'NewObject', 'The "'.$ClassName.'" class referenced by "'.$ClassLabel.'" does not appear to exist.');
		}
		if ($IsContextObject) {
			return new $ClassName($Context, $Param1, $Param2, $Param3, $Param4, $Param5, $Param6, $Param7, $Param8, $Param9, $Param10);
		} else {
			return new $ClassName($Param1, $Param2, $Param3, $Param4, $Param5, $Param6, $Param7, $Param8, $Param9, $Param10);
		}
	}
	
   function CreateControl(&$Context, $ClassLabel, $Param1 = '', $Param2 = '', $Param3 = '', $Param4 = '', $Param5 = '', $Param6 = '', $Param7 = '', $Param8 = '', $Param9 = '', $Param10 = '') {
      if (!array_key_exists($ClassLabel, $this->ClassIndex)) {
         // If the class has not yet been defined, assume the class label is the class name
         $ClassName = $ClassLabel;
      } else {
         $ClassName = $this->ClassIndex[$ClassLabel];
      }
      if (!class_exists($ClassName)) {
			$PrefixArray = $Context->Configuration['LIBRARY_NAMESPACE_ARRAY'];
			$PrefixArrayCount = count($PrefixArray);
			$i = 0;
			for ($i = 0; $i < $PrefixArrayCount; $i++) {
            $File = $Context->Configuration['LIBRARY_PATH'].$PrefixArray[$i].'/'.$PrefixArray[$i].'.Control.'.$ClassName.'.php';
				if (file_exists($File)) {
					include($File);
					break;
				}
			}
			// If it failed to find the class, throw a fatal error
			if (!class_exists($ClassName)) {
				$Context->ErrorManager->AddError($Context, 'ObjectFactory', 'CreateControl', 'The "'.$ClassName.'" control referenced by "'.$ClassLabel.'" does not appear to exist.');
			}
		}
		return new $ClassName($Context, $Param1, $Param2, $Param3, $Param4, $Param5, $Param6, $Param7, $Param8, $Param9, $Param10);
	}
	
	// Almost identical to NewObject, but passes the context by reference as the first variable in the constructor of the object
	function NewContextObject(&$Context, $ClassLabel, $Param1 = '', $Param2 = '', $Param3 = '', $Param4 = '', $Param5 = '', $Param6 = '', $Param7 = '', $Param8 = '', $Param9 = '', $Param10 = '') {
		return $this->CreateObject($Context, $ClassLabel, 1, $Param1, $Param2, $Param3, $Param4, $Param5, $Param6, $Param7, $Param8, $Param9, $Param10);
	}
	
	// Create a new object based on a class name. Will gracefully error out if the class does not exist
	function NewObject(&$Context, $ClassLabel, $Param1 = '', $Param2 = '', $Param3 = '', $Param4 = '', $Param5 = '', $Param6 = '', $Param7 = '', $Param8 = '', $Param9 = '', $Param10 = '') {
		return $this->CreateObject($Context, $ClassLabel, 0, $Param1, $Param2, $Param3, $Param4, $Param5, $Param6, $Param7, $Param8, $Param9, $Param10);
	}
   
   function ObjectFactory () {
      $this->ClassIndex = array();
		$this->ControlStrings = array();
   }
   
   // For debugging, allow the current references to be written
   function PrintReferences() {
      while (list($Label, $Name) = each($this->ClassIndex)) {
         echo('<div>'.$Label.': '.$Name.'</div>');
      }      
   }
	
	function SetReference($ClassLabel, $ClassName = '') {
      if ($ClassName == '') $ClassName = $ClassLabel;
      $this->ClassIndex[$ClassLabel] = $ClassName;
	}	
}
?>