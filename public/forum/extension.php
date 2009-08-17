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
* Description: A blank page for extensions
*/

include('appg/settings.php');
$Configuration['SELF_URL'] = 'extension.php';
include('appg/init_vanilla.php');

// 1. DEFINE VARIABLES AND PROPERTIES SPECIFIC TO THIS PAGE

	// Ensure the user is allowed to view this page
	$Context->Session->Check($Context);
   
   $Head->BodyId = 'ExtensionPage';
	
// 2. BUILD PAGE CONTROLS
	$PostBackAction = ForceIncomingString('PostBackAction', '');
	if ($PostBackAction == '') {
		$NoticeCollector->AddNotice($Context->GetDefinition('AboutExtensionPage'));
	}

// 3. ADD CONTROLS TO THE PAGE

	$Page->AddRenderControl($Head, $Configuration['CONTROL_POSITION_HEAD']);
	$Page->AddRenderControl($Menu, $Configuration['CONTROL_POSITION_MENU']);
	$Page->AddRenderControl($Panel, $Configuration['CONTROL_POSITION_PANEL']);
	$Page->AddRenderControl($NoticeCollector, $Configuration['CONTROL_POSITION_NOTICES']);
	$Page->AddRenderControl($Foot, $Configuration['CONTROL_POSITION_FOOT']);
	$Page->AddRenderControl($PageEnd, $Configuration['CONTROL_POSITION_PAGE_END']);

// 4. FIRE PAGE EVENTS

	$Page->FireEvents();

?>