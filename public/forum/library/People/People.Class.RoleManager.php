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
* Description: role management class.
*/

class RoleManager {
	var $Name;					// The name of this class
   var $Context;				// The context object that contains all global objects (database, error manager, warning collector, session, etc)
	
	// Returns a SqlBuilder object with all of the user properties already defined in the select
	function GetRoleBuilder($GetUnauthenticated = '0') {
		$s = $this->Context->ObjectFactory->NewContextObject($this->Context, 'SqlBuilder');
		$s->SetMainTable('Role', 'r');
		$s->AddSelect(array('RoleID', 'Name', 'Icon', 'Description', 'PERMISSION_SIGN_IN', 'PERMISSION_RECEIVE_APPLICATION_NOTIFICATION', 'PERMISSION_HTML_ALLOWED', 'Permissions', 'Unauthenticated'), 'r');
		$s->AddWhere('r', 'Active', '', '1', '=');
		if (!$GetUnauthenticated) $s->AddWhere('r', 'Unauthenticated', '', '0', '=');
		return $s;
	}
	
	function GetRoleById($RoleID) {
		$s = $this->GetRoleBuilder(1);
		$s->AddWhere('r', 'RoleID', '', $RoleID, '=');

		$Role = $this->Context->ObjectFactory->NewContextObject($this->Context, 'Role');
		$result = $this->Context->Database->Select($s, $this->Name, 'GetRoleById', 'An error occurred while attempting to retrieve the requested role.');
		if ($this->Context->Database->RowCount($result) == 0) $this->Context->WarningCollector->Add($this->Context->GetDefinition('ErrRoleNotFound'));
		while ($rows = $this->Context->Database->GetRow($result)) {
			$Role->GetPropertiesFromDataSet($rows);
		}
		return $this->Context->WarningCollector->Iif($Role, false);
	}
	
	function GetRoles($RoleToExclude = '0', $GetUnauthenticated = '0') {
		$RoleToExclude = ForceInt($RoleToExclude, 0);
		$s = $this->GetRoleBuilder($GetUnauthenticated);
		$s->AddOrderBy('Priority', 'r', 'asc');
		$s->AddWhere('r', 'RoleID', '', $RoleToExclude, '<>');
		return $this->Context->Database->Select($s, $this->Name, 'GetRoles', 'An error occurred while attempting to retrieve roles.');
	}
	
	function RemoveRole($RemoveRoleID, $ReplacementRoleID) {
		$s = $this->Context->ObjectFactory->NewContextObject($this->Context, 'SqlBuilder');
		$s->SetMainTable('User', 'u');
		$s->AddSelect('UserID', 'u');
		$s->AddJoin('Role', 'r', 'RoleID', 'u', 'RoleID', 'inner join');
		$s->AddWhere('u', 'RoleID', '', $RemoveRoleID, '=');
		$s->AddWhere('r', 'Unauthenticated', '', '0', '=');
		$OldRoleUsers = $this->Context->Database->Select($s, $this->Name, 'RemoveRole', 'An error occurred while attempting to remove the role.');
		
		if ($this->Context->Database->RowCount($OldRoleUsers) > 0) {
			$um = $this->Context->ObjectFactory->NewContextObject($this->Context, 'UserManager');
			// Reset the role for all of the affected users
         $urh = $this->Context->ObjectFactory->NewObject($this->Context, 'UserRoleHistory');
			$urh->RoleID = $ReplacementRoleID;
			$urh->AdminUserID = $this->Context->Session->UserID;
			$urh->Notes = "The user's previous role has been made obselete.";
			while ($row = $this->Context->Database->GetRow($OldRoleUsers)) {
				$urh->UserID = ForceInt($row['UserID'], 0);
				$um->AssignRole($urh);
			}
		}		
		
		$s->Clear();
		$s->SetMainTable('Role', 'r');
		$s->AddFieldNameValue('Active', '0');
		$s->AddWhere('r', 'RoleID', '', $RemoveRoleID, '=');
		$this->Context->Database->Update($s, $this->Name, 'RemoveRole', 'An error occurred while attempting to remove the role.');
		return 1;
	}
	
	function RoleManager(&$Context) {
		$this->Name = 'RoleManager';
		$this->Context = &$Context;
	}	

	function SaveRole(&$Role) {
		// Ensure that the person performing this action has access to do so
		if (($Role->RoleID > 0 && !$this->Context->Session->User->Permission('PERMISSION_EDIT_ROLES'))
			|| ($Role->RoleID == 0 && !$this->Context->Session->User->Permission('PERMISSION_ADD_ROLES'))) $this->Context->WarningCollector->Add($this->Context->GetDefinition('ErrPermissionInsufficient'));
		
		if ($this->Context->WarningCollector->Count() == 0) {
			// In order to make sure we don't overwrite permissions from other applications,
			// we should reload the current permissions first
			if ($Role->RoleID > 0) {
				$TempRole = $this->GetRoleById($Role->RoleID);
				while (list($Permission, $Value) = each($TempRole->Permissions)) {
					if ($Permission != 'PERMISSION_SIGN_IN'
						&& $Permission != 'PERMISSION_HTML_ALLOWED'
						&& $Permission != 'PERMISSION_RECEIVE_APPLICATION_NOTIFICATION'
						&& !array_key_exists($Permission, $Role->Permissions)) {
						$Role->Permissions[$Permission] = $Value;
					}
				}
			}            
			
			// Validate the properties
			if ($this->ValidateRole($Role)) {				
				$s = $this->Context->ObjectFactory->NewContextObject($this->Context, 'SqlBuilder');
				$s->SetMainTable('Role', 'r');
				$s->AddFieldNameValue('Name', $Role->RoleName);
				$s->AddFieldNameValue('Icon', $Role->Icon);
				$s->AddFieldNameValue('Description', $Role->Description);
				$s->AddFieldNameValue('PERMISSION_SIGN_IN', $Role->PERMISSION_SIGN_IN);
				$s->AddFieldNameValue('PERMISSION_HTML_ALLOWED', $Role->PERMISSION_HTML_ALLOWED);
				$s->AddFieldNameValue('PERMISSION_RECEIVE_APPLICATION_NOTIFICATION', $Role->PERMISSION_RECEIVE_APPLICATION_NOTIFICATION);
				$s->AddFieldNameValue('Permissions', $Role->Permissions);
				if ($Role->RoleID > 0) {
					$s->AddWhere('r', 'RoleID', '', $Role->RoleID, '=');
					$this->Context->Database->Update($s, $this->Name, 'SaveRole', 'An error occurred while attempting to update the role.');
				} else {
					$Role->RoleID = $this->Context->Database->Insert($s, $this->Name, 'SaveRole', 'An error occurred while creating a new role.');
				}
			}
		}
		return $this->Context->WarningCollector->Iif($Role, false);
	}
	
	
	// Validates and formats Role properties ensuring they're safe for database input
	// Returns: boolean value indicating success
	function ValidateRole(&$Role) {
		$ValidatedRole = $Role;
		$ValidatedRole->FormatPropertiesForDatabaseInput();
		
		Validate($this->Context->GetDefinition('RoleNameLower'), 1, $ValidatedRole->RoleName, 100, '', $this->Context);
		
		// If validation was successful, then reset the properties to db safe values for saving
		if ($this->Context->WarningCollector->Count() == 0) $Role = $ValidatedRole;
		
		return $this->Context->WarningCollector->Iif();
	}
}
?>