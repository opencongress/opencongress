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
* Description: Class that builds and maintains a select list.
* Applications utilizing this file: Vanilla;
*/

class Select {
	var $Name;			// Name of the select list
   var $SelectedValue; // The value to be selected in the list (you can pass an array of ids for multiselects)
	var $CssClass;		// Stylesheet class name
	var $Attributes;	// Additional attributes for select element
	var $aOptions;		// Array for holding select options
	
	function AddOption($IdValue, $DisplayValue, $Attributes = '') {
		$this->aOptions[] = array('IdValue' => $IdValue, 'DisplayValue' => $DisplayValue, 'Attributes' => $Attributes);
	}

	function AddOptionsFromAssociativeArray($Array, $KeyPrefix) {
		while (list($key, $val) = each($Array)) {
			$this->AddOption($KeyPrefix.$key, $val);
		}		
	}

	function AddOptionsFromDataSet(&$Database, $DataSet, $IdField, $DisplayField) {
		while ($rows = $Database->GetRow($DataSet)) {
			$this->AddOption($rows[$IdField], $rows[$DisplayField]);
		}	
	}
	
	function Clear() {
		$this->Name = '';
		$this->CssClass = 'LargeSelect';
		$this->Attributes = '';
		$this->aOptions = array();
	}
	
	function ClearOptions() {
		$this->aOptions = array();
	}
	
	function Count() {
		return count($this->aOptions);
	}

	function Get() {
		$sReturn = '<select name="'.$this->Name.'" class="'.$this->CssClass.'" '.$this->Attributes.'>
		';
		$OptionCount = count($this->aOptions);
		$i = 0;
		for ($i = 0 ; $i < $OptionCount; $i++) {
			$sReturn .= '<option value="'.FormatStringForDisplay($this->aOptions[$i]['IdValue']).'" ';
		
			if (is_array($this->SelectedValue)) {
				$numrows = count($this->SelectedValue);
				for ($j = 0; $j < $numrows; $j++) {
					if ($this->aOptions[$i]['IdValue'] == $this->SelectedValue[$j]) {
						$sReturn .= ' selected="selected"';
						$j = $numrows; // If you've found a match, don't bother looping anymore
					}
				}			
			} else {
				if ($this->aOptions[$i]['IdValue'] == $this->SelectedValue) $sReturn .= ' selected="selected"';
			}
			if ($this->aOptions[$i]['Attributes'] != '') $sReturn .= $this->aOptions[$i]['Attributes'];
			$sReturn .= '>'.FormatStringForDisplay($this->aOptions[$i]['DisplayValue']).'</option>
			';
		}
		$sReturn .= '</select>
		';
		return $sReturn;
	}

	function RemoveOption($IdValue) {
		if ($IdValue == $this->SelectedValue) $this->SelectedValue = '';
		$OptionCount = count($this->aOptions);
		$i = 0;
		for($i = 0; $i < $OptionCount; $i++) {
			if ($this->aOptions[$i]['IdValue'] == $IdValue) {
				array_splice($this->aOptions, $i, 1);
				break;
			}
		}
	}

	function Select() {
		$this->Clear();
	}

	function Write() {
		echo($this->Get());
	}
}
?>