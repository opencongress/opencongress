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
* Description: Class that builds a collection of name/value pairs based on a given collection.
* It is generally used for holding, changing, and then dumping querystring variables.
* Applications utilizing this file: Vanilla;
*/
class Parameters {
	var $aParameters = array();
	
	// Add an element to the collection
	function Add($Name, $Value, $EncodeValue = 1, $Id = '', $EncodeName = 1, $IsConstant = 0) {
		if ($EncodeValue && !is_array($Value)) $Value = urlencode($Value);
		if ($EncodeName) $Name = urlencode($Name);
		$this->aParameters[$Name] = array("Value" => $Value, "Id" => $Id, "IsConstant" => $IsConstant);
 	}
	
	// Completely clear the collection
	function Clear() {
		// This option will not clear any items marked with IsConstant
		$tmp = array();
		while (list($Name, $Value) = each($this->aParameters)) {
			if ($Value['IsConstant'] == 1) 
				$tmp[$Name] = $Value;
		}
		$this->aParameters = $tmp;
	}
	
	// Return a count of how many elements are in the collection
	function Count() {
		return count($this->aParameters);
	}
	
	// Retrieves all get and post variables
	function DefineCollection($Collection, $ParameterPrefix = '', $IncludeByPrefix = '0', $ExcludeByPrefix = '0') {
		$ParameterPrefix = ForceString($ParameterPrefix, '');
		$IncludeByPrefix = ForceBool($IncludeByPrefix, 0);
		$ExcludeByPrefix = ForceBool($ExcludeByPrefix, 0);
		$Add = 1;
		while (list($key, $value) = each($Collection)) {
			$Add = 1;
			if ($ParameterPrefix != '') {
				$PrefixMatchLocation = strstr($key, $ParameterPrefix);
				// If the prefix isn't found or the location is anywhere other than 0 (the start of the variable name)
				if ($PrefixMatchLocation === false || $PrefixMatchLocation != 0) {
					if ($IncludeByPrefix) $Add = 0;
				} else {
					if ($ExcludeByPrefix) $Add = 0;
				}
			}
			if ($Add) $this->Add($key, $value);
		}		
	}
	
	function GetHiddenInputs() {
		$sReturn = '';
		$Id = '';
		$Value = '';
		while (list($key, $val) = each($this->aParameters)) {
			$Value = $val['Value'];
			$Id = $val['Id'];
			if(is_array($Value)) {
				$nmrows = count($Value);
				$i = 0;
				for ($i = 0; $i < $nmrows; ++$i) {
					// Repetitive values cannot have an unique id, so ignore the id param
					$sReturn .= '<input type="hidden" name="'.$key.'[]" value="'.$Value[$i].'" />
					';
				}
			} else {
				$sReturn .= '<input'.($Id == '' ? '' : ' id="'.$Id.'"').' type="hidden" name="'.$key.'" value="'.$Value.'" />
				';
			}
		}
		reset($this->aParameters);
		return '<div>'.$sReturn.'</div>';
	}
	
	// Return the collection as a string in querystring name/value pair format
	function GetQueryString($IncludeQuestionMark = '0') {
		$sReturn = '';
		$Value = '';
		while (list($key, $val) = each($this->aParameters)) {
			$Value = $val['Value'];
			if(is_array($Value)) {
				$nmrows = count($Value);
				for ($i = 0; $i < $nmrows; ++$i) {
					$sReturn .= $key .'[]=' . $Value[$i] . '&amp;';
				}
			} else {
				$sReturn .= $key . '=' . $Value . '&amp;';
			}
		}
		// remove trailing ampersand
		$sReturn = substr($sReturn,0,strlen($sReturn) - 5);
		if ($sReturn != '' && $IncludeQuestionMark) $sReturn = '?'.$sReturn;
		reset($this->aParameters);
		return $sReturn;
	}
	
	// Remove an element from the collection
	function Remove($Name) {
		$key_index = array_keys(array_keys($this->aParameters), $Name); 
		if (count($key_index) > 0) array_splice($this->aParameters, $key_index[0], 1);
	}
	// Set a value. If it already exists, overwrite it.
	function Set($Name, $Value, $EncodeValue = 1, $Id = '', $IsConstant = 0) {
		$this->Remove($Name);
		$this->Add($Name, $Value, $EncodeValue, $Id, 1, $IsConstant);
	}
}
?>