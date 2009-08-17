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
* Description: File used by Dynamic Data Management object to block/unblock categories
*/

include('../appg/settings.php');
include('../appg/init_ajax.php');
$PostBackKey = ForceIncomingString('PostBackKey', '');
$ExtensionKey = ForceIncomingString('ExtensionKey', '');
if ($PostBackKey != '' && $PostBackKey == $Context->Session->GetVariable('SessionPostBackKey', 'string')) {
	$Block = ForceIncomingBool('Block', 0);
	$BlockCategoryID = ForceIncomingInt('BlockCategoryID', 0);
	
	if ($BlockCategoryID > 0) {
		$um = $Context->ObjectFactory->NewContextObject($Context, 'UserManager');
		if ($Block) {
			$um->AddCategoryBlock($BlockCategoryID);
		} else {
			$um->RemoveCategoryBlock($BlockCategoryID);
		}
	}
	
	// Report success
	echo 'Complete';
} else {
	echo $Context->GetDefinition('ErrPostBackKeyInvalid');
}
$Context->Unload();
?>