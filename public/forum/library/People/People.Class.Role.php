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
* Description: Container for role properties.
*/
class Role extends Delegation {
	var $RoleID;
	var $RoleName;
	var $Icon;
	var $Description;
	var $Permissions;
	var $PERMISSION_SIGN_IN;
	var $PERMISSION_HTML_ALLOWED;
	var $PERMISSION_RECEIVE_APPLICATION_NOTIFICATION;
	var $Unauthenticated;
	
	function Clear() {
		$this->RoleID = 0;
		$this->RoleName = '';
		$this->Icon = '';
		$this->Description = '';
		$this->PERMISSION_SIGN_IN = 0;
		$this->PERMISSION_HTML_ALLOWED = 0;
		$this->PERMISSION_RECEIVE_APPLICATION_NOTIFICATION = 0;
		$this->Permissions = array();
		$this->Unauthenticated = 0;

		// Loop through the configuration array looking for permission declarations
		while (list($ConfigurationKey, $ConfigurationValue) = each($this->Context->Configuration)) {
			if (substr($ConfigurationKey, 0, 11) == 'PERMISSION_') {
				$this->AddPermission($ConfigurationKey);
			}
		}
		
		// Call a delegate here so that others can add new role permissions
		$this->CallDelegate('DefineRolePermissions');            
	}
	
	function FormatPropertiesForDatabaseInput() {
		$this->RoleName = FormatStringForDatabaseInput($this->RoleName, 1);
		$this->Icon = FormatStringForDatabaseInput($this->Icon, 1);
		$this->Description = FormatStringForDatabaseInput($this->Description, 1);
      if (is_array($this->Permissions)) {
			// Make sure to remove the hard-coded permissions from the array before saving
			if (array_key_exists('PERMISSION_SIGN_IN', $this->Permissions)) unset($this->Permissions['PERMISSION_SIGN_IN']);
			if (array_key_exists('PERMISSION_HTML_ALLOWED', $this->Permissions)) unset($this->Permissions['PERMISSION_HTML_ALLOWED']);
			if (array_key_exists('PERMISSION_RECEIVE_APPLICATION_NOTIFICATION', $this->Permissions)) unset($this->Permissions['PERMISSION_RECEIVE_APPLICATION_NOTIFICATION']);
			// Now serialize the array
			$this->Permissions = SerializeArray($this->Permissions);
		}
	}
	
	function FormatPropertiesForDisplay() {
		$this->RoleName = FormatStringForDisplay($this->RoleName, 0);
		$this->Description = FormatStringForDisplay($this->Description, 0);
	}
	
	function GetPropertiesFromDataSet($DataSet) {
		$this->RoleID = ForceInt(@$DataSet['RoleID'], 0);
		$this->RoleName = ForceString(@$DataSet['Name'],'');
		$this->Icon = ForceString(@$DataSet['Icon'],'');
		$this->Description = ForceString(@$DataSet['Description'],'');
		$this->PERMISSION_SIGN_IN = ForceBool(@$DataSet['PERMISSION_SIGN_IN'], 0);
		$this->PERMISSION_HTML_ALLOWED = ForceBool(@$DataSet['PERMISSION_HTML_ALLOWED'], 0);
		$this->PERMISSION_RECEIVE_APPLICATION_NOTIFICATION = ForceBool(@$DataSet['PERMISSION_RECEIVE_APPLICATION_NOTIFICATION'], 0);
		$this->Unauthenticated = ForceBool(@$DataSet['Unauthenticated'], 0);
		$TempPermissions = '';
		$TempPermissions = ForceString(@$DataSet['Permissions'], '');
		$TempPermissions = UnserializeAssociativeArray($TempPermissions);
		$this->Permissions['PERMISSION_SIGN_IN'] = $this->PERMISSION_SIGN_IN;
		$this->Permissions['PERMISSION_HTML_ALLOWED'] = $this->PERMISSION_HTML_ALLOWED;
		$this->Permissions['PERMISSION_RECEIVE_APPLICATION_NOTIFICATION'] = $this->PERMISSION_RECEIVE_APPLICATION_NOTIFICATION;
		while (list($TempKey, $TempValue) = each($TempPermissions)) {
			$this->Permissions[$TempKey] = $TempValue;
		}
		unset($TempPermissions);
	}
	
	function GetPropertiesFromForm($Configuration) {
		$this->RoleID = ForceIncomingInt('RoleID', 0);
		$this->RoleName = ForceIncomingString('RoleName', '');
		$this->Icon = ForceIncomingString('Icon', '');
		$this->Description = ForceIncomingString('Description', '');
		$this->Unauthenticated = ForceIncomingBool('Unauthenticated', 0);
		$this->PERMISSION_SIGN_IN = ForceIncomingBool('PERMISSION_SIGN_IN', 0);
		$this->PERMISSION_HTML_ALLOWED = ForceIncomingBool('PERMISSION_HTML_ALLOWED', 0);
		$this->PERMISSION_RECEIVE_APPLICATION_NOTIFICATION = ForceIncomingBool('PERMISSION_RECEIVE_APPLICATION_NOTIFICATION', 0);
		while (list($Key, $Permission) = each($this->Permissions)) {
			$this->Permissions[$Key] = ForceIncomingBool($Key, 0);
		}
	}
	
	function AddPermission($PermissionKey) {
		if (!array_key_exists($PermissionKey, $this->Permissions)) {
			$this->Permissions[$PermissionKey] = $this->Context->Configuration[$PermissionKey];
		}
	}
	
	function Role(&$Context) {
		$this->Name = 'Role';
		$this->Delegation($Context);
		$this->Clear();
	}
}
?>