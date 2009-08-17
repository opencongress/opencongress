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
* Description: Category class
*/

class Category {
	var $CategoryID;
	var $Name;
	var $Description;
	var $Blocked; // Is this category blocked by the viewing user
	var $RoleBlocked; // Is this category blocked to the role of the viewing user
	var $AllowedRoles; // Contains the roles that are allowed to take part in this category
	var $DiscussionCount; // aggregate - display only
	
	function Category() {
		$this->Clear();
	}
	
	// Clears all properties
	function Clear() {
		$this->CategoryID = 0;
		$this->Name = '';
		$this->Description = '';
		$this->DiscussionCount = 0;
		$this->Blocked = 0;
		$this->RoleBlocked = 0;
		$this->AllowedRoles = array();
	}

	function FormatPropertiesForDatabaseInput() {
		$this->Name = FormatStringForDatabaseInput($this->Name, 1);
		$this->Description = FormatStringForDatabaseInput($this->Description, 1);
	}
	
	function FormatPropertiesForDisplay() {
		$this->Name = FormatStringForDisplay($this->Name, 1);
		$this->Description = FormatStringForDisplay($this->Description, 1);
	}
	
	function GetPropertiesFromDataSet($DataSet) {
		$this->CategoryID = ForceInt(@$DataSet['CategoryID'], 0);
		$this->Name = ForceString(@$DataSet['Name'], '');
		$this->Description = ForceString(@$DataSet['Description'], '');
		$this->DiscussionCount = ForceInt(@$DataSet['DiscussionCount'], 0);
		$this->Blocked = ForceBool(@$DataSet['Blocked'], 0);
		$this->RoleBlocked = ForceBool(@$DataSet['RoleBlocked'], 0);
	}	

	function GetPropertiesFromForm(&$Context) {
		$this->CategoryID = ForceIncomingInt('CategoryID', 0);
		$this->Name = ForceIncomingString('Name', '');
		$this->Description = ForceIncomingString('Description', '');
		$this->AllowedRoles = ForceIncomingArray('CategoryRoleBlock', array());
	}
}
?>