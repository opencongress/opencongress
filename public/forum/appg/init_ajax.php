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
include($Configuration['LIBRARY_PATH'].$Configuration['AUTHENTICATION_MODULE']);
include($Configuration['LIBRARY_PATH'].'People/People.Class.Session.php');
include($Configuration['LIBRARY_PATH'].'People/People.Class.User.php');

$Context = new Context($Configuration);
$Context->DatabaseTables = &$DatabaseTables;
$Context->DatabaseColumns = &$DatabaseColumns;

// Start the session management
$Context->StartSession();

$Context->Session->Check($Context);

// DEFINE THE LANGUAGE DICTIONARY
include($Configuration['LANGUAGES_PATH'].$Configuration['LANGUAGE'].'/definitions.php');
include($Configuration['APPLICATION_PATH'].'conf/language.php');

// INSTANTIATE THE PAGE OBJECT
$Page = $Context->ObjectFactory->NewContextObject($Context, 'Page', $Configuration['PAGE_EVENTS']);

// FIRE INITIALIZATION EVENT
$Page->FireEvent('Page_Init');

// INCLUDE EXTENSIONS
// 2006-06-16 - Extensions are no long included here because bad extensions were causing standard ajax features to break.
// include($Configuration['APPLICATION_PATH'].'conf/extensions.php');
?>