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
* Description: Handle a user sign in
*/

class SignInManager {
   var $Context;				// The context object that contains all global objects (database, error manager, warning collector, session, etc)
	var $Username;
	var $Password;
	
	function FormatPropertiesForDatabaseInput() {
		$this->Username = FormatStringForDatabaseInput($this->Username, 1);
		$this->Password = FormatStringForDatabaseInput($this->Password, 1);
	}
	
	function FormatPropertiesForDisplay() {
		$this->Username = FormatStringForDisplay($this->Username, 1);
		$this->Password = '';
	}

	function GetPropertiesFromForm($FormElementPrefix = '') {
		$this->Username = ForceIncomingString($FormElementPrefix.'Username', '');
		$this->Password = ForceIncomingString($FormElementPrefix.'Password', '');
	}
	
	function SignInManager(&$Context) {
		$this->Context = &$Context;
	}
	
	function ValidateCredentials() {
		// Check for an already active session
		if ($this->Context->Session->UserID != 0) {
			return true;
		} else {
			$this->FormatPropertiesForDatabaseInput();
			
			// Attempt to create a new session for the user
			$UserManager = $this->Context->ObjectFactory->NewContextObject($this->Context, 'UserManager');
			return $UserManager->ValidateUserCredentials($this->Username, $this->Password);
		}
	}
}
?>