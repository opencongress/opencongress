<?php
/*
* Copyright 2003 Mark O'Sullivan
* This file is part of People: The Lussumo User Management System.
* Vanilla is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
* Vanilla is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
* You should have received a copy of the GNU General Public License along with Vanilla; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
* The latest source code for Vanilla is available at www.lussumo.com
* Contact Mark O'Sullivan at mark [at] lussumo [dot] com
* 
* Description: Class that handles user sessions
*/

class PeopleSession {
	var $UserID;			// Unique user identifier
	var $User;				// User object containing properties relevant to session

	// Ensure that there is an active session. 
	// If there isn't an active session, send the user to the SignIn Url
	function Check(&$Context) {
		if (($this->UserID == 0 && !$Context->Configuration['PUBLIC_BROWSING']) || ($this->UserID > 0 && !$this->User->PERMISSION_SIGN_IN)) {
			if ($this->UserID > 0 && !$this->User->PERMISSION_SIGN_IN) $this->End($Context->Authenticator);
			header('location: '.AppendUrlParameters($Context->Configuration['SAFE_REDIRECT'], 'ReturnUrl='.GetRequestUri()));
			die();
		}
	}
	
	// End a session
	function End($Authenticator) {
		$Authenticator->DeAuthenticate();
	}
	
	// Get a session variable
	function GetVariable($Name, $DataType = 'bool') {
		if ($DataType == 'int') {
			return ForceInt(@$_SESSION[$Name], 0);
		} elseif ($DataType == 'bool') {
			return ForceBool(@$_SESSION[$Name], 0);
		} else {
			return ForceString(@$_SESSION[$Name], '');
		}
	}
	
	// Set a session variable
	function SetVariable($Name, $Value) {
		@$_SESSION[$Name] = $Value;		
	}
	
	// Start a session if required username/password exist in the system
	function Start(&$Context, $Authenticator, $UserID = '0') {
		$UserManager = false;

		// If the UserID is not explicitly defined (ie. by some vanilla-based login module),
      // retrieve the authenticated UserID from the Authenticator module.
      $this->UserID = ForceInt($UserID, 0);
      if ($this->UserID == 0) $this->UserID = $Authenticator->GetIdentity();		

		// Now retrieve user information
		if ($this->UserID > 0) {
			$UserManager = $Context->ObjectFactory->NewContextObject($Context, 'UserManager');
			$this->User = $UserManager->GetSessionDataById($this->UserID);
			
			// If the session data retrieval failed for some reason, dump the user
			if (!$this->User) {
				$this->User = $Context->ObjectFactory->NewContextObject($Context, 'User');
				$this->User->Clear();
				$this->UserID = 0;				
			}
		} else {
			$this->User = $Context->ObjectFactory->NewContextObject($Context, 'User');
			$this->User->Clear();
		}
	}
}
?>