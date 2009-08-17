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
* Description: Display and manipulate discussions
*/

include("appg/settings.php");
$Configuration['SELF_URL'] = 'index.php';
include("appg/init_vanilla.php");

// 1. DEFINE VARIABLES AND PROPERTIES SPECIFIC TO THIS PAGE

	// Ensure the user is allowed to view this page
	$Context->Session->Check($Context);
	
	// Define properties of the page controls that are specific to this page
   $Head->BodyId = 'DiscussionsPage';
	$Menu->CurrentTab = 'discussions';
	$Panel->CssClass = 'DiscussionPanel';
   $Panel->BodyCssClass = 'Discussions';

// 2. BUILD PAGE CONTROLS
	$DiscussionGrid = $Context->ObjectFactory->CreateControl($Context, 'DiscussionGrid');
	// Add an update reminder if necessary
	if ($Configuration['UPDATE_REMINDER'] != '') {
		if ($Context->Session->User && $Context->Session->User->Permission('PERMISSION_CHECK_FOR_UPDATES')) {
			$ShowUpdateMessage = 0;
			$LastUpdate = $Configuration['LAST_UPDATE'];
			if ($LastUpdate == '') $LastUpdate = time();
			$Difference = time() - $LastUpdate;
			$Days = floor($Difference/60/60/24);
			if ($Configuration['LAST_UPDATE'] == '') {
				$ShowUpdateMessage = 1;
			} elseif ($Configuration['UPDATE_REMINDER'] == 'Weekly') {
				if ($Days > 7) $ShowUpdateMessage = 1;
			} elseif ($Configuration['UPDATE_REMINDER'] == 'Monthly') {
				if ($Days > 30) $ShowUpdateMessage = 1;
			} elseif ($Configuration['UPDATE_REMINDER'] == 'Quarterly') {
				if ($Days > 90) $ShowUpdateMessage = 1;
			}
			
			if ($ShowUpdateMessage) {
				$Message = '';
				if ($Days == 0) {
					$Message = $Context->GetDefinition('NeverCheckedForUpdates');
				} else {
					$Message = str_replace('//1', $Days, $Context->GetDefinition('XDaysSinceUpdateCheck'));
				}
				$NoticeCollector->AddNotice($Message.' <a href="'.GetUrl($Configuration, 'settings.php', '', '', '', '', 'PostBackAction=UpdateCheck').'">'.$Context->GetDefinition('CheckForUpdatesNow').'</a>');
			}
		}
	}
   
	// Remind them to get addons if this is a new install
   if ($Configuration['ADDON_NOTICE']) {
		if ($Context->Session->User && $Context->Session->User->Permission('PERMISSION_MANAGE_EXTENSIONS')) {
			$HideNotice = ForceIncomingBool('TurnOffAddonNotice', 0);
			if ($HideNotice) {
				$SettingsFile = $Configuration['APPLICATION_PATH'].'conf/settings.php';
				$SettingsManager = $Context->ObjectFactory->NewContextObject($Context, 'ConfigurationManager');
				$SettingsManager->DefineSetting("ADDON_NOTICE", '0', 1);
				$SettingsManager->SaveSettingsToFile($SettingsFile);
			} else {
				$NoticeCollector->AddNotice('<span><a href="'.GetUrl($Configuration, 'index.php', '', '', '', '', 'TurnOffAddonNotice=1').'">'.$Context->GetDefinition('RemoveThisNotice').'</a></span>
					'.$Context->GetDefinition('WelcomeToVanillaGetSomeAddons'));
			}
		}
	}

// 3. ADD CONTROLS TO THE PAGE

	$Page->AddRenderControl($Head, $Configuration['CONTROL_POSITION_HEAD']);
	$Page->AddRenderControl($Menu, $Configuration['CONTROL_POSITION_MENU']);
	$Page->AddRenderControl($Panel, $Configuration['CONTROL_POSITION_PANEL']);
	$Page->AddRenderControl($NoticeCollector, $Configuration['CONTROL_POSITION_NOTICES']);
	$Page->AddRenderControl($DiscussionGrid, $Configuration['CONTROL_POSITION_BODY_ITEM']);
	$Page->AddRenderControl($Foot, $Configuration['CONTROL_POSITION_FOOT']);
	$Page->AddRenderControl($PageEnd, $Configuration['CONTROL_POSITION_PAGE_END']);

// 4. FIRE PAGE EVENTS

	$Page->FireEvents();

?>