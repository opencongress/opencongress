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
* Description: The Account control displays user account information in Vanilla.
*/

// Displays a user's account information
class Account extends Control {
	var $User;	// The user object to be displayed
   var $FatalError; // Boolean value indicating if there were any fatal errors before any delegates were reached (ie, a fatal error in the core code).
   
	function Account(&$Context, &$User) {
		$this->FatalError = 0;
		$this->Name = 'Account';
		$this->PostBackAction = ForceIncomingString('PostBackAction', '');
		$this->Control($Context);
		$this->User = &$User;
		if ($this->Context->WarningCollector->Count() > 0) $this->FatalError = 1;
		$this->CallDelegate('Constructor');
	}
	
	function Render() {
		$this->CallDelegate('PreRender');
		// Don't render anything but warnings if there are any warnings or if there is a postback
      if ($this->PostBackAction == '') {
			if ($this->FatalError) {
				echo($this->Get_Warnings());
			} else {
				$this->User->FormatPropertiesForDisplay();
				include(ThemeFilePath($this->Context->Configuration, 'account_profile.php'));
			}
		}
		$this->CallDelegate('PostRender');
	}
}
?>