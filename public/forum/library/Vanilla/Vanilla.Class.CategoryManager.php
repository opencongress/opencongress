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
* Description: Category management class
*/

class CategoryManager {
	var $Name;				// The name of this class
   var $Context;			// The context object that contains all global objects (database, error manager, warning collector, session, etc)
	
	function CategoryManager(&$Context) {
		$this->Name = 'CategoryManager';
		$this->Context = &$Context;
	}
	
	function GetCategories($IncludeCount = '0', $OrderByPreference = '0', $ForceRoleBlock = '1') {
		$OrderByPreference = ForceBool($OrderByPreference, 0);
		$s = $this->GetCategoryBuilder($IncludeCount, $ForceRoleBlock);
		if ($OrderByPreference && $this->Context->Session->UserID > 0) {
			// Order by the user's preference (unblocked categories first)
			$s->AddOrderBy('Blocked', 'b', 'asc');
		}
		$s->AddOrderBy('Priority', 'c', 'asc');
		return $this->Context->Database->Select($s, $this->Name, 'GetCategories', 'An error occurred while retrieving categories.');
	}
	
	function GetCategoryBuilder($IncludeCount = '0', $ForceRoleBlock = '1') {
		
		$IncludeCount = ForceBool($IncludeCount, 0);
		$s = $this->Context->ObjectFactory->NewContextObject($this->Context, 'SqlBuilder');
		$s->SetMainTable('Category', 'c');
		if ($IncludeCount) {
			if ($this->Context->Session->User->Permission('PERMISSION_REMOVE_CATEGORIES') && $this->Context->Session->User->Preference('ShowDeletedDiscussions')) {
				$s->AddJoin('Discussion', 'd', 'CategoryID', 'c', 'CategoryID', 'left join');
			} else {
				$s->AddJoin('Discussion', 'd', 'CategoryID', 'c', 'CategoryID', 'left join', " and d.".$this->Context->DatabaseColumns['Discussion']['Active']." = 1");
			}
			$s->AddSelect('DiscussionID', 'd', 'DiscussionCount', 'count');
		}
		$s->AddSelect(array('CategoryID', 'Name', 'Description'), 'c', '', '', '', 1);
		
		$BlockCategoriesByRole = 1;
		if ($this->Context->Session->User->Permission('PERMISSION_ADD_CATEGORIES')
			|| $this->Context->Session->User->Permission('PERMISSION_EDIT_CATEGORIES')
			|| $this->Context->Session->User->Permission('PERMISSION_REMOVE_CATEGORIES')) {
				$BlockCategoriesByRole = 0;
		}
		if ($ForceRoleBlock) $BlockCategoriesByRole = 1;
		
		if ($this->Context->Session->UserID > 0) {
			$s->AddJoin('CategoryRoleBlock', 'crb', 'CategoryID', 'c', 'CategoryID', 'left join', ' and crb.'.$this->Context->DatabaseColumns['CategoryRoleBlock']['RoleID'].' = '.$this->Context->Session->User->RoleID);
			$s->AddJoin('CategoryBlock', 'b', 'CategoryID', 'c', 'CategoryID', 'left join', ' and b.'.$this->Context->DatabaseColumns['CategoryBlock']['UserID'].' = '.$this->Context->Session->UserID);
			$s->AddSelect('Blocked', 'b', 'Blocked', 'coalesce', '0');
		} else {
			$s->AddJoin('CategoryRoleBlock', 'crb', 'CategoryID', 'c', 'CategoryID', 'left join', ' and crb.'.$this->Context->DatabaseColumns['CategoryRoleBlock']['RoleID'].' = 1');
		}
		
		// Limit to categories that this user is allowed to see.
		if ($BlockCategoriesByRole) {
			$s->AddWhere('crb', 'Blocked', '', 0, '=', 'and', '', 1, 1);
			$s->AddWhere('crb', 'Blocked', '', 0, '=', 'or', '', 0);
			$s->AddWhere('crb', 'Blocked', '', 'null', 'is', 'or', '', 0);
			$s->EndWhereGroup();
		} else {
			// Identify which of these categories is blocked by role
         // (so administrators can easily see what they do and don't have access to)
			$s->AddSelect('Blocked', 'crb', 'RoleBlocked', 'coalesce', '0');
		}
		
		return $s;
	}

	function GetCategoryById($CategoryID) {
		$Category = $this->Context->ObjectFactory->NewObject($this->Context, 'Category');
		$s = $this->GetCategoryBuilder(0, 0);
		$s->AddWhere('c', 'CategoryID', '', $CategoryID, '=');
		$ResultSet = $this->Context->Database->Select($s, $this->Name, 'GetCategoryById', 'An error occurred while attempting to retrieve the requested category.');
		if ($this->Context->Database->RowCount($ResultSet) == 0) $this->Context->WarningCollector->Add($this->Context->GetDefinition('ErrCategoryNotFound'));
		while ($rows = $this->Context->Database->GetRow($ResultSet)) {
			$Category->GetPropertiesFromDataSet($rows);
		}
		return $this->Context->WarningCollector->Iif($Category, false);
	}
	
	function GetCategoryRoleBlocks($CategoryID = '0') {
		$s = $this->Context->ObjectFactory->NewContextObject($this->Context, 'SqlBuilder');
		$s->SetMainTable('Role', 'r');
		$s->AddJoin('CategoryRoleBlock', 'crb', 'RoleID', 'r', 'RoleID', 'left join', ' and crb.'.$this->Context->DatabaseColumns['CategoryRoleBlock']['CategoryID'].' = '.$CategoryID);
		$s->AddSelect(array('RoleID', 'Name'), 'r');
		$s->AddSelect('Blocked', 'crb', 'Blocked', 'coalesce', '0');
		$s->AddWhere('r', 'Active', '', '1', '=');
		$s->AddOrderBy('Priority', 'r', 'asc');
		return $this->Context->Database->Select($s, $this->Name, 'GetCategoryRoleBlocks', 'An error occurred while retrieving category role blocks.');
	}
		
	function RemoveCategory($RemoveCategoryID, $ReplacementCategoryID) {
		$ReplacementCategoryID = ForceInt($ReplacementCategoryID, 0);
		if ($ReplacementCategoryID <= 0) {
			$this->Context->WarningCollector->Add($this->Context->GetDefinition('ErrCategoryReplacement'));
			return false;
		}
		// Reassign the user-assigned categorizations
		$s = $this->Context->ObjectFactory->NewContextObject($this->Context, 'SqlBuilder');
		$s->SetMainTable('Discussion', 'd');
		$s->AddFieldNameValue('CategoryID', $ReplacementCategoryID);
		$s->AddWhere('d', 'CategoryID', '', $RemoveCategoryID, '=');
		$this->Context->Database->Update($s, $this->Name, 'RemoveCategory', 'An error occurred while attempting to re-assign user categorizations.');
		
		// remove user blocks
		$s->Clear();
		$s->SetMainTable('CategoryBlock', 'b');
		$s->AddWhere('b', 'CategoryID', '', $RemoveCategoryID, '=');
		$this->Context->Database->Delete($s, $this->Name, 'RemoveCategory', 'An error occurred while attempting to remove user-assigned blocks on the selected category.');
		
		// Now remove the category itself
      $s->Clear();
		$s->SetMainTable('Category', 'c');
		$s->AddWhere('c', 'CategoryID', '', $RemoveCategoryID, '=');
		$this->Context->Database->Delete($s, $this->Name, 'RemoveCategory', 'An error occurred while attempting to remove the category.');
		return true;
	}
	
	function SaveCategory(&$Category) {
		// Validate the properties
		if($this->ValidateCategory($Category)) {
			$s = $this->Context->ObjectFactory->NewContextObject($this->Context, 'SqlBuilder');
			$s->SetMainTable('Category', 'c');
			$s->AddFieldNameValue('Name', $Category->Name);
			$s->AddFieldNameValue('Description', $Category->Description);
			
			// If creating a new object
			if ($Category->CategoryID == 0) {
				$Category->CategoryID = $this->Context->Database->Insert($s, $this->Name, 'SaveCategory', 'An error occurred while creating a new category.');
			} else 	{
				$s->AddWhere('c', 'CategoryID', '', $Category->CategoryID, '=');
				$this->Context->Database->Update($s, $this->Name, 'SaveCategory', 'An error occurred while attempting to update the category.');
			}
			
			// Now update the blocked roles
         $s->Clear();
			$s->SetMainTable('CategoryRoleBlock', 'crb');
			$s->AddWhere('crb', 'CategoryID', '', $Category->CategoryID, '=');
			$this->Context->Database->Delete($s, $this->Name, 'SaveCategory', 'An error occurred while removing old role block definitions for this category.');
			
			$Category->AllowedRoles[] = 0;
			
			$s->Clear();
			$s->SetMainTable('Role', 'r');
			$s->AddSelect('RoleID', 'r');
			$s->AddWhere('r', 'Active', '', 1, '=');
			$s->AddWhere('r', 'RoleID', '', '('.implode(',',$Category->AllowedRoles).')', 'not in', 'and', '', 0);
			$BlockedRoles = $this->Context->Database->Select($s, $this->Name, 'SaveCategory', 'An error occurred while retrieving blocked roles.');
			
			while ($Row = $this->Context->Database->GetRow($BlockedRoles)) {
				$RoleID = ForceInt($Row['RoleID'], 0);
				if ($RoleID > 0) {
					$s->Clear();
					$s->SetMainTable('CategoryRoleBlock', 'crb');
					$s->AddFieldNameValue('CategoryID', $Category->CategoryID);
					$s->AddFieldNameValue('RoleID', $RoleID);
					$s->AddFieldNameValue('Blocked', 1);
					$this->Context->Database->Insert($s, $this->Name, 'SaveCategory', 'An error occurred while adding new role block definitions for this category.');
				}
			}
		}
		return $this->Context->WarningCollector->Iif($Category, false);
	}
	
	function SaveCategoryOrder() {
		$s = $this->Context->ObjectFactory->NewContextObject($this->Context, 'SqlBuilder');
		$ItemCount = ForceIncomingInt('SortItemCount', 0) + 1;
		for ($i = 1; $i < $ItemCount; $i++) {
			$CategoryID = ForceIncomingInt('Sort_'.$i, 0);
			if ($CategoryID > 0) {
				$s->Clear();
				$s->SetMainTable('Category', 'c');
				$s->AddFieldNameValue('Priority', $i);
				$s->AddWhere('c', 'CategoryID', '', $CategoryID, '=');
				$this->Context->Database->Update($s, $this->Name, 'SaveCategoryOrder', 'An error occurred while attempting to update the category sort order.', 0);
			}
		}
	}

	// Validates and formats properties ensuring they're safe for database input
	// Returns: boolean value indicating success
	function ValidateCategory(&$Category) {
		// First update the values so they are safe for db input
		$ValidatedCategory = $Category;
		$ValidatedCategory->FormatPropertiesForDatabaseInput();

		// Instantiate a new validator for each field
		Validate($this->Context->GetDefinition('CategoryNameLower'), 1, $ValidatedCategory->Name, 100, '', $this->Context);
	
		// If validation was successful, then reset the properties to db safe values for saving
		if ($this->Context->WarningCollector->Count() == 0) $Category = $ValidatedCategory;
		
		return $this->Context->WarningCollector->Iif();
	}
}
?>