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
* Description: A class that defines how delegation works
* Applications utilizing this file: Vanilla;
*/

// A standard control
class Delegation {

   var $Context;           // Request context (for global context objects)
   var $Name;              // The name of this control
   
	// Private
   var $Delegates;			// An array of delegates & their associated functions
   var $DelegateParameters;// An associative array of Variable => Values that is used to allow delegate functions to change local, method-level variable values
   
	// Adds a function to the specified delegate
	function AddToDelegate($DelegateName, $FunctionName) {
		if (!array_key_exists($DelegateName, $this->Delegates)) $this->Delegates[$DelegateName] = array();
		$this->Delegates[$DelegateName][] = $FunctionName;			
	}
	
	// Executes all functions associated with the specified delegate
	function CallDelegate($DelegateName) {
		if (array_key_exists($DelegateName, $this->Delegates)) {
			$FunctionCount = count($this->Delegates[$DelegateName]);
			for ($i = 0; $i < $FunctionCount; $i++) {
            $this->Delegates[$DelegateName][$i]($this);
			}
		}
	}
	
   function Delegation(&$Context) {
		$this->Delegates = array();
		$this->DelegateParameters = array();
      $this->Context = &$Context;
		$this->GetDelegatesFromContext();
   }
	
	function GetDelegatesFromContext() {
		// Get delegates from the context object that were added before this object was instantiated
		if (array_key_exists($this->Name, $this->Context->DelegateCollection)) {
			$this->Delegates = array_merge($this->Delegates, $this->Context->DelegateCollection[$this->Name]);
		}
	}
  
}
?>