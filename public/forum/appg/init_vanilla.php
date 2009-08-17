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
* Description: Constants and objects specific to forum pages.
*/
// Make sure this file was not accessed directly and prevent register_globals configuration array attack
if (!defined('IN_VANILLA')) exit();

// GLOBAL INCLUDES
include($Configuration['APPLICATION_PATH'].'appg/headers.php');
include($Configuration['APPLICATION_PATH'].'appg/database.php');
include($Configuration['DATABASE_PATH']);
include($Configuration['LIBRARY_PATH'].'Framework/Framework.Functions.php');
include($Configuration['LIBRARY_PATH'].'Framework/Framework.Class.Database.php');
include($Configuration['LIBRARY_PATH'].'Framework/Framework.Class.'.$Configuration['DATABASE_SERVER'].'.php');
include($Configuration['LIBRARY_PATH'].'Framework/Framework.Class.SqlBuilder.php');
include($Configuration['LIBRARY_PATH'].'Framework/Framework.Class.MessageCollector.php');
include($Configuration['LIBRARY_PATH'].'Framework/Framework.Class.ErrorManager.php');
include($Configuration['LIBRARY_PATH'].'Framework/Framework.Class.ObjectFactory.php');
include($Configuration['LIBRARY_PATH'].'Framework/Framework.Class.StringManipulator.php');
include($Configuration['LIBRARY_PATH'].'Framework/Framework.Class.Context.php');
include($Configuration['LIBRARY_PATH'].'Framework/Framework.Class.Delegation.php');
include($Configuration['LIBRARY_PATH'].'Framework/Framework.Class.Control.php');
include($Configuration['LIBRARY_PATH'].'Vanilla/Vanilla.Functions.php');
include($Configuration['LIBRARY_PATH'].$Configuration['AUTHENTICATION_MODULE']);
include($Configuration['LIBRARY_PATH'].'People/People.Class.Session.php');
include($Configuration['LIBRARY_PATH'].'People/People.Class.User.php');

// INSTANTIATE THE CONTEXT OBJECT
// The context object handles the following:
// - Open a connection to the database
// - Create a user session (autologging in any user with valid cookie credentials)
// - Instantiate debug and warning collectors
// - Instantiate an error manager
// - Define global variables relative to the current context (SelfUrl

$Context = new Context($Configuration);
$Context->DatabaseTables = &$DatabaseTables;
$Context->DatabaseColumns = &$DatabaseColumns;

// Start the session management
$Context->StartSession();

// DEFINE THE LANGUAGE DICTIONARY
include($Configuration['LANGUAGES_PATH'].$Configuration['LANGUAGE'].'/definitions.php');
include($Configuration['APPLICATION_PATH'].'conf/language.php');
// By cleaning the output buffer and restarting, it makes downloading work
// properly with utf-8 encoding (this was a bug in previous versions).
// http://lussumo.com/community/discussion/4442/
ob_end_clean();
ob_start();

// INSTANTIATE THE PAGE OBJECT
// The page object handles collecting all page controls
// and writing them when it's events are fired.
$Page = $Context->ObjectFactory->NewContextObject($Context, 'Page', $Configuration['PAGE_EVENTS']);

// FIRE INITIALIZATION EVENT
$Page->FireEvent('Page_Init');

// DEFINE THE MASTER PAGE CONTROLS
$Head = $Context->ObjectFactory->CreateControl($Context, 'Head');
$Menu = $Context->ObjectFactory->CreateControl($Context, 'Menu');
$Panel = $Context->ObjectFactory->CreateControl($Context, 'Panel');
$NoticeCollector = $Context->ObjectFactory->CreateControl($Context, 'NoticeCollector');
$Foot = $Context->ObjectFactory->CreateControl($Context, 'Filler', 'foot.php');
$PageEnd = $Context->ObjectFactory->CreateControl($Context, 'PageEnd');

// BUILD THE PAGE HEAD
// Every page will require some basic definitions for the header.
$Head->AddScript('js/global.js');
$Head->AddScript('js/vanilla.js');
$Head->AddScript('js/ajax.js');
$Head->AddScript('js/ac.js');
$Head->AddStyleSheet($Context->StyleUrl.'vanilla.css', 'screen', 100, '');
$Head->AddStyleSheet($Context->StyleUrl.'vanilla.print.css', 'print', 101, '');

// BUILD THE MAIN MENU
$Menu->AddTab($Context->GetDefinition('Discussions'), 'discussions', GetUrl($Configuration, './'), '', $Configuration['TAB_POSITION_DISCUSSIONS']);
if ($Configuration['USE_CATEGORIES']) $Menu->AddTab($Context->GetDefinition('Categories'), 'categories', GetUrl($Configuration, 'categories.php'), '', $Configuration['TAB_POSITION_CATEGORIES']);
$Menu->AddTab($Context->GetDefinition('Search'), 'search', GetUrl($Configuration, 'search.php'), '', $Configuration['TAB_POSITION_SEARCH']);
if ($Context->Session->UserID > 0) {
	// Make sure they should be seeing the settings tab
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
		
	$RequiredPermissionsCount = count($RequiredPermissions);
	$i = 0;
	for ($i = 0; $i < $RequiredPermissionsCount; $i++) {
		if ($Context->Session->User->Permission($RequiredPermissions[$i])) {
			$Menu->AddTab($Context->GetDefinition('Settings'), 'settings', GetUrl($Configuration, 'settings.php'), '', $Configuration['TAB_POSITION_SETTINGS']);
			break;
		}
	}

	// Add the account tab   
	$Menu->AddTab($Context->GetDefinition('Account'), 'account', GetUrl($Configuration, 'account.php'), '', $Configuration['TAB_POSITION_ACCOUNT']);
}

// Define the context object's passthru variables
$Context->PassThruVars['SetBookmarkOnClick'] = '';

// INCLUDE EXTENSIONS
include($Configuration['APPLICATION_PATH'].'conf/extensions.php');

$Panel->AddString($Context->GetDefinition('PanelFooter'), 500);

// Make sure to get all delegates from the extensions into objects which were
// constructed before the extensions were loaded.
$Head->GetDelegatesFromContext();
$Menu->GetDelegatesFromContext();
$Panel->GetDelegatesFromContext();
$NoticeCollector->GetDelegatesFromContext();
$Foot->GetDelegatesFromContext();
$PageEnd->GetDelegatesFromContext();

// If the sign-in and sign-out urls have not been modified from their default
// values, concatenate them with the web root so that they link correctly if
// mod_rewrite is on.
if ($Configuration['SIGNIN_URL'] == 'people.php') $Configuration['SIGNIN_URL'] = $Configuration['WEB_ROOT'].$Configuration['SIGNIN_URL'];
if ($Configuration['SIGNOUT_URL'] == 'people.php?PostBackAction=SignOutNow') $Configuration['SIGNOUT_URL'] = $Configuration['WEB_ROOT'].$Configuration['SIGNOUT_URL'];
?>