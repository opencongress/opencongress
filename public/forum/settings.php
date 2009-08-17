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
* Description: Web forms that handle manipulating user & application settings
*/

include('appg/settings.php');
$Configuration['SELF_URL'] = 'settings.php';
include('appg/init_vanilla.php');

// Ensure the user is allowed to view this page (they must have at least one of the following permissions)
$RequiredPermissions = array('PERMISSION_CHECK_FOR_UPDATES',
	'PERMISSION_APPROVE_APPLICANTS',
	'PERMISSION_MANAGE_REGISTRATION',
	'PERMISSION_ADD_ROLES',
	'PERMISSION_EDIT_ROLES',
	'PERMISSION_REMOVE_ROLES',
	'PERMISSION_ADD_CATEGORIES',
	'PERMISSION_EDIT_CATEGORIES',
	'PERMISSION_REMOVE_CATEGORIES',
	'PERMISSION_SORT_CATEGORIES',
	'PERMISSION_CHANGE_APPLICATION_SETTINGS',
	'PERMISSION_MANAGE_EXTENSIONS',
	'PERMISSION_MANAGE_LANGUAGE',
	'PERMISSION_MANAGE_STYLES',
	'PERMISSION_MANAGE_THEMES');
$Allowed = 0;
$RequiredPermissionsCount = count($RequiredPermissions);
$i = 0;
for ($i = 0; $i < $RequiredPermissionsCount; $i++) {
	if ($Context->Session->User->Permission($RequiredPermissions[$i])) {
		$Allowed = 1;
		break;
	}
}
if (!$Allowed) header('location:'.GetUrl($Configuration, 'index.php'));

// 1. DEFINE VARIABLES AND PROPERTIES SPECIFIC TO THIS PAGE

	$Head->BodyId = 'SettingsPage';
   $Menu->CurrentTab = 'settings';
   $Panel->CssClass = 'SettingsPanel';
   $Panel->BodyCssClass = 'SettingsPageBody';
   if ($Context->PageTitle == '') $Context->PageTitle = $Context->GetDefinition('AdministrativeSettings');

// 2. BUILD PAGE CONTROLS

   // Build the control panel
	$AdminOptions = $Context->GetDefinition('AdministrativeOptions');
   $Panel->AddList($AdminOptions, 20);
	if ($Context->Session->User->Permission('PERMISSION_CHANGE_APPLICATION_SETTINGS')) $Panel->AddListItem($AdminOptions, $Context->GetDefinition('ApplicationSettings'), GetUrl($Configuration, 'settings.php', '', '', '', '', 'PostBackAction=Globals'), '', '', 10);
	if ($Context->Session->User->Permission('PERMISSION_CHECK_FOR_UPDATES')) $Panel->AddListItem($AdminOptions, $Context->GetDefinition('UpdatesAndReminders'), GetUrl($Configuration, 'settings.php', '', '', '', '', 'PostBackAction=UpdateCheck'), '', '', 20);
	if ($Context->Session->User->Permission('PERMISSION_MANAGE_EXTENSIONS')) $Panel->AddListItem($AdminOptions, $Context->GetDefinition('ManageExtensions'), GetUrl($Configuration, 'settings.php', '', '', '', '', 'PostBackAction=Extensions'), '', '', 60);
	if ($Context->Session->User->Permission('PERMISSION_MANAGE_THEMES')
		|| $Context->Session->User->Permission('PERMISSION_MANAGE_STYLES')) $Panel->AddListItem($AdminOptions, $Context->GetDefinition('ManageThemeAndStyle'), GetUrl($Configuration, 'settings.php', '', '', '', '', 'PostBackAction=ThemeChange'), '', '', 70);
	if ($Context->Session->User->Permission('PERMISSION_MANAGE_LANGUAGE')) $Panel->AddListItem($AdminOptions, $Context->GetDefinition('LanguageManagement'), GetUrl($Configuration, 'settings.php', '', '', '', '', 'PostBackAction=LanguageChange'), '', '', 80);
	if ($Context->Session->User->Permission('PERMISSION_ADD_ROLES')
		|| $Context->Session->User->Permission('PERMISSION_EDIT_ROLES')
		|| $Context->Session->User->Permission('PERMISSION_REMOVE_ROLES')) $Panel->AddListItem($AdminOptions, $Context->GetDefinition('RoleManagement'), GetUrl($Configuration, 'settings.php', '', '', '', '', 'PostBackAction=Roles'), '', '', 30);
		
	if ($Context->Configuration['USE_CATEGORIES']
		&& ($Context->Session->User->Permission('PERMISSION_ADD_CATEGORIES')
			|| $Context->Session->User->Permission('PERMISSION_EDIT_CATEGORIES')
			|| $Context->Session->User->Permission('PERMISSION_REMOVE_CATEGORIES')
			|| $Context->Session->User->Permission('PERMISSION_SORT_CATEGORIES')
			)
		) $Panel->AddListItem($AdminOptions, $Context->GetDefinition('CategoryManagement'), GetUrl($Configuration, 'settings.php', '', '', '', '', 'PostBackAction=Categories'), '', '', 50);
		
	if ($Context->Session->User->Permission('PERMISSION_MANAGE_REGISTRATION')) $Panel->AddListItem($AdminOptions, $Context->GetDefinition('RegistrationManagement'), GetUrl($Configuration, 'settings.php', '', '', '', '', 'PostBackAction=RegistrationChange'), '', '', 40);
	   
   // Create the default view
   $SettingsHelp = $Context->ObjectFactory->CreateControl($Context, 'SettingsHelp');

   // Forms
   $CategoryForm = $Context->ObjectFactory->CreateControl($Context, 'CategoryForm');
   $RoleForm = $Context->ObjectFactory->CreateControl($Context, 'RoleForm');
   $GlobalsForm = $Context->ObjectFactory->CreateControl($Context, 'GlobalsForm');
   $UpdateCheck = $Context->ObjectFactory->CreateControl($Context, 'UpdateCheck');
   $ExtensionForm = $Context->ObjectFactory->CreateControl($Context, 'ExtensionForm');
   $ThemeAndStyleForm = $Context->ObjectFactory->CreateControl($Context, 'ThemeAndStyleForm');
   $RegistrationForm = $Context->ObjectFactory->CreateControl($Context, 'RegistrationForm');
   $LanguageForm = $Context->ObjectFactory->CreateControl($Context, 'LanguageForm');
	$ApplicantsForm = $Context->ObjectFactory->CreateControl($Context, 'ApplicantsForm');
	$ApplicantData = false;
	if ($Context->Session->User->Permission('PERMISSION_APPROVE_APPLICANTS') && !$Configuration['ALLOW_IMMEDIATE_ACCESS']) {
		$UserManager = $Context->ObjectFactory->NewContextObject($Context, 'UserManager');
		$ApplicantData = $UserManager->GetUsersByRoleID(0);
		$ApplicantCount = $Context->Database->RowCount($ApplicantData);
		$ApplicantsForm->ApplicantData = $ApplicantData;
		$Panel->AddListItem($AdminOptions, $Context->GetDefinition('MembershipApplicants'), GetUrl($Configuration, 'settings.php', '', '', '', '', 'PostBackAction=Applicants'), $ApplicantCount.' '.$Context->GetDefinition('New'), '', 100);
	}

// 3. ADD CONTROLS TO THE PAGE

	$Page->AddRenderControl($Head, $Configuration['CONTROL_POSITION_HEAD']);
	$Page->AddRenderControl($Menu, $Configuration['CONTROL_POSITION_MENU']);
	$Page->AddRenderControl($Panel, $Configuration['CONTROL_POSITION_PANEL']);
	$Page->AddRenderControl($NoticeCollector, $Configuration['CONTROL_POSITION_NOTICES']);
	$Page->AddRenderControl($SettingsHelp, $Configuration['CONTROL_POSITION_BODY_ITEM']);
	$Page->AddRenderControl($CategoryForm, $Configuration['CONTROL_POSITION_BODY_ITEM'] + 10);
	$Page->AddRenderControl($RoleForm, $Configuration['CONTROL_POSITION_BODY_ITEM'] + 20);
	$Page->AddRenderControl($GlobalsForm, $Configuration['CONTROL_POSITION_BODY_ITEM'] + 30);
	$Page->AddRenderControl($UpdateCheck, $Configuration['CONTROL_POSITION_BODY_ITEM'] + 40);
	$Page->AddRenderControl($ExtensionForm, $Configuration['CONTROL_POSITION_BODY_ITEM'] + 50);
	$Page->AddRenderControl($ThemeAndStyleForm, $Configuration['CONTROL_POSITION_BODY_ITEM'] + 60);
	$Page->AddRenderControl($RegistrationForm, $Configuration['CONTROL_POSITION_BODY_ITEM'] + 70);
	$Page->AddRenderControl($LanguageForm, $Configuration['CONTROL_POSITION_BODY_ITEM'] + 80);
	$Page->AddRenderControl($ApplicantsForm, $Configuration['CONTROL_POSITION_BODY_ITEM'] + 90);
	$Page->AddRenderControl($Foot, $Configuration['CONTROL_POSITION_FOOT']);
	$Page->AddRenderControl($PageEnd, $Configuration['CONTROL_POSITION_PAGE_END']);
   

// 4. FIRE PAGE EVENTS

   $Page->FireEvents();
   
?>