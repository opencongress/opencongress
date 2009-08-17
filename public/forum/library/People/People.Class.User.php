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
* Description: Container for user properties and a user management class.
*/
class User {
	// Basic User Properties
	var $UserID;
	var $RoleID;
	var $Role;
	var $RoleIcon;
	var $RoleDescription;
	var $StyleID;
	var $Style;
	var $StyleUrl;
	var $CustomStyle;
	var $Name;
	var $FirstName;
	var $LastName;
	var $FullName;
	var $ShowName;
	var $Password;
	var $Email;
	var $UtilizeEmail;
	var $Icon;
	var $Picture;
	var $Attributes;
	var $DateFirstVisit;
	var $DateLastActive;
	var $CountVisit;
	var $CountDiscussions;
	var $CountComments;
	var $RemoteIp;
	var $AgreeToTerms;
	var $ReadTerms;
	var $BlocksCategories;
	var $DefaultFormatType;
	var $Discovery;
	var $DisplayIcon;				// The icon to display for the user. Normally the user-defined icon, but if the user has a role icon it will appear here instead

	// Spam blocking variables
	var $LastDiscussionPost;
	var $DiscussionSpamCheck;
	var $LastCommentPost;
	var $CommentSpamCheck;

	// Access Abilities (relating to the user role)
   var $PERMISSION_SIGN_IN;
	var $PERMISSION_HTML_ALLOWED;
	var $PERMISSION_RECEIVE_APPLICATION_NOTIFICATION;
	var $Permissions; // An array of permissions (similar to the Preferences Property but applicable to all people in a particular role).
	
	// Password Manipulation Properties
	var $OldPassword;
	var $NewPassword;
	var $ConfirmPassword;

	// An associative array of user-defined settings
   var $SendNewApplicantNotifications;
	var $Preferences;
	
	var $Context;
   
	function Clear() {
		$this->UserID = 0;
		$this->RoleID = 0;
		$this->Role = '';
		$this->RoleIcon = '';
		$this->RoleDescription = '';
		$this->StyleID = 0;
		$this->Style = '';
		$this->CustomStyle = '';
		$this->Name = '';
		$this->FirstName = '';
		$this->LastName = '';
		$this->FullName = '';
		$this->ShowName = 1;
		$this->Password = '';
		$this->Email = '';
		$this->UtilizeEmail = 0;
		$this->Icon = '';
		$this->Picture = '';
		$this->Attributes = array();
		$this->DateFirstVisit = '';
		$this->DateLastActive = '';
		$this->CountVisit = 0;
		$this->CountDiscussions = 0;
		$this->CountComments = 0;
		$this->RemoteIp = '';
		$this->AgreeToTerms = 0;
		$this->ReadTerms = 0;
		$this->BlocksCategories = 0;
		if ($this->Context) {
			$this->DefaultFormatType = $this->Context->Configuration['DEFAULT_FORMAT_TYPE'];
			$this->StyleUrl = $this->Context->Configuration['DEFAULT_STYLE'];
		} else {
			global $Configuration;
			$this->DefaultFormatType = $Configuration['DEFAULT_FORMAT_TYPE'];
			$this->StyleUrl = $Configuration['DEFAULT_STYLE'];
		}
		$this->Discovery = '';
		$this->DisplayIcon = '';
		$this->SendNewApplicantNotifications = 0;
		
		$this->Preferences = array();
		
		$this->PERMISSION_SIGN_IN = 1;
		$this->PERMISSION_HTML_ALLOWED = 0;
		$this->PERMISSION_RECEIVE_APPLICATION_NOTIFICATION = 0;
		$this->Permissions = array();
	}
	
	// Customizations are strings stored in the Preferences array
	function Customization($CustomizationName) {
		$CustomizationName = str_replace('CUSTOMIZATION_', '', $CustomizationName);
		if (array_key_exists($CustomizationName, $this->Preferences)) {
			return $this->Preferences[$CustomizationName];
		} else {
			return ForceString(@$this->Context->Configuration['CUSTOMIZATION_'.$CustomizationName], '');
		}
	}
	
	function FormatPropertiesForDatabaseInput() {
		$this->CustomStyle = FormatStringForDatabaseInput($this->CustomStyle, 1);
		$this->Name = FormatStringForDatabaseInput($this->Name, 1);
		$this->FirstName = FormatStringForDatabaseInput($this->FirstName, 1);
		$this->LastName= FormatStringForDatabaseInput($this->LastName, 1);
		$this->Email = FormatStringForDatabaseInput($this->Email, 1);
		$this->Icon = FormatStringForDatabaseInput($this->Icon, 1);
		$this->Picture = FormatStringForDatabaseInput($this->Picture, 1);
		$this->Password = FormatStringForDatabaseInput($this->Password, 1);
		$this->OldPassword = FormatStringForDatabaseInput($this->OldPassword, 1);
		$this->NewPassword = FormatStringForDatabaseInput($this->NewPassword, 1);
		$this->ConfirmPassword = FormatStringForDatabaseInput($this->ConfirmPassword, 1);
		$this->Attributes = SerializeArray($this->Attributes);
		$this->Discovery = FormatStringForDatabaseInput($this->Discovery, 1);
	}
	
	function FormatPropertiesForDisplay() {
		$this->Name = FormatStringForDisplay($this->Name, 1);
		$this->FirstName = FormatStringForDisplay($this->FirstName, 1);
		$this->LastName = FormatStringForDisplay($this->LastName, 1);
		$this->FullName = FormatStringForDisplay($this->FullName, 1);
		$this->Email = FormatStringForDisplay($this->Email, 1);
		$this->Password = '';
		$this->Picture = FormatStringForDisplay($this->Picture, 1, 0);
		$this->Icon = FormatStringForDisplay($this->Icon, 1, 0);
		$this->DisplayIcon = FormatStringForDisplay($this->DisplayIcon, 1, 0);
		$this->Style = FormatStringForDisplay($this->Style, 0);
	}
	
	function GetPropertiesFromDataSet($DataSet) {
		$this->UserID = ForceInt(@$DataSet['UserID'],0);
		$this->RoleID = ForceInt(@$DataSet['RoleID'],0);
		$this->Role = ForceString(@$DataSet['Role'],'');
		if ($this->RoleID == 0 && $this->Context) $this->Role = $this->Context->GetDefinition('Applicant');
		$this->RoleIcon = ForceString(@$DataSet['RoleIcon'],'');
		$this->RoleDescription = ForceString(@$DataSet['RoleDescription'],'');
		$this->StyleID = ForceInt(@$DataSet['StyleID'], 0);
		$this->Style = ForceString(@$DataSet['Style'], '');
		$this->StyleUrl = ForceString(@$DataSet['StyleUrl'], '');
		$this->CustomStyle = ForceString(@$DataSet['CustomStyle'], '');
		$this->Name = ForceString(@$DataSet['Name'],'');
		$this->FirstName = ForceString(@$DataSet['FirstName'], '');
		$this->LastName = ForceString(@$DataSet['LastName'], '');
		$this->FullName = trim($this->FirstName . ' ' . $this->LastName);
		$this->ShowName = ForceBool(@$DataSet['ShowName'], 0);
		$this->Email = ForceString(@$DataSet['Email'],'');
		$this->UtilizeEmail = ForceBool(@$DataSet['UtilizeEmail'], 0);
		$this->Icon = ForceString(@$DataSet['Icon'], '');
		$this->Picture = ForceString(@$DataSet['Picture'],'');
		$this->Discovery = ForceString(@$DataSet['Discovery'], '');
		$this->Attributes = '';
		$this->Attributes = ForceString(@$DataSet['Attributes'],'');
		$this->Attributes = UnserializeArray($this->Attributes);
		$this->SendNewApplicantNotifications = ForceBool(@$DataSet['SendNewApplicantNotifications'], 0);
		
		if ($this->RoleIcon != '') {
			$this->DisplayIcon = $this->RoleIcon;
		} else {
			$this->DisplayIcon = $this->Icon;
		}
		
		$this->Preferences = '';
		$this->Preferences = ForceString(@$DataSet['Preferences'],'');
		$this->Preferences = UnserializeAssociativeArray($this->Preferences);
		$this->DateFirstVisit = UnixTimestamp(@$DataSet['DateFirstVisit']);
		$this->DateLastActive = UnixTimestamp(@$DataSet['DateLastActive']);
		$this->CountVisit = ForceInt(@$DataSet['CountVisit'],0);
		$this->CountDiscussions = ForceInt(@$DataSet['CountDiscussions'],0);
		$this->CountComments = ForceInt(@$DataSet['CountComments'],0);
		$this->RemoteIp = ForceString(@$DataSet['RemoteIp'],'');
		$this->BlocksCategories = ForceBool(@$DataSet['UserBlocksCategories'], 0);
		$this->DefaultFormatType = ForceString(@$DataSet['DefaultFormatType'], $this->Context->Configuration['DEFAULT_FORMAT_TYPE']);

		// User Role Permissions
      $this->PERMISSION_SIGN_IN = ForceBool(@$DataSet['PERMISSION_SIGN_IN'], $this->Context->Configuration['PERMISSION_SIGN_IN']);
		$this->PERMISSION_HTML_ALLOWED = ForceBool(@$DataSet['PERMISSION_HTML_ALLOWED'], $this->Context->Configuration['PERMISSION_HTML_ALLOWED']);
      $this->PERMISSION_RECEIVE_APPLICATION_NOTIFICATION = ForceBool(@$DataSet['PERMISSION_RECEIVE_APPLICATION_NOTIFICATION'], $this->Context->Configuration['PERMISSION_RECEIVE_APPLICATION_NOTIFICATION']);
		$this->Permissions = '';
		$this->Permissions = ForceString(@$DataSet['Permissions'],'');
		$this->Permissions = UnserializeAssociativeArray($this->Permissions);
		$this->Permissions['PERMISSION_SIGN_IN'] = $this->PERMISSION_SIGN_IN;
		$this->Permissions['PERMISSION_HTML_ALLOWED'] = $this->PERMISSION_HTML_ALLOWED;
		$this->Permissions['PERMISSION_RECEIVE_APPLICATION_NOTIFICATION'] = $this->PERMISSION_RECEIVE_APPLICATION_NOTIFICATION;
		
		// If this user doesn't have permission to do things, force their preferences to abide.
		if (!$this->Permission('PERMISSION_VIEW_HIDDEN_DISCUSSIONS')) $this->Setting['ShowDeletedDiscussions'] = 0;
		if (!$this->Permission('PERMISSION_VIEW_HIDDEN_COMMENTS')) $this->Setting['ShowDeletedComments'] = 0;
		if (!$this->PERMISSION_RECEIVE_APPLICATION_NOTIFICATION) $this->SendNewApplicantNotifications = 0;
			
		// change the user's style if they've selected no style
		if ($this->StyleID == 0) {
			$this->Style = 'Custom';
			$this->StyleUrl = ForceString($this->CustomStyle, $this->Context->Configuration['DEFAULT_STYLE']);
		}
	}
	
	function GetPropertiesFromForm() {
		$this->UserID = ForceIncomingInt('u', 0);
		$this->RoleID = ForceIncomingInt('RoleID', 0);
		$this->StyleID = ForceIncomingInt('StyleID', 0);
		$this->CustomStyle = ForceIncomingString('CustomStyle', '');
		$this->Name = ForceIncomingString('Name', '');
		$this->FirstName = ForceIncomingString('FirstName', '');
		$this->LastName = ForceIncomingString('LastName', '');
		$this->ShowName = ForceIncomingBool('ShowName', 0);
		$this->Email = ForceIncomingString('Email', '');
		$this->UtilizeEmail = ForceIncomingBool('UtilizeEmail',0);
		$this->Password = ForceIncomingString('Password', '');
		$this->Icon = PrependString($this->Context->Configuration['HTTP_METHOD'].'://', ForceIncomingString('Icon',''));
		$this->Picture = PrependString($this->Context->Configuration['HTTP_METHOD'].'://', ForceIncomingString('Picture',''));
		$this->AgreeToTerms = ForceIncomingBool('AgreeToTerms', 0);		
		$this->ReadTerms = ForceIncomingBool('ReadTerms', 0);
		$this->Discovery = ForceIncomingString('Discovery', '');
		
		$this->OldPassword = ForceIncomingString('OldPassword', '');
		$this->NewPassword = ForceIncomingString('NewPassword', '');
		$this->ConfirmPassword = ForceIncomingString('ConfirmPassword', '');
		
		// Retrieve attributes from the form
		$AttributeCount = ForceIncomingInt('LabelValuePairCount', 0);
		$Label = '';
		$Value = '';
		$i = 0;
		for ($i = 0; $i < $AttributeCount; $i++) {
			$Label = ForceIncomingString('Label'.($i+1), '');
			$Label = strip_tags($Label);
			$Label = str_replace("\\\"", "", $Label);
			$Value = ForceIncomingString("Value".($i+1), "");
			$Value = strip_tags($Value);
			$Value = str_replace("\\\"", "", $Value);
			if ($Label != '' && $Value != '') $this->Attributes[] = array('Label' => $Label, 'Value' => $Value);
		}
	}
	
	// Call this method to retrieve a setting (boolean) value rather than accessing the settings array directly and catching an error if the particular setting is not defined
	function Preference($PreferenceName) {
		if (array_key_exists($PreferenceName, $this->Preferences)) {
			return ForceBool($this->Preferences[$PreferenceName], 0);
		} else {
			return ForceBool(@$this->Context->Configuration['PREFERENCE_'.$PreferenceName], 0);
		}
	}
	
	function Permission($PermissionName) {
		$Default = 0;
		if (is_array($this->Context->Configuration)
			&& array_key_exists($PermissionName, $this->Context->Configuration)) {
				$Default = $this->Context->Configuration[$PermissionName];
			}
		if (array_key_exists($PermissionName, $this->Permissions)) {
			return ForceBool($this->Permissions[$PermissionName], $Default);
		} else {
			return $Default;
		}
	}
	
	function User(&$Context) {
		$this->Context = &$Context;
	}
}
?>