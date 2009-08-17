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
* Description: The validator class is used to ensure that user-input is valid depending on various criteria
* Applications utilizing this file: Vanilla;
*/
class Validator {
	var $Context;
	var $InputName;
	var $isValid;
	var $isRequired;
	var $ValidationExpression;
	var $ValidationExpressionErrorMessage;
	var $Value;
	var $MaxLength;
	
	function Clear() {
		$this->InputName = 'Input';
		$this->isRequired = 0;
		$this->isValid = 1;
		$this->ValidationExpression = '';
		$this->MaxLength = 0;
		$this->Value = '';
	}

	// Compare the value of this input to the value of another input
	// Operator: [Equal|NotEqual|GreaterThan|GreaterThanEqualTo|LessThan|LessThanEqualTo]
	function CompareTo($InputToCompare, $Operator, $ErrorMessage) {
		switch($Operator) {
			case 'GreaterThan':
				if($InputToCompare->Value <= $this->Value) {
					$this->isValid = 0;
					$this->Context->WarningCollector->Add($ErrorMessage);
				}
				break;
			case 'GreaterThanEqualTo':
				if($InputToCompare->Value < $this->Value) {
					$this->isValid = 0;
					$this->Context->WarningCollector->Add($ErrorMessage);				
				}
				break;
			case 'LessThan':
				if($InputToCompare->Value >= $this->Value) {
					$this->isValid = 0;
					$this->Context->WarningCollector->Add($ErrorMessage);				
				}
				break;
			case 'LessThanEqualTo':
				if($InputToCompare->Value > $this->Value) {
					$this->isValid = 0;
					$this->Context->WarningCollector->Add($ErrorMessage);				
				}
				break;
			case 'NotEqual':
				if($InputToCompare->Value == $this->Value) {
					$this->isValid = 0;
					$this->Context->WarningCollector->Add($ErrorMessage);				
				}
				break;
			default:
				if($InputToCompare->Value != $this->Value) {
					$this->isValid = 0;
					$this->Context->WarningCollector->Add($ErrorMessage);				
				}
				break;
		}
 	}

	// Validate all defined variables
	// Returns boolean value indicating un/successful validation
	function Validate() {
		// If a regexp was supplied, attempt to validate on it (empty strings allowed)
		if($this->ValidationExpression != '' && $this->Value != '') {
			if(!eregi($this->ValidationExpression, $this->Value)) {
				$this->isValid = 0;
				$this->Context->WarningCollector->Add($this->ValidationExpressionErrorMessage);
			}
		}
		// If the value is required, ensure it's not empty
		if($this->isRequired) {
			$ForcedValue = ForceString($this->Value, '');
			if ($ForcedValue == '') {
				$this->isValid = 0;
				$this->Context->WarningCollector->Add(str_replace('//1', $this->InputName, $this->Context->GetDefinition('ErrRequiredInput')));
			}
		}
		// Ensure the value is not too long if maxlength is specified
		if (($this->MaxLength > 0) && (strlen($this->Value) > $this->MaxLength)) {
			$CharsToLong = (strlen($this->Value) - $this->MaxLength);
			$this->isValid = 0;
			$this->Context->WarningCollector->Add(str_replace(array('//1', '//2'),
				array($this->InputName, $CharsToLong),
				$this->Context->GetDefinition('ErrInputLength')));
		}
		return $this->isValid;
	}
	
	function Validator(&$Context) {
		$this->Context = &$Context;
	}
}
?>