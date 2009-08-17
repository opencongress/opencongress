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
* Description: Class that builds and maintains a checkbox list.
*/
class Checkbox {
	var $Name;		      	// Name of the checkbox list
	var $aOptions;	      	// Array for holding checkbox options
   
	function AddOption($IdValue, $DisplayValue, $Checked, $FlipCheckedValue, $Attributes = '') {
		$this->aOptions[] = array('IdValue' => $IdValue,
         'DisplayValue' => $DisplayValue,
         'Checked' => ($FlipCheckedValue ? FlipBool($Checked) : $Checked),
         'Attributes' => $Attributes);
	}
	
	function AddOptionsFromDataSet(&$Database, $DataSet, $IdField, $DisplayField, $CheckedField, $FlipCheckedValue, $Attributes = '') {
      $FlipCheckedValue = ForceBool($FlipCheckedValue, 0);
		while ($rows = $Database->GetRow($DataSet)) {
			$this->AddOption($rows[$IdField], $rows[$DisplayField], $rows[$CheckedField], $FlipCheckedValue, $Attributes);
		}	
	}	
	
	function Checkbox() {
		$this->Clear();
	}
	
	function Clear() {
		$this->Name = '';
		$this->aOptions = array();
	}
	
	function ClearOptions() {
		$this->aOptions = array();
	}
	
	function Count() {
		return count($this->aOptions);
	}
	
	function Get() {
		$sReturn = '';
		$OptionCount = count($this->aOptions);
		for ($i = 0; $i < $OptionCount ; $i++) {
		   $sReturn .= '<label>'
				.GetBasicCheckBox($this->Name,
					$this->aOptions[$i]['IdValue'],
					$this->aOptions[$i]['Checked'],
					$this->aOptions[$i]['Attributes'])
				.' '
				.$this->aOptions[$i]['DisplayValue']
				.'</label>';
		}
		return $sReturn;
	}
	
	function Write() {
		echo($this->Get());
	}	
}
?>