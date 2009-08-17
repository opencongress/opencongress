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
* Description: The AccountRoleForm control allows administrators to alter a user's role in Vanilla.
*/

class AccountRoleForm extends PostBackControl {
	var $User;
	var $RoleSelect;
	
	function AccountRoleForm (&$Context, &$UserManager, $User) {
		$this->Name = 'AccountRoleForm';
		$this->ValidActions = array('ApproveUser', 'DeclineUser', 'Role', 'ProcessRole');
		$this->Constructor($Context);
		if ($this->IsPostBack) {
			$this->User = &$User;
			$Redirect = 0;
			if ($this->PostBackAction == 'ProcessRole' && $this->IsValidFormPostBack() && $this->Context->Session->UserID != $User->UserID && $this->Context->Session->User->Permission('PERMISSION_CHANGE_USER_ROLE')) {
				$urh = $this->Context->ObjectFactory->NewObject($this->Context, 'UserRoleHistory');
				$urh->GetPropertiesFromForm();
				if ($UserManager->AssignRole($urh)) $Redirect = 1;
			}
			
			if ($Redirect) {
				header('location: '.GetUrl($this->Context->Configuration, $this->Context->SelfUrl, '', 'u', $User->UserID));
				die();
			} else {
				$this->PostBackAction = str_replace('Process', '', $this->PostBackAction);
			}
			
			if ($this->PostBackAction == 'Role') {
				$RoleManager = $this->Context->ObjectFactory->NewContextObject($this->Context, 'RoleManager');
				$RoleData = $RoleManager->GetRoles();

				$this->RoleSelect = $this->Context->ObjectFactory->NewObject($this->Context, 'Select');
				$this->RoleSelect->Name = 'RoleID';
				$this->RoleSelect->CssClass = 'PanelInput';
				$this->RoleSelect->AddOptionsFromDataSet($this->Context->Database, $RoleData, 'RoleID', 'Name');
				$this->RoleSelect->SelectedValue = $this->User->RoleID;
				$this->RoleSelect->Attributes = ' id="ddRoleID"';
			}
		}
		$this->CallDelegate('Constructor');
	}
	
	function Render() {
		if ($this->PostBackAction == 'Role') {
			$this->CallDelegate('PreRender');
			include(ThemeFilePath($this->Context->Configuration, 'account_role_form.php'));
			$this->CallDelegate('PostRender');
		}
	}
}
?>