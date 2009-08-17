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
* Description: Manage major errors resulting in page not functioning properly.
* Applications utilizing this file: Vanilla;
*/
class Error {
	var $AffectedElement;	// The element (class) that has encountered the error
	var $AffectedFunction;	// The function or method that has encountered the error
	var $Message;				// Actual error message
	var $Code;					// Any related code to help identify the error
}

class ErrorManager {
	// Public Variables
	var $StyleSheet;		// A custom stylesheet may be supplied for the error display
	
	// Public, Read Only Variables
	var $ErrorCount;		// Number of errors encountered

	// Private Variables
	var $Errors;			// Collection of error objects
	
	function AddError(&$Context, $AffectedElement, $AffectedFunction, $Message, $Code = "", $WriteAndKill = 1) {
		if ($Context) {
			$Error = $Context->ObjectFactory->NewObject($Context, "Error");
		} else {
			$Error = new Error();
		}
		$Error->AffectedElement = $AffectedElement;
		$Error->AffectedFunction = $AffectedFunction;
		$Error->Message = $Message;
		$Error->Code = $Code;
		$this->Errors[] = $Error;
		$this->ErrorCount += 1;	
		if ($WriteAndKill == 1) $this->Write($Context);
	}
	
	function Clear() {
		$this->ErrorCount = 0;
		$this->Errors = array();
	}
	
	function ErrorManager() {
		$this->Clear();
	}
	
	function Iif($True = "1", $False = "0") {
		if ($this->ErrorCount == 0) {
			return $True;
		} else {
			return $False;			
		}
	}	
	
	function Write(&$Context) {
		
		@include(ThemeFilePath($this->Context->Configuration, 'fatal_error.php'));
		// Cleanup
		if ($Context) $Context->Unload();
		die();
	}
	function GetSimple() {
		$sReturn = "";
		$ErrorCount = count($this->Errors);
		for ($i = 0; $i < $ErrorCount; $i++) {
			$sReturn .= ForceString($this->Errors[$i]->Message, "No error message supplied\r\n");
		}
		return $sReturn;
	}
}
?>