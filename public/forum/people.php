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
* Description: Web form that handles user sign-ins
*/

include("appg/settings.php");
$Configuration['SELF_URL'] = 'people.php';
include("appg/init_people.php");

// Define properties of the page controls that are specific to this page
$SignInForm = $Context->ObjectFactory->CreateControl($Context, "SignInForm", "frmSignIn");
$Leave = $Context->ObjectFactory->CreateControl($Context, "Leave");
$ApplyForm = $Context->ObjectFactory->CreateControl($Context, "ApplyForm", "ApplicationForm");
$PasswordRequestForm = $Context->ObjectFactory->CreateControl($Context, "PasswordRequestForm", "PasswordRequestForm");
$PasswordResetForm = $Context->ObjectFactory->CreateControl($Context, "PasswordResetForm", "PasswordResetForm");

// Add the controls to the page
$Page->AddRenderControl($Head, $Configuration["CONTROL_POSITION_HEAD"]);
$Page->AddRenderControl($Banner, $Configuration["CONTROL_POSITION_BANNER"]);
$Page->AddRenderControl($SignInForm, $Configuration["CONTROL_POSITION_BODY_ITEM"]);
$Page->AddRenderControl($Leave, $Configuration["CONTROL_POSITION_BODY_ITEM"]);
$Page->AddRenderControl($ApplyForm, $Configuration["CONTROL_POSITION_BODY_ITEM"]);
$Page->AddRenderControl($PasswordRequestForm, $Configuration["CONTROL_POSITION_BODY_ITEM"]);
$Page->AddRenderControl($PasswordResetForm, $Configuration["CONTROL_POSITION_BODY_ITEM"]);
$Page->AddRenderControl($Foot, $Configuration["CONTROL_POSITION_FOOT"]);
$Page->AddRenderControl($PageEnd, $Configuration["CONTROL_POSITION_PAGE_END"]);

// 4. FIRE PAGE EVENTS
$Page->FireEvents();
?>
