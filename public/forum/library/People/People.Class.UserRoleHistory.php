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
* Description: Container for an instance in a user's role history.
*/

class UserRoleHistory {
	var $UserID;
	var $Username;
	var $FullName;
	var $RoleID;
	var $Role;
	var $RoleDescription;
	var $RoleIcon;
	var $AdminUserID;
	var $AdminUsername;
	var $AdminFullName;
	var $Notes;
	var $Date;
	
	function Clear() {
		$this->UserID = 0;
		$this->Username = '';
		$this->FullName = '';
		$this->RoleID = 0;
		$this->Role = '';
		$this->RoleDescription = '';
		$this->RoleIcon = '';
		$this->AdminUserID = 0;
		$this->AdminUsername = '';
		$this->AdminFullName = '';
		$this->Notes = '';
		$this->Date = '';
	}
	
	function FormatPropertiesForDisplay(&$Context) {
		$this->Username = FormatStringForDisplay($this->Username, 0);
		$this->FullName = FormatStringForDisplay($this->FullName, 0);
		$this->AdminUsername = FormatStringForDisplay($this->AdminUsername, 0);
		$this->AdminFullName = FormatStringForDisplay($this->AdminFullName, 0);
		$AdminUser = $Context->ObjectFactory->NewContextObject($Context, 'Comment');
		$AdminUser->Clear();
		$AdminUser->AuthUsername = $this->AdminUsername;
		$AdminUser->AuthUserID = $this->AdminUserID;
		$this->Notes = $Context->FormatString($this->Notes, $AdminUser, 'Text', FORMAT_STRING_FOR_DISPLAY);
	}
	
	function GetPropertiesFromDataSet($DataSet) {
		$this->UserID = ForceInt(@$DataSet['UserID'],0);
		$this->Username = ForceString(@$DataSet['Username'],'');
		$this->FullName = ForceString(@$DataSet['FullName'],'');
		$this->RoleID = ForceInt(@$DataSet['RoleID'],0);
		$this->Role = ForceString(@$DataSet['Role'],'');
		$this->RoleDescription = ForceString(@$DataSet['RoleDescription'],'');
		$this->RoleIcon = ForceString(@$DataSet['RoleIcon'],'');
		$this->AdminUserID = ForceInt(@$DataSet['AdminUserID'],0);
		$this->AdminUsername = ForceString(@$DataSet['AdminUsername'],'');
		$this->AdminFullName =ForceString(@$DataSet['AdminFullName'],'');
		$this->Notes = ForceString(@$DataSet['Notes'],'');
		$this->Date = UnixTimestamp(@$DataSet['Date']);
	}
	
	function GetPropertiesFromForm() {
		$this->UserID = ForceIncomingInt('u', 0);
		$this->RoleID = ForceIncomingInt('RoleID', 0);
		$this->Notes = ForceIncomingString('Notes', '');
	}
}
?>