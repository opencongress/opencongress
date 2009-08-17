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

class UserManager extends Delegation {
	var $Name;				// The name of this class
   var $Context;			// The context object that contains all global objects (database, error manager, warning collector, session, etc)
	
	function AddBookmark($UserID, $DiscussionID) {
		$s = $this->Context->ObjectFactory->NewContextObject($this->Context, 'SqlBuilder');
		$s->SetMainTable('UserBookmark', 'b');
		$s->AddFieldNameValue('UserID', $UserID);
		$s->AddFieldNameValue('DiscussionID', $DiscussionID);
		$this->Context->Database->Insert($s, $this->Name, 'AddBookmark', 'An error occurred while adding the bookmark.');
	}
	
	function AddCategoryBlock($CategoryID) {
		$s = $this->Context->ObjectFactory->NewContextObject($this->Context, 'SqlBuilder');
		$s->SetMainTable('CategoryBlock', 'b');
		$s->AddFieldNameValue('UserID', $this->Context->Session->UserID);
		$s->AddFieldNameValue('CategoryID', $CategoryID);
		$s->AddFieldNameValue('Blocked', 1);
		// Don't stress over errors (ie. duplicate entries) since this is indexed and duplicates cannot be inserted
		if ($this->Context->Database->Insert($s, $this->Name, 'AddCategoryBlock', 'Failed to add category block.', 0, 0)) {
			$s->Clear();
			$s->SetMainTable('User', 'u');
			$s->AddFieldNameValue('UserBlocksCategories', '1');
			$s->AddWhere('u', 'UserID', '', $this->Context->Session->UserID, '=');
			$this->Context->Database->Update($s, $this->Name, 'AddCategoryBlock', 'Failed to update category block.', 0);
		}
	}

	function AddCommentBlock($CommentID) {
		$s = $this->Context->ObjectFactory->NewContextObject($this->Context, 'SqlBuilder');
		$s->SetMainTable('CommentBlock', 'b');
		$s->AddFieldNameValue('BlockingUserID', $this->Context->Session->UserID);
		$s->AddFieldNameValue('BlockedCommentID', $CommentID);
		$s->AddFieldNameValue('Blocked', 1);
		// Don't stress over errors (ie. duplicate entries) since this is indexed and duplicates cannot be inserted
		$this->Context->Database->Insert($s, $this->Name, 'AddCommentBlock', 'Failed to add comment block.', 0, 0);
	}

	function AddUserBlock($UserID) {
		$s = $this->Context->ObjectFactory->NewContextObject($this->Context, 'SqlBuilder');
		$s->SetMainTable('UserBlock', 'b');
		$s->AddFieldNameValue('BlockingUserID', $this->Context->Session->UserID);
		$s->AddFieldNameValue('BlockedUserID', $UserID);
		$s->AddFieldNameValue('Blocked', 1);
		// Don't stress over errors (ie. duplicate entries) since this is indexed and duplicates cannot be inserted
		$this->Context->Database->Insert($s, $this->Name, 'AddCommentBlock', 'Failed to add user block.', 0, 0);
	}
	
	function ApproveApplicant($ApplicantID) {
		$urh = $this->Context->ObjectFactory->NewObject($this->Context, 'UserRoleHistory');
		if (!is_array($ApplicantID)) {
			$ApplicantID = array($ApplicantID);
		}
		for ($i = 0; $i < count($ApplicantID); $i++) {
			$aid = ForceInt($ApplicantID[$i], 0);
			if ($aid > 0) {
				$urh->UserID = $ApplicantID[$i];
				$urh->Notes = $this->Context->GetDefinition('NewMemberWelcomeAboard');
				$urh->RoleID = $this->Context->Configuration['APPROVAL_ROLE'];
				$this->AssignRole($urh);
			}
		}
		return $this->Context->WarningCollector->Iif();
	}
	
	function AssignRole($UserRoleHistory, $NewUser = '0') {
		$NewUser = ForceBool($NewUser, 0);
		if (!$this->Context->Session->User->Permission('PERMISSION_CHANGE_USER_ROLE') && !$this->Context->Session->User->Permission('PERMISSION_APPROVE_APPLICANTS') && !$NewUser) {
			$this->Context->WarningCollector->Add($this->Context->GetDefinition('ErrPermissionInsufficient'));
		} elseif ($UserRoleHistory->Notes == '') {
			$this->Context->WarningCollector->Add($this->Context->GetDefinition('ErrRoleNotes'));
		} else {			
			// Assign the user to the role first
			$s = $this->Context->ObjectFactory->NewContextObject($this->Context, 'SqlBuilder');
			$s->SetMainTable('User', 'u');
			$s->AddFieldNameValue('RoleID', $UserRoleHistory->RoleID);
			$s->AddWhere('u', 'UserID', '', $UserRoleHistory->UserID, '=');
			$this->Context->Database->Update($s, $this->Name, 'AssignRole', 'An error occurred while assigning the user to a role.');
			
			// Now record the change
			$UserRoleHistory->Notes = FormatStringForDatabaseInput($UserRoleHistory->Notes);
			$s->Clear();
			$s->SetMainTable('UserRoleHistory', 'h');
			$s->AddFieldNameValue('UserID', $UserRoleHistory->UserID);
			$s->AddFieldNameValue('RoleID', $UserRoleHistory->RoleID);
			$s->AddFieldNameValue('Date', MysqlDateTime());
			$s->AddFieldNameValue('AdminUserID', ($NewUser?0:$this->Context->Session->UserID));
			$s->AddFieldNameValue('Notes', $UserRoleHistory->Notes);
			$s->AddFieldNameValue('RemoteIp', GetRemoteIp(1));
			$this->Context->Database->Insert($s, $this->Name, 'AssignRole', 'An error occurred while recording the role change.');
			
			// Now email the user about the role change
         if (!$NewUser) {
				// Retrieve user information
            $AffectedUser = $this->GetUserById($UserRoleHistory->UserID);
					
				$e = $this->Context->ObjectFactory->NewContextObject($this->Context, 'Email');
				$e->HtmlOn = 0;
				$e->WarningCollector = &$this->Context->WarningCollector;
				$e->ErrorManager = &$this->Context->ErrorManager;
				$e->AddFrom($this->Context->Configuration['SUPPORT_EMAIL'], $this->Context->Configuration['SUPPORT_NAME']);
				$e->AddRecipient($AffectedUser->Email, $AffectedUser->Name);
				$e->Subject = $this->Context->Configuration['APPLICATION_TITLE'].' '.$this->Context->GetDefinition('AccountChangeNotification');
				
				$File = "";
				if ($AffectedUser->PERMISSION_SIGN_IN) {
					$File = $this->Context->Configuration['LANGUAGES_PATH']
						.$this->Context->Configuration['LANGUAGE']
						.'/email_role_change.txt';
				} else {
					$File = $this->Context->Configuration['LANGUAGES_PATH']
						.$this->Context->Configuration['LANGUAGE']
						.'/email_banned.txt';
				}
				
				$EmailBody = @file_get_contents($File);
				
				if (!$EmailBody) $this->Context->ErrorManager->AddError($this->Context, $this->Name, 'AssignRole', 'Failed to read email template ('.$File.').');
				
				$e->Body = str_replace(
					array(
						"{user_name}",
						"{forum_name}",
						"{role_name}",
						"{forum_url}"
					),
					array(
						$AffectedUser->Name,
						$this->Context->Configuration['APPLICATION_TITLE'],
						strtolower($AffectedUser->Role),
						ConcatenatePath(
							$this->Context->Configuration['BASE_URL'],
							GetUrl($this->Context->Configuration, 'account.php', '', 'u', $AffectedUser->UserID)
						)
					),
					$EmailBody
				);
				
				$this->DelegateParameters['AffectedUser'] = &$AffectedUser;
				$this->DelegateParameters['EmailBody'] = &$EmailBody;
				$this->CallDelegate('PreRoleChangeNotification');
				
				$e->Send();
			}
		}
		return $this->Context->WarningCollector->Iif();
	}
	
	function ChangePassword($User) {
		if ($this->Context->Configuration['ALLOW_PASSWORD_CHANGE']) {
			// Ensure that the person performing this action has access to do so
			// Everyone can edit themselves
			if ($this->Context->Session->UserID != $User->UserID && !$this->Context->Session->User->Permission('PERMISSION_EDIT_USERS')) $this->Context->WarningCollector->Add($this->Context->GetDefinition('ErrPermissionInsufficient'));
			$User->FormatPropertiesForDatabaseInput();
			if ($this->Context->WarningCollector->Count() == 0) {
				// Ensure that the supplied 'old password' is valid
				$s = $this->Context->ObjectFactory->NewContextObject($this->Context, 'SqlBuilder');
				$s->SetMainTable('User', 'u');
				$s->AddSelect('UserID', 'u');
				$s->StartWhereGroup();
				$s->AddWhere('u', 'Password', '', $User->OldPassword, '=', 'and', 'md5');
				$s->AddWhere('u', 'Password', '', $User->OldPassword, '=', 'or');
				$s->EndWhereGroup();
				$s->AddWhere('u', 'UserID', '', $User->UserID, '=');
				$Result = $this->Context->Database->Select($s, $this->Name, 'ChangePassword', "An error occurred while validating the user's old password.");
				if ($this->Context->Database->RowCount($Result) == 0) $this->Context->WarningCollector->Add($this->Context->GetDefinition('ErrOldPasswordBad'));
			}
			
			// Validate inputs
			Validate($this->Context->GetDefinition('NewPasswordLower'), 1, $User->NewPassword, 100, '', $this->Context);
			if ($User->NewPassword != $User->ConfirmPassword) $this->Context->WarningCollector->Add($this->Context->GetDefinition('ErrNewPasswordMatchBad'));
	
			if ($this->Context->WarningCollector->Count() == 0) {
				$s->Clear();
				$s->SetMainTable('User', 'u');
				$s->AddFieldNameValue('Password', $User->NewPassword, 1, 'md5');
				$s->AddWhere('u', 'UserID', '', $User->UserID, '=');
				$this->Context->Database->Update($s, $this->Name, 'ChangePassword', 'An error occurred while attempting to update the password.');
			}
		}
		return $this->Context->WarningCollector->Iif();
	}
	
	function CreateUser(&$User) {
		$SafeUser = clone($User);
		$SafeUser->FormatPropertiesForDatabaseInput();

		// Instantiate a new validator for each field
		Validate($this->Context->GetDefinition('EmailLower'), 1, $SafeUser->Email, 200, '(.+)@(.+)\.(.+)', $this->Context);
		Validate($this->Context->GetDefinition('UsernameLower'), 1, $SafeUser->Name, 20, '', $this->Context);
		Validate($this->Context->GetDefinition('PasswordLower'), 1, $SafeUser->NewPassword, 50, '', $this->Context);
		if ($SafeUser->NewPassword != $SafeUser->ConfirmPassword) $this->Context->WarningCollector->Add($this->Context->GetDefinition('ErrPasswordsMatchBad'));
		if (!$SafeUser->AgreeToTerms) $this->Context->WarningCollector->Add($this->Context->GetDefinition('ErrAgreeTOS'));
		
		// Ensure the username isn't taken already
		$s = $this->Context->ObjectFactory->NewContextObject($this->Context, 'SqlBuilder');
		$s->SetMainTable('User', 'u');
		$s->AddSelect('UserID', 'u');
		$s->AddWhere('u', 'Name', '', FormatStringForDatabaseInput($SafeUser->Name), '=');
		$MatchCount = 0;
		$result = $this->Context->Database->Select($s, $this->Name, 'CreateUser', 'A fatal error occurred while validating your input.');
		$MatchCount = $this->Context->Database->RowCount($result);
		if ($MatchCount > 0) $this->Context->WarningCollector->Add($this->Context->GetDefinition('ErrUsernameTaken'));

		$this->DelegateParameters['User'] = &$User;
		$this->CallDelegate('PostValidation');
		
		// If validation was successful
		if ($this->Context->WarningCollector->Count() == 0) {
			$s->Clear();
			$s->SetMainTable('User', 'u');
			$s->AddFieldNameValue('FirstName', $SafeUser->FirstName);
			$s->AddFieldNameValue('LastName', $SafeUser->LastName);
			$s->AddFieldNameValue('Name', $SafeUser->Name);
			$s->AddFieldNameValue('Email', $SafeUser->Email);
			$s->AddFieldNameValue('Password', $SafeUser->NewPassword, 1, 'md5');
			$s->AddFieldNameValue('DateFirstVisit', MysqlDateTime());
			$s->AddFieldNameValue('DateLastActive', MysqlDateTime());
			$s->AddFieldNameValue('CountVisit', 0);
			$s->AddFieldNameValue('CountDiscussions', 0);
			$s->AddFieldNameValue('CountComments', 0);
			$s->AddFieldNameValue('RoleID', $this->Context->Configuration['DEFAULT_ROLE']);
			$s->AddFieldNameValue('StyleID', 0);
			$s->AddFieldNameValue('UtilizeEmail', $this->Context->Configuration['DEFAULT_EMAIL_VISIBLE']);
			$s->AddFieldNameValue('Attributes', '');
			$s->AddFieldNameValue('RemoteIp', GetRemoteIp(1));
			
			$this->DelegateParameters['User'] = &$User;
			$this->DelegateParameters['SqlBuilder'] = &$s;
			$this->CallDelegate('PreDataInsert');
			
			$User->UserID = $this->Context->Database->Insert($s, $this->Name, 'CreateUser', 'An error occurred while creating a new user.');
				
			$Urh = $this->Context->ObjectFactory->NewObject($this->Context, 'UserRoleHistory');
			$Urh->UserID = $User->UserID;
			$Urh->AdminUserID = 0;
			$Urh->RoleID = $this->Context->Configuration['DEFAULT_ROLE'];
			if ($this->Context->Configuration['ALLOW_IMMEDIATE_ACCESS']) {
				$Urh->Notes = $this->Context->GetDefinition('RegistrationAccepted');
			} else {
				$Urh->Notes = $this->Context->GetDefinition('RegistrationPendingApproval');
			}
			$this->AssignRole($Urh, 1);
			
			$this->CallDelegate('PostRoleAssignment');
			
			// Notify user administrators
         if (!$this->Context->Configuration['ALLOW_IMMEDIATE_ACCESS']) {
				$s->Clear();
				$s->SetMainTable('User', 'u');
				$s->AddJoin('Role', 'r', 'RoleID', 'u', 'RoleID', 'inner join');
				$s->AddWhere('r', 'PERMISSION_RECEIVE_APPLICATION_NOTIFICATION', '', 1, '=');
				$s->AddWhere('u', 'SendNewApplicantNotifications', '', 1, '=');
				$s->AddSelect(array('Name', 'Email'), 'u');
				$Administrators = $this->Context->Database->Select($s, $this->Name, 'CreateUser', 'An error occurred while retrieving administrator email addresses.', 0);
				// Fail silently if an error occurs while notifying administrators
            
				// Get the email body
				$File = $this->Context->Configuration['LANGUAGES_PATH']
					.$this->Context->Configuration['LANGUAGE']
					.'/email_applicant.txt';
				$EmailBody = @file_get_contents($File);
				
				if ($EmailBody && $Administrators) {
					$EmailBody = str_replace(
						array(
							"{applicant_name}",
							"{applicant_email}",
							"{application_url}"
						),
						array(
							$User->Name,
							$User->Email,
							ConcatenatePath(
								$this->Context->Configuration['BASE_URL'],
								GetUrl($this->Context->Configuration, 'settings.php', '', '', '', '', 'PostBackAction=Applicants')
							)
						),
						$EmailBody
					);
					
					$this->DelegateParameters['User'] = &$User;
					$this->DelegateParameters['EmailBody'] = &$EmailBody;
					$this->CallDelegate('PreNewUserNotification');
					
					if ($this->Context->Database->RowCount($Administrators) > 0) {
						$e = $this->Context->ObjectFactory->NewContextObject($this->Context, 'Email');
						$e->HtmlOn = 0;
						$e->ErrorManager = &$this->Context->ErrorManager;
						$e->WarningCollector = &$this->Context->WarningCollector;
						$e->AddFrom($User->Email, $User->Name);
						$AdminEmail = '';
						$AdminName = '';
						while ($Row = $this->Context->Database->GetRow($Administrators)) {
							$AdminEmail = ForceString($Row['Email'], '');
							$AdminName = ForceString($Row['Name'], '');
							if ($AdminEmail != '') $e->AddRecipient($AdminEmail, $AdminName);
						}
						$e->Subject = $this->Context->GetDefinition("NewApplicant");
						$e->Body = $EmailBody;						
						$e->Send(0);
					}
				}
			}
		}
		return $this->Context->WarningCollector->Iif();
	}
	
	function GetApplicantCount() {
		$ApplicantData = $this->GetUsersByRoleId(0);
		if ($ApplicantData) {
			return $this->Context->Database->RowCount($ApplicantData);
		} else {
			return 0;
		}
	}

	function GetIpHistory($UserID) {
		$s = $this->Context->ObjectFactory->NewContextObject($this->Context, 'SqlBuilder');
		$s->SetMainTable('IpHistory', 'i');
		$s->AddSelect('IpHistoryID', 'i', 'UsageCount', 'count');
		$s->AddSelect('RemoteIp', 'i');
		$s->AddGroupBy('RemoteIp', 'i');
		$s->AddWhere('i', 'UserID', '', $UserID, '=');
		$ResultSet = $this->Context->Database->Select($s, $this->Name, 'GetIpHistory', 'An error occurred while retrieving historical IP usage data.');
		$IpData = array();
		$SharedWith = array();
		$CurrentIp = '';
		$UsageCount = 0;
		$SharedUserName = '';
		$SharedUserID = '';
		while ($Row = $this->Context->Database->GetRow($ResultSet)) {
			$CurrentIp = ForceString($Row['RemoteIp'], '');
			$UsageCount = ForceInt($Row['UsageCount'], 0);
			$UserData = $this->GetUsersByIp($CurrentIp);
			while ($UserRow = $this->Context->Database->GetRow($UserData)) {
				$SharedUserName = ForceString($UserRow['Name'], '');
				$SharedUserID = ForceInt($UserRow['UserID'], 0);
				if ($SharedUserID > 0 && $SharedUserID != $UserID) {
					$SharedWith[] = array('UserID' => $SharedUserID, 'Name' => $SharedUserName);
				}
			}
			$IpData[] = array('IP' => $CurrentIp, 'UsageCount' => $UsageCount, 'SharedWith' => $SharedWith);
			$SharedWith = array();
		}
		return $IpData;
	}
	
	// Returns a SqlBuilder object with all of the user properties already defined in the select
	function GetUserBuilder() {
		$s = $this->Context->ObjectFactory->NewContextObject($this->Context, 'SqlBuilder');
		$s->SetMainTable('User', 'u');
		$s->AddJoin('Role', 'r', 'RoleID', 'u', 'RoleID', 'left join');
		$s->AddJoin('Style', 's', 'StyleID', 'u', 'StyleID', 'left join');
		$s->AddSelect(array('UserID', 'Name', 'FirstName', 'LastName', 'Email', 'UtilizeEmail', 'Icon', 'Picture', 'Attributes', 'Preferences', 'CountVisit', 'CountDiscussions', 'CountComments', 'RemoteIp', 'DateFirstVisit', 'DateLastActive', 'RoleID', 'StyleID', 'CustomStyle', 'ShowName', 'UserBlocksCategories', 'DefaultFormatType', 'Discovery', 'SendNewApplicantNotifications'), 'u');
		$s->AddSelect(array('PERMISSION_SIGN_IN', 'PERMISSION_RECEIVE_APPLICATION_NOTIFICATION', 'PERMISSION_HTML_ALLOWED', 'Permissions'), 'r');
		$s->AddSelect('Name', 'r', 'Role');
		$s->AddSelect('Description', 'r', 'RoleDescription');
		$s->AddSelect('Icon', 'r', 'RoleIcon');
		$s->AddSelect('Url', 's', 'StyleUrl');
		$s->AddSelect('Name', 's', 'Style');
		return $s;
	}
	
	function GetUserById($UserID) {
		if ($UserID > 0) {
			$s = $this->GetUserBuilder();
			$s->AddWhere('u', 'UserID', '', $UserID, '=');
			$Found = false;
	
			$User = $this->Context->ObjectFactory->NewContextObject($this->Context, 'User');
			$UserData = $this->Context->Database->Select($s, $this->Name, 'GetUserById', 'An error occurred while attempting to retrieve the requested user.');
			while ($rows = $this->Context->Database->GetRow($UserData)) {
				$User->GetPropertiesFromDataSet($rows);
				$Found = true;
			}
			return $Found ? $User : false;
		} else {
			return false;
		}
	}
	
	function GetUserIdByName($Username) {
		$Username = FormatStringForDatabaseInput(ForceString($Username, ''), 1);
		$UserID = 0;
		if ($Username != '') {
			$s = $this->Context->ObjectFactory->NewContextObject($this->Context, 'SqlBuilder');
			$s->SetMainTable('User', 'u');
			$s->AddSelect('UserID', 'u');
			$s->AddWhere('u', 'Name', '', $Username, '=');
			$result = $this->Context->Database->Select($s, $this->Name, 'GetUserIdByName', 'An error occurred while attempting to retrieve the requested user information.');
			while ($rows = $this->Context->Database->GetRow($result)) {
				$UserID = ForceInt($rows['UserID'], 0);
			}
		}
		return $UserID;
	}
	
	function GetUserRoleHistoryByUserId($UserID) {
		$s = $this->Context->ObjectFactory->NewContextObject($this->Context, 'SqlBuilder');
		$s->SetMainTable('UserRoleHistory', 'h');
		$s->AddJoin('Role', 'r', 'RoleID', 'h', 'RoleID', 'inner join');
		$s->AddJoin('User', 'u', 'UserID', 'h', 'UserID', 'inner join');
		$s->AddJoin('User', 'a', 'UserID', 'h', 'AdminUserID', 'left join');
		$s->AddSelect(array('UserID', 'RoleID', 'AdminUserID', 'Notes', 'Date'), 'h');
		$s->AddSelect('Name', 'u', 'Username');
		$s->AddSelect('Name', 'a', 'AdminUsername');
		$s->AddSelect('Name', 'r', 'Role');
		$s->AddSelect('Description', 'r', 'RoleDescription');
		$s->AddSelect('Icon', 'r', 'RoleIcon');
		$s->AddWhere('h', 'UserID', '', $UserID, '=');
		$s->AddOrderBy('Date', 'h', 'desc');
		return $this->Context->Database->Select($s, $this->Name, 'GetUserRoleHistoryByUserId', "An error occurred while attempting to retrieve the user's role history.");
	}
	
	function GetUsersByIp($Ip) {
		$s = $this->Context->ObjectFactory->NewContextObject($this->Context, 'SqlBuilder');
		$s->SetMainTable('User', 'u');
		$s->AddJoin('IpHistory', 'i', "UserID", 'u', 'UserID', 'inner join', " and i.".$this->Context->DatabaseColumns['IpHistory']['RemoteIp']." = '$Ip'");
		$s->AddSelect(array('UserID', 'Name'), 'u');
		$s->AddGroupBy('UserID', 'u');
		return $this->Context->Database->Select($s, $this->Name, 'GetUsersByIp', 'An error occurred while retrieving users by IP.');
	}
	
	function GetUsersByRoleId($RoleID, $RecordsToReturn = '0') {
		$RecordsToReturn = ForceInt($RecordsToReturn, 0);
		$s = $this->GetUserBuilder();
		$s->AddSelect('Discovery', 'u');
		$s->AddWhere('u', 'RoleID', '', $RoleID, '=');
		if ($RecordsToReturn > 0) $s->AddLimit(0,$RecordsToReturn);
		return $this->Context->Database->Select($s, $this->Name, 'GetUsersByRoleId', 'An error occurred while attempting to retrieve users from the specified role.');
	}
	
	function GetUserSearch($Search, $RowsPerPage, $CurrentPage) {
		$s = $this->GetSearchBuilder($Search);
		$SortField = $Search->UserOrder;
		if (!in_array($SortField, array('Name', 'Date'))) $SortField = 'Name';
		if ($SortField != 'Name') $SortField = 'DateLastActive';
		$SortDirection = ($SortField == 'Name'?'asc':'desc');
		$s->AddOrderBy($SortField, 'u', $SortDirection);
		if ($RowsPerPage > 0) {
			$CurrentPage = ForceInt($CurrentPage, 1);
			if ($CurrentPage < 1) $CurrentPage == 1;
			$RowsPerPage = ForceInt($RowsPerPage, 50);
			$FirstRecord = ($CurrentPage * $RowsPerPage) - $RowsPerPage;
		}		
		if ($RowsPerPage > 0) $s->AddLimit($FirstRecord, $RowsPerPage+1);
		return $this->Context->Database->Select($s, $this->Name, 'GetUserSearch', 'An error occurred while retrieving search results.');
	}
	
	function GetSearchBuilder($Search) {
		$Search->FormatPropertiesForDatabaseInput();
		$s = $this->Context->ObjectFactory->NewContextObject($this->Context, 'SqlSearch');
		$s->UserQuery = $Search->Query;
		$s->SearchFields = array('u.Name');
		if ($this->Context->Session->User->Permission('PERMISSION_EDIT_USERS')
		|| $this->Context->Session->User->Permission('PERMISSION_APPROVE_APPLICANTS')
		|| $this->Context->Session->User->Permission('PERMISSION_CHANGE_USER_ROLE')) {
			$s->SearchFields[] = 'u.FirstName';
			$s->SearchFields[] = 'u.LastName';
			$s->SearchFields[] = 'u.Email';
		}
		$s->SetMainTable('User', 'u');
		$s->AddJoin('Style', 's', 'StyleID', 'u', 'StyleID', 'left join');
		$s->AddJoin('Role', 'r', 'RoleID', 'u', 'RoleID', 'left join');
		$s->AddSelect(array('UserID', 'RoleID', 'StyleID', 'CustomStyle', 'FirstName', 'LastName', 'Name', 'Email', 'UtilizeEmail', 'Icon', 'CountVisit', 'CountDiscussions', 'CountComments', 'DateFirstVisit', 'DateLastActive'), 'u');
		$s->AddSelect('Name', 's', 'Style');
		$s->AddSelect('Name', 'r', 'Role');
		$s->AddSelect('Icon', 'r', 'RoleIcon');
		
		$this->DelegateParameters['SqlBuilder'] = &$s;
		$this->CallDelegate('PreDefineSearch');		
		
		$s->DefineSearch();
		if ($Search->Roles != '') {
			$Roles = explode(',',$Search->Roles);
			$RoleCount = count($Roles);
			$s->AddWhere('', '1', '', '0', '=', 'and', '', 0, 1);
			for ($i = 0; $i < $RoleCount; $i++) {
				if ($Roles[$i] == $this->Context->GetDefinition('Applicant')) {
					$s->AddWhere('u', 'RoleID', '', 0, '=', 'or', '', 1);
					$s->AddWhere('u', 'RoleID', '', 0, '=', 'or', '' ,0);
				} else {
					$s->AddWhere('r', 'Name', '', trim($Roles[$i]), '=', 'or');
				}
			}
			$s->EndWhereGroup();
		}
		if ($this->Context->Session->User && $this->Context->Session->User->Permission('PERMISSION_APPROVE_APPLICANTS')) {
			// Allow the applicant search
		} else {
			// DON'T allow the applicant search
			$s->AddWhere('u', 'RoleID', '', 0, '<>', 'and');
		}
		return $s;
	}
	
	// Just retrieve user properties relevant to the session
	function GetSessionDataById($UserID) {
		$s = $this->Context->ObjectFactory->NewContextObject($this->Context, 'SqlBuilder');
		$s->SetMainTable('User', 'u');
		$s->AddJoin('Role', 'r', 'RoleID', 'u', 'RoleID', 'left join');
		$s->AddJoin('Style', 's', 'StyleID', 'u', 'StyleID', 'left join');
		
		$s->AddSelect(array('Name', 'UserID', 'RoleID', 'StyleID', 'CustomStyle', 'UserBlocksCategories', 'DefaultFormatType', 'Preferences', 'SendNewApplicantNotifications'), 'u');
		$s->AddSelect(array('PERMISSION_SIGN_IN', 'PERMISSION_RECEIVE_APPLICATION_NOTIFICATION', 'PERMISSION_HTML_ALLOWED', 'Permissions'), 'r');
		$s->AddSelect('Url', 's', 'StyleUrl');
		$s->AddWhere('u', 'UserID', '', $UserID, '=');

		$User = $this->Context->ObjectFactory->NewContextObject($this->Context, 'User');
		$UserData = $this->Context->Database->Select($s, $this->Name, 'GetSessionDataById', 'An error occurred while attempting to retrieve the requested user.');
		if ($this->Context->Database->RowCount($UserData) == 0) {
			// This warning is in plain english, because at the point that
         // this method is called, the dictionary object is not yet loaded
         // (this is called in the context object's constructor when the session is started)
			$this->Context->WarningCollector->Add('The requested user could not be found.');
		} else {
			while ($rows = $this->Context->Database->GetRow($UserData)) {
				$User->GetPropertiesFromDataSet($rows);
			}
		}
		return $this->Context->WarningCollector->Iif($User, false);
	}
	
	function LogIp($UserID) {
		if ($this->Context->Configuration['LOG_ALL_IPS']) {
			$s = $this->Context->ObjectFactory->NewContextObject($this->Context, 'SqlBuilder');
			$s->SetMainTable('IpHistory', 'i');
			$s->AddFieldNameValue('UserID', $UserID);
			$s->AddFieldNameValue('RemoteIp', GetRemoteIp(1));
			$s->AddFieldNameValue('DateLogged', MysqlDateTime());
			$this->Context->Database->Insert($s, $this->Name, 'LogIp', 'An error occurred while logging user data.');
		}
	}
	
	function RemoveApplicant($UserID) {
		// Ensure that the user has not made any contributions to the application in any way
      if (!is_array($UserID)) $UserID = array($UserID);
		$s = $this->Context->ObjectFactory->NewContextObject($this->Context, 'SqlBuilder');
      
		for ($i = 0; $i < count($UserID); $i++) {
			$uid = ForceInt($UserID[$i], 0);
			
			if ($uid > 0) {
				// Styles
				$s->Clear();
				$s->SetMainTable('Style', 's');
				$s->AddSelect('StyleID', 's');
				$s->AddWhere('s', 'AuthUserID', '', $uid, '=');
				$Result = $this->Context->Database->Select($s, $this->Name, 'RemoveApplicant', 'An error occurred while removing the user.');
				if ($this->Context->Database->RowCount($Result) > 0) $this->Context->WarningCollector->Add($this->Context->GetDefinition('ErrRemoveUserStyle'));
				if ($this->Context->WarningCollector->Count() > 0) return false;
				
				// Comments
				$s->Clear();
				$s->SetMainTable('Comment', 'm');
				$s->AddSelect('CommentID', 'm');
				$s->AddWhere('m', 'AuthUserID', '', $uid, '=');
				$Result = $this->Context->Database->Select($s, $this->Name, 'RemoveApplicant', 'An error occurred while removing the user.');
				if ($this->Context->Database->RowCount($Result) > 0) $this->Context->WarningCollector->Add($this->Context->GetDefinition('ErrRemoveUserComments'));
				if ($this->Context->WarningCollector->Count() > 0) return false;
				
				// Discussions
				$s->Clear();
				$s->SetMainTable('Discussion', 't');
				$s->AddSelect('DiscussionID', 't');
				$s->AddWhere('t', 'AuthUserID', '', $uid, '=');
				$Result = $this->Context->Database->Select($s, $this->Name, 'RemoveApplicant', 'An error occurred while removing the user.');
				if ($this->Context->Database->RowCount($Result) > 0) $this->Context->WarningCollector->Add($this->Context->GetDefinition('ErrRemoveUserDiscussions'));
				if ($this->Context->WarningCollector->Count() > 0) return false;
				
				// Remove other data the user has created
				// Bookmarks
				$s->Clear();
				$s->SetMainTable('UserBookmark', 'b');
				$s->AddWhere('b', 'UserID', '', $uid, '=');
				$this->Context->Database->Delete($s, $this->Name, 'RemoveApplicant', "An error occurred while removing the user's bookmarks.");
				
				// Role History
				$s->Clear();
				$s->SetMainTable('UserRoleHistory', 'r');
				$s->AddWhere('r', 'UserID', '', $uid, '=');
				$this->Context->Database->Delete($s, $this->Name, 'RemoveApplicant', "An error occurred while removing the user's role history.");
				
				// Discussion Watch
				$s->Clear();
				$s->SetMainTable('UserDiscussionWatch', 'w');
				$s->AddWhere('w', 'UserID', '', $uid, '=');
				$this->Context->Database->Delete($s, $this->Name, 'RemoveApplicant', "An error occurred while removing the user's discussion history.");
				
				// Remove the user
				$s->Clear();
				$s->SetMainTable('User', 'u');
				$s->AddWhere('u', 'UserID', '', $uid, '=');
				// Adding in this little check to make sure that only applicants can be removed.
				$s->AddWhere('u', 'RoleID', '', 0, '=');
				$this->Context->Database->Delete($s, $this->Name, 'RemoveApplicant', 'An error occurred while removing the user.');
			}
		}
		
		return true;
	}
	
	function RemoveBookmark($UserID, $DiscussionID) {
		$s = $this->Context->ObjectFactory->NewContextObject($this->Context, 'SqlBuilder');
		$s->SetMainTable('UserBookmark', 'b');
		$s->AddWhere('b', 'UserID', '', $UserID, '=');
		$s->AddWhere('b', 'DiscussionID', '', $DiscussionID, '=');
		$this->Context->Database->Delete($s, $this->Name, 'RemoveBookmark', 'An error occurred while removing the bookmark.');
	}
	
	function RemoveCategoryBlock($CategoryID) {
		$s = $this->Context->ObjectFactory->NewContextObject($this->Context, 'SqlBuilder');
		$s->SetMainTable('CategoryBlock', 'b');
		$s->AddWhere('b', 'CategoryID', '', $CategoryID, '=');
		$s->AddWhere('b', 'UserID', '', $this->Context->Session->UserID, '=');
		// Don't stress over errors (ie. duplicate entries) since this is indexed and duplicates cannot be inserted
		if ($this->Context->Database->Delete($s, $this->Name, 'RemoveCategoryBlock', 'An error occurred while removing the category block.', 0)) {
			$s->Clear();
			$s->SetMainTable('CategoryBlock', 'b');
			$s->AddWhere('b', 'UserID', '', $this->Context->Session->UserID, '=');			
			$s->AddSelect('CategoryID', 'b');
			$Result = $this->Context->Database->Select($s, $this->Name, 'RemoveCategoryBlock', 'Related category block information could not be found.', 0);
			if ($Result) {
				if ($this->Context->Database->RowCount($Result) == 0) {
					$s->Clear();
					$s->SetMainTable('User', 'u');
					$s->AddFieldNameValue('UserBlocksCategories', '0');
					$s->AddWhere('u', 'UserID', '', $this->Context->Session->UserID, '=');
					$this->Context->Database->Update($s, $this->Name, 'RemoveCategoryBlock', 'An error occurred while updating category block information.', 0);
				}
			}			
		}
	}
	
	function RemoveCommentBlock($CommentID) {
		$s = $this->Context->ObjectFactory->NewContextObject($this->Context, 'SqlBuilder');
		$s->SetMainTable('CommentBlock', 'b');
		$s->AddWhere('b', 'BlockedCommentID', '', $CommentID, '=');
		$s->AddWhere('b', 'BlockingUserID', '', $this->Context->Session->UserID, '=');
		echo($s->GetDelete());
		// Don't stress over errors (ie. duplicate entries) since this is indexed and duplicates cannot be inserted
      $this->Context->Database->Delete($s, $this->Name, 'RemoveCommentBlock', 'An error occurred while removing the comment block.', 0);
	}

	function RemoveUserBlock($UserID) {
		$s = $this->Context->ObjectFactory->NewContextObject($this->Context, 'SqlBuilder');
		$s->SetMainTable('UserBlock', 'b');
		$s->AddFieldNameValue('BlockingUserID', $this->Context->Session->UserID);
		$s->AddFieldNameValue('BlockedUserID', $UserID);
		// Don't stress over errors (ie. duplicate entries) since this is indexed and duplicates cannot be inserted
      $this->Context->Database->Delete($s, $this->Name, 'RemoveUserBlock', 'An error occurred while removing the user block.', 0);
	}
	
	function RequestPasswordReset($Username) {
		$Username = FormatStringForDatabaseInput($Username, '');
		$Email = false;
		if ($Username == '') {
			$this->Context->WarningCollector->Add($this->Context->GetDefinition('ErrInvalidUsername'));
		} else {
			// Attempt to retrieve email address
			$s = $this->Context->ObjectFactory->NewContextObject($this->Context, 'SqlBuilder');
			$s->SetMainTable('User', 'u');
			$s->AddSelect(array('Email', 'Name', 'UserID'), 'u');
			$s->AddWhere('u', 'Name', '', $Username, '=');
			
			
			$UserResult = $this->Context->Database->Select($s, $this->Name, 'RequestPasswordReset', 'An error occurred while retrieving account information.');
			if ($this->Context->Database->RowCount($UserResult) == 0) {
				$this->Context->WarningCollector->Add($this->Context->GetDefinition('ErrAccountNotFound'));
			} else {
				$Name = '';
				$Email = '';
				$UserID = 0;
				while ($rows = $this->Context->Database->GetRow($UserResult)) {
					$UserID = ForceInt($rows['UserID'], 0);
					$Email = ForceString($rows['Email'], '');
					$Name = FormatStringForDisplay($rows['Name'], 1);
				}
				// Now that we have the email, generate an email verification key
				$EmailVerificationKey = DefineVerificationKey();
				
				// Insert the email verification key into the user table
				$s->Clear();
				$s->SetMainTable('User', 'u');
				$s->AddFieldNameValue('EmailVerificationKey', $EmailVerificationKey,1);
				$s->AddWhere('u', 'UserID', '', $UserID, '=');
				$this->Context->Database->Update($s, $this->Name, 'RequestPasswordReset', 'An error occurred while managing your account information.');
				
				// If there are no errors, send the user an email
				if ($this->Context->WarningCollector->Count() == 0) {
					// Retrieve the email body
					$File = $this->Context->Configuration['LANGUAGES_PATH']
						.$this->Context->Configuration['LANGUAGE']
						.'/email_password_request.txt';
				
					$EmailBody = @file_get_contents($File);
					if (!$EmailBody) $this->Context->ErrorManager->AddError($this->Context, $this->Name, 'AssignRole', 'Failed to read email template ('.$File.').');
				
					$e = $this->Context->ObjectFactory->NewContextObject($this->Context, 'Email');
					$e->HtmlOn = 0;
					$e->WarningCollector = &$this->Context->WarningCollector;
					$e->ErrorManager = &$this->Context->ErrorManager;
					$e->AddFrom($this->Context->Configuration['SUPPORT_EMAIL'], $this->Context->Configuration['SUPPORT_NAME']);
					$e->AddRecipient($Email, $Name);
					$e->Subject = $this->Context->Configuration['APPLICATION_TITLE'].' '.$this->Context->GetDefinition('PasswordResetRequest');
					$e->Body = str_replace(
						array(
							"{user_name}",
							"{forum_name}",
							"{password_url}"
						),
						array(
							$Name,
							$this->Context->Configuration['APPLICATION_TITLE'],
							ConcatenatePath(
								$this->Context->Configuration['BASE_URL'],
								GetUrl($this->Context->Configuration, 'people.php', '', '', '', '', 'PostBackAction=PasswordResetForm&u='.$UserID.'&k='.$EmailVerificationKey)
							)
						),
						$EmailBody
					);
					
					$e->Send();
				}	
			}
		}
		return $this->Context->WarningCollector->Iif($Email,false);
	}
	
	function ResetPassword($PassUserID, $EmailVerificationKey, $NewPassword, $ConfirmPassword) {
		// Validate the passwords
      if ($NewPassword == '') $this->Context->WarningCollector->Add($this->Context->GetDefinition('ErrPasswordRequired'));
		if ($NewPassword != $ConfirmPassword) $this->Context->WarningCollector->Add($this->Context->GetDefinition('ErrPasswordsMatchBad'));
		
		if ($this->Context->WarningCollector->Count() == 0) {
			$NewPassword = FormatStringForDatabaseInput($NewPassword, 1);
			$EmailVerificationKey = FormatStringForDatabaseInput($EmailVerificationKey);
			
			// Attempt to retrieve email address
			$s = $this->Context->ObjectFactory->NewContextObject($this->Context, 'SqlBuilder');
			$s->SetMainTable('User', 'u');
			$s->AddFieldNameValue('EmailVerificationKey', '', 1);
			$s->AddFieldNameValue('Password', $NewPassword, 1, 'md5');
			$s->AddWhere('u', 'UserID', '', $PassUserID, '=');
			$s->AddWhere('u', 'EmailVerificationKey', '', $EmailVerificationKey, '=');
			$this->Context->Database->Update($s, $this->Name, 'ResetPassword', 'An error occurred while updating your password.');
		}
		return $this->Context->WarningCollector->Iif();
	}
	
	function SaveIdentity($User) {
		// Ensure that the person performing this action has access to do so
		// Everyone can edit themselves
		if ($this->Context->Session->UserID != $User->UserID && !$this->Context->Session->User->Permission('PERMISSION_EDIT_USERS')) $this->Context->WarningCollector->Add($this->Context->GetDefinition('ErrPermissionInsufficient'));
		
		if ($this->Context->WarningCollector->Count() == 0) {
			// Validate the properties
			if($this->ValidateUser($User)) {
				$s = $this->Context->ObjectFactory->NewContextObject($this->Context, 'SqlBuilder');
				$s->SetMainTable('User', 'u');
				if ($this->Context->Configuration['ALLOW_NAME_CHANGE'] == '1') $s->AddFieldNameValue('Name', $User->Name);
				if ($this->Context->Configuration['USE_REAL_NAMES'] == '1') {
					$s->AddFieldNameValue('FirstName', $User->FirstName);
					$s->AddFieldNameValue('LastName', $User->LastName);
					$s->AddFieldNameValue('ShowName', $User->ShowName);
				}
				if ($this->Context->Configuration['ALLOW_EMAIL_CHANGE'] == '1') $s->AddFieldNameValue('Email', $User->Email);
				$s->AddFieldNameValue('UtilizeEmail', $User->UtilizeEmail);
				$s->AddFieldNameValue('Icon', $User->Icon);
				$s->AddFieldNameValue('Picture', $User->Picture);
				$s->AddFieldNameValue('Attributes', $User->Attributes);
				$s->AddWhere('u', 'UserID', '', $User->UserID, '=');
				$this->DelegateParameters['User'] = &$User;
				$this->DelegateParameters['SqlBuilder'] = &$s;
				$this->CallDelegate('PreIdentityUpdate');
				$this->Context->Database->Update($s, $this->Name, 'SaveIdentity', 'An error occurred while attempting to update the identity data.');
			}
		}
		return $this->Context->WarningCollector->Iif();
	}
	
	function SaveStyle($User) {
		// Ensure that the person performing this action has access to do so
		// Everyone can edit themselves
		if ($this->Context->Session->UserID != $User->UserID) $this->Context->WarningCollector->Add($this->Context->GetDefinition('ErrPermissionInsufficient'));
		
		if ($this->Context->WarningCollector->Count() == 0) {
			// Make sure they've got a style of some kind
			if ($User->CustomStyle == '' && $User->StyleID == 0) $User->StyleID = 1;
			$User->FormatPropertiesForDatabaseInput();
			$s = $this->Context->ObjectFactory->NewContextObject($this->Context, 'SqlBuilder');
			$s->SetMainTable('User', 'u');
			$s->AddFieldNameValue('StyleID', $User->StyleID);
			if ($User->StyleID == 0) $s->AddFieldNameValue('CustomStyle', $User->CustomStyle);
			$s->AddWhere('u', 'UserID', '', $User->UserID, '=');
			$this->Context->Database->Update($s, $this->Name, 'SaveStyle', 'An error occurred while attempting to update the style data.');
		}
		$this->Context->Session->User->StyleID = $User->StyleID;
		$this->Context->Session->User->CustomStyle = $User->CustomStyle;
		
		return $this->Context->WarningCollector->Iif();
	}
	
	function SetDefaultFormatType($UserID, $FormatType) {
		$this->Context->Session->User->DefaultFormatType = $FormatType;
		return $this->SwitchUserProperty($UserID, 'DefaultFormatType', $FormatType);
	}
	
	function SwitchUserProperty($UserID, $PropertyName, $Switch) {
		$UserID = ForceInt($UserID, 0);
		if ($UserID == 0) $this->Context->WarningCollector->Add($this->Context->GetDefinition('ErrUserID'));
		
		if ($UserID != $this->Context->Session->UserID) $this->Context->WarningCollector->Add($this->Context->GetDefinition('ErrPermissionUserSettings'));
		
		if ($this->Context->WarningCollector->Count() == 0) {
			$s = $this->Context->ObjectFactory->NewContextObject($this->Context, 'SqlBuilder');
			$s->SetMainTable('User', 'u');
			$s->AddFieldNameValue($PropertyName, $Switch);
			$s->AddWhere('u', 'UserID', '', $UserID, '=');
			$this->Context->Database->Update($s, $this->Name, 'SwitchUserProperty', 'An error occurred while manipulating user properties.');
		}
		return $this->Context->WarningCollector->Iif();
	}	
	// Boolean preferences
	function SwitchUserPreference($PreferenceName, $Switch) {
		$Switch = ForceBool($Switch, 0);
		if ($this->Context->Session->UserID == 0) $this->Context->WarningCollector->Add($this->Context->GetDefinition('ErrUserID'));
		
		if ($this->Context->WarningCollector->Count() == 0) {
			// Set the value for the user
         $this->Context->Session->User->Preferences[$PreferenceName] = $Switch;
			$this->SaveUserPreferences($this->Context->Session->User);
		}
		return $this->Context->WarningCollector->Iif();
	}
	// Customizable strings
	function SaveUserCustomization($CustomizationName, $Value) {
		$Value = ForceString($Value, '');
		if ($this->Context->Session->UserID == 0) $this->Context->WarningCollector->Add($this->Context->GetDefinition('ErrUserID'));
		if ($this->Context->WarningCollector->Count() == 0) {
			// Set the value for the user
         $this->Context->Session->User->Preferences[$CustomizationName] = $Value;
         $this->SaveUserPreferences($this->Context->Session->User);
		}
		return $this->Context->WarningCollector->Iif();		
	}
	
	function SaveUserCustomizationsFromForm(&$User) {
		$ValueSet = 0;
		while (list($CustomizationName, $DefaultValue) = each($this->Context->Configuration)) {
			if (strpos($CustomizationName, 'CUSTOMIZATION_') !== false) {
				$ValueSet = 1;
				$Value = ForceIncomingString($CustomizationName, '');
				$CustomizationName = substr($CustomizationName, 14);
	         $User->Preferences[$CustomizationName] = $Value;
			}
		}
      if ($ValueSet) $this->SaveUserPreferences($User);
		return true;
	}
		
	function SaveUserPreferences($User) {
		if ($User->UserID > 0) {
			// Serialize and save the settings
         $SerializedPreferences = SerializeArray($User->Preferences);
			$s = $this->Context->ObjectFactory->NewContextObject($this->Context, 'SqlBuilder');
			$s->SetMainTable('User', 'u');
			$s->AddFieldNameValue('Preferences', $SerializedPreferences);
			$s->AddWhere('u', 'UserID', '', $User->UserID, '=');
			$this->Context->Database->Update($s, $this->Name, 'SaveUserPreferences', 'An error occurred while manipulating user preferences.');
		}
		return true;
	}
	
	function UpdateUserBlogCount($UserID) {
		$s = $this->Context->ObjectFactory->NewContextObject($this->Context, 'SqlBuilder');
		$s->SetMainTable('User', 'u');
		$s->AddFieldNameValue('CountBlogs', 'CountBlogs+1', 0);
		$s->AddWhere('u', 'UserID', '', $UserID, '=');
		$this->Context->Database->Update($s, $this->Name, 'UpdateUserBlogCount', 'An error occurred while updating the blog count.');
	}
	
	function UpdateUserCommentCount($UserID) {
		if ($this->Context->WarningCollector->Count() == 0) {
			$UserID = ForceInt($UserID, 0);
			
			if ($UserID == 0) $this->Context->ErrorManager->AddError($this->Context, $this->Name, 'UpdateUserCommentCount', 'User identifier not supplied');
			
			// Select the LastCommentPost, and CommentSpamCheck values from the user's profile
			$s = $this->Context->ObjectFactory->NewContextObject($this->Context, 'SqlBuilder');
			$s->SetMainTable('User', 'u');
			$s->AddSelect(array('LastCommentPost', 'CommentSpamCheck'), 'u');
			$s->AddWhere('u', 'UserID', '', $UserID, '=');
	
			$DateDiff = '';
			$CommentSpamCheck = 0;
			$result = $this->Context->Database->Select($s, $this->Name, 'UpdateUserCommentCount', 'An error occurred while retrieving user activity data.');
			while ($rows = $this->Context->Database->GetRow($result)) {
				$LastCommentPost = UnixTimestamp($rows['LastCommentPost']);
				$DateDiff = mktime() - $LastCommentPost;
				$CommentSpamCheck = ForceInt($rows['CommentSpamCheck'], 0);
			}
			
			// If a non-numeric value was returned, then this is the user's first post
			$SecondsSinceLastPost = ForceInt($DateDiff, 0);
			// If the LastCommentPost is less than 30 seconds ago 
			// and the CommentSpamCheck is greater than five, throw a warning
			if ($SecondsSinceLastPost < $this->Context->Configuration['COMMENT_THRESHOLD_PUNISHMENT'] && $CommentSpamCheck >= $this->Context->Configuration['COMMENT_POST_THRESHOLD'] && $DateDiff != '') {
				$this->Context->WarningCollector->Add(str_replace(array('//1', '//2', '//3'),
					array($this->Context->Configuration['COMMENT_POST_THRESHOLD'], $this->Context->Configuration['COMMENT_TIME_THRESHOLD'], $this->Context->Configuration['COMMENT_THRESHOLD_PUNISHMENT']),
					$this->Context->GetDefinition('ErrSpamComments')));
			}
	
			$s->Clear();
			$s->SetMainTable('User', 'u');
			if ($this->Context->WarningCollector->Count() == 0) {
				// make sure to update the 'datelastactive' field
            $s->AddFieldNameValue('DateLastActive', MysqlDateTime());
				$s->AddFieldNameValue('CountComments', $this->Context->DatabaseColumns['User']['CountComments'].'+1', 0);
				// If the LastCommentPost is less than 30 seconds ago 
				// and the DiscussionSpamCheck is less than 6, 
				// update the user profile and add 1 to the CommentSpamCheck
				if ($SecondsSinceLastPost == 0) {
					$s->AddFieldNameValue('LastCommentPost', MysqlDateTime());
				} elseif ($SecondsSinceLastPost < $this->Context->Configuration['COMMENT_TIME_THRESHOLD'] && $CommentSpamCheck <= $this->Context->Configuration['COMMENT_POST_THRESHOLD'] && $DateDiff != '') {
					$s->AddFieldNameValue('CommentSpamCheck', $this->Context->DatabaseColumns['User']['CommentSpamCheck'].'+1', 0);
				} else {
					// If the LastCommentPost is more than 60 seconds ago, 
					// set the CommentSpamCheck to 1, LastCommentPost to now(), 
					// and update the user profile
					$s->AddFieldNameValue('CommentSpamCheck', 1);
					$s->AddFieldNameValue('LastCommentPost', MysqlDateTime());
				}
				$s->AddWhere('u', 'UserID', '', $UserID, '=');
				$this->Context->Database->Update($s, $this->Name, 'UpdateUserCommentCount', 'An error occurred while updating the user profile.');
			} else {
				// Update the 'Waiting period' every time they try to post again
            $s->AddFieldNameValue('DateLastActive', MysqlDateTime());
				$s->AddFieldNameValue('LastCommentPost', MysqlDateTime());
				$s->AddWhere('u', 'UserID', '', $UserID, '=');
				$this->Context->Database->Update($s, $this->Name, 'UpdateUserCommentCount', 'An error occurred while updating the user profile.');
			}
		}
	
		return $this->Context->WarningCollector->Iif();	
	}
	
	function UpdateUserDiscussionCount($UserID) {
		if ($this->Context->WarningCollector->Iif()) {
			$UserID = ForceInt($UserID, 0);
			
			if ($UserID == 0) $this->Context->ErrorManager->AddError($this->Context, $this->Name, 'UpdateUserDiscussionCount', 'User identifier not supplied');
			
			// Select the LastDiscussionPost, and DiscussionSpamCheck values from the user's profile
			$s = $this->Context->ObjectFactory->NewContextObject($this->Context, 'SqlBuilder');
			$s->SetMainTable('User', 'u');
			$s->AddSelect(array('LastDiscussionPost', 'DiscussionSpamCheck'), 'u');
			$s->AddWhere('u', 'UserID', '', $UserID, '=');
			$DateDiff = '';
			$DiscussionSpamCheck = 0;
			$result = $this->Context->Database->Select($s, $this->Name, 'UpdateUserDiscussionCount', 'An error occurred while retrieving user activity data.');
			while ($rows = $this->Context->Database->GetRow($result)) {
				$LastDiscussionPost = UnixTimestamp($rows['LastDiscussionPost']);
				$DateDiff = mktime() - $LastDiscussionPost;
				$DiscussionSpamCheck = ForceInt($rows['DiscussionSpamCheck'], 0);
			}
			$SecondsSinceLastPost = ForceInt($DateDiff, 0);
			
			// If the LastDiscussionPost is less than 1 minute ago 
			// and the DiscussionSpamCheck is greater than three, throw a warning
			if ($SecondsSinceLastPost < $this->Context->Configuration['DISCUSSION_THRESHOLD_PUNISHMENT'] && $DiscussionSpamCheck >= $this->Context->Configuration['DISCUSSION_POST_THRESHOLD'] && $DateDiff != '') {
				$this->Context->WarningCollector->Add(str_replace(array('//1', '//2', '//3'),
					array($this->Context->Configuration['DISCUSSION_POST_THRESHOLD'], $this->Context->Configuration['DISCUSSION_TIME_THRESHOLD'], $this->Context->Configuration['DISCUSSION_THRESHOLD_PUNISHMENT']),
					$this->Context->GetDefinition('ErrSpamDiscussions')));
			}
			
			$s->Clear();
			$s->SetMainTable('User', 'u');
			if ($this->Context->WarningCollector->Count() == 0) {
            $s->AddFieldNameValue('DateLastActive', MysqlDateTime());
				$s->AddFieldNameValue('CountDiscussions', $this->Context->DatabaseColumns['User']['CountDiscussions'].'+1', 0);
				// If the LastDiscussionPost is less than 1 minute ago 
				// and the DiscussionSpamCheck is less than four, 
				// update the user profile and add 1 to the DiscussionSpamCheck
				if ($SecondsSinceLastPost < $this->Context->Configuration['DISCUSSION_TIME_THRESHOLD'] && $DiscussionSpamCheck <= $this->Context->Configuration['DISCUSSION_POST_THRESHOLD'] && $DateDiff != '') {
					$s->AddFieldNameValue('DiscussionSpamCheck', $this->Context->DatabaseColumns['User']['DiscussionSpamCheck'].'+1', 0);
				} else {
					// If the LastDiscussionPost is more than 1 minute ago, 
					// set the DiscussionSpamCheck to 1, LastDiscussionPost to now(), 
					// and update the user profile
					$s->AddFieldNameValue('DiscussionSpamCheck', 1);
					$s->AddFieldNameValue('LastDiscussionPost', MysqlDateTime());
				}
				$s->AddWhere('u', 'UserID', '', $UserID, '=');
				$this->Context->Database->Update($s, $this->Name, 'UpdateUserDiscussionCount', 'An error occurred while updating the user profile.');
			} else {
				// Update the 'Waiting period' every time they try to post again
            $s->AddFieldNameValue('DateLastActive', MysqlDateTime());
				$s->AddFieldNameValue('LastDiscussionPost', MysqlDateTime());
				$s->AddWhere('u', 'UserID', '', $UserID, '=');
				$this->Context->Database->Update($s, $this->Name, 'UpdateUserCommentCount', 'An error occurred while updating the user profile.');
			}
		}
		
		return $this->Context->WarningCollector->Iif();
	}
	
	// Constructor
	function UserManager(&$Context) {
		$this->Name = 'UserManager';
		$this->Delegation($Context);
	}	
	

	// Validates and formats User properties ensuring they're safe for database input
	// Returns: boolean value indicating success
	// Usage: $Boolean = $UserManager->ValidateUser($MyUser);
	function ValidateUser(&$User) {
		// First update the values so they are safe for db input
		$SafeUser = $User;
		$SafeUser->FormatPropertiesForDatabaseInput();

		// Instantiate a new validator for each field
		if ($this->Context->Configuration['ALLOW_NAME_CHANGE'] == '1') Validate($this->Context->GetDefinition('UsernameLower'), 1, $SafeUser->Name, 20, '', $this->Context);
		if ($this->Context->Configuration['ALLOW_EMAIL_CHANGE'] == '1') Validate($this->Context->GetDefinition('EmailLower'), 1, $SafeUser->Email, 200, '(.+)@(.+)\.(.+)', $this->Context);
		
		// Ensure the username isn't taken already
		$s = $this->Context->ObjectFactory->NewContextObject($this->Context, 'SqlBuilder');
		$s->SetMainTable('User', 'u');
		$s->AddSelect('UserID', 'u');
		$s->AddWhere('u', 'Name', '', $SafeUser->Name, '=');
		if ($User->UserID > 0) $s->AddWhere('u', 'UserID', '', $User->UserID, '<>');
		$MatchCount = 0;		
		$result = $this->Context->Database->Select($s, $this->Name, 'ValidateUser', 'A fatal error occurred while validating your input.');
		$MatchCount = $this->Context->Database->RowCount($result);
		
		if ($MatchCount > 0) $this->Context->WarningCollector->Add($this->Context->GetDefinition('ErrUsernameTaken'));
		
		// If validation was successful, then reset the properties to db safe values for saving
		if ($this->Context->WarningCollector->Count() == 0) $User = $SafeUser;
		
		return $this->Context->WarningCollector->Iif();
	}
	
	function ValidateUserCredentials($Username, $Password, $PersistentSession) {
		if ($Username == '') $this->Context->WarningCollector->Add($this->Context->GetDefinition('ErrInvalidUsername'));
		if ($Password == '') $this->Context->WarningCollector->Add($this->Context->GetDefinition('ErrInvalidPassword'));
		
		// Only continue if there have been no errors/warnings
		if ($this->Context->WarningCollector->Count() == 0) {
			$UserID = $this->Context->Authenticator->Authenticate($Username, $Password, $PersistentSession);
			if ($UserID == -2) $this->Context->ErrorManager->AddError($this->Context, $this->Name, 'ValidateUserCredentials', 'An error occurred while validating your credentials.');
			if ($UserID == -1) $this->Context->WarningCollector->Add($this->Context->GetDefinition('ErrNoLogin'));
			if ($UserID == 0) $this->Context->WarningCollector->Add($this->Context->GetDefinition('ErrUserCombination'));
			if ($UserID > 0) $this->Context->Session->Start($this->Context, $this->Context->Authenticator, $UserID);
		}
		return $this->Context->WarningCollector->Iif();
	}	
	
	function VerifyPasswordResetRequest($VerificationUserID, $EmailVerificationKey) {
		$VerificationUserID = ForceInt($VerificationUserID, 0);
		$EmailVerificationKey = ForceString($EmailVerificationKey, '');
		$EmailVerificationKey = FormatStringForDatabaseInput($EmailVerificationKey);
		
		// Attempt to retrieve email address
		$s = $this->Context->ObjectFactory->NewContextObject($this->Context, 'SqlBuilder');
		$s->SetMainTable('User', 'u');
		$s->AddSelect('UserID', 'u');
		$s->AddWhere('u', 'UserID', '', $VerificationUserID, '=');
		$s->AddWhere('u', 'EmailVerificationKey', '', $EmailVerificationKey, '=');
		$UserResult = $this->Context->Database->Select($s, $this->Name, 'VerifyPasswordResetRequest', 'An error occurred while retrieving account information.');
		if ($this->Context->Database->RowCount($UserResult) == 0) $this->Context->WarningCollector->Add($this->Context->GetDefinition('ErrPasswordResetRequest'));
		return $this->Context->WarningCollector->Iif();
	}	
}
?>