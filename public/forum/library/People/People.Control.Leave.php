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
* Description: The Leave control is used to sign a user out of an application and present them with a "good bye" screen.
*/

class Leave extends PostBackControl {
	
	function Leave(&$Context) {
		$this->Name = 'Leave';
		$this->ValidActions = array('SignOutNow', 'SignOut');
		$this->Constructor($Context);
		
		if ($this->IsPostBack) {
			// Set up the page
			global $Banner, $Foot;
			$Banner->Properties['CssClass'] = 'SignOut';
			$Foot->CssClass = 'SignOut';
			$this->Context->PageTitle = $this->Context->GetDefinition('SignOut');		
	
			// Occassionally cookies cannot be removed, and rather than
			// cause an infinite loop where the page continually refreshes
			// until it crashes (attempting to remove the cookies over and
			// over again), I just fail out and treat the user as if s/he
			// has been signed out successfully.
			if ($this->PostBackAction == 'SignOutNow') {
				$this->Context->Session->End($this->Context->Authenticator);
			}
			$this->PostBackValidated = 1;
		}
	}
	
	function Render_ValidPostBack() {
		$this->CallDelegate('PreValidPostBackRender');
		include(ThemeFilePath($this->Context->Configuration, 'people_signout_form_validpostback.php'));
		$this->CallDelegate('PostValidPostBackRender');
	}
	
	function Render_NoPostBack() {
		$this->CallDelegate('PreNoPostBackRender');
		include(ThemeFilePath($this->Context->Configuration, 'people_signout_form_validpostback.php'));
		$this->CallDelegate('PostNoPostBackRender');
	}
}
?>