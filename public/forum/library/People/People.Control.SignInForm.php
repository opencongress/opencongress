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
* Description: The SignInForm control is used to validate a user's credentials and create a session.
*/

class SignInForm extends PostBackControl {
	var $Username;
	var $Password;
	var $RememberMe;
	var $FormName;
	var $ApplicantCount;		// The number of applicants currently awaiting approval
   var $ReturnUrl;
	
	function SignInForm(&$Context, $FormName) {
		$this->Name = 'SignInForm';
		$this->ValidActions = array('SignIn');
		$this->Constructor($Context);
				
		if ($this->PostBackAction == '') $this->IsPostBack = 1;
		
		if ($this->IsPostBack) {
			$this->FormName = $FormName;
			$this->ReturnUrl = urldecode(ForceIncomingString('ReturnUrl', ''));
			if ($this->ReturnUrl != '') $this->PostBackParams->Add('ReturnUrl', $this->ReturnUrl);
			$this->Username = ForceIncomingString('Username', '');
			$this->Password = ForceIncomingString('Password', '');
			$this->RememberMe = ForceIncomingBool('RememberMe', 0);
			
			// Set up the page
			global $Banner, $Foot;
			$Banner->Properties['CssClass'] = 'SignIn';
			$Foot->CssClass = 'SignIn';
			$this->Context->PageTitle = $this->Context->GetDefinition('SignIn');			

			if ($this->PostBackAction == 'SignIn') {

				$UserManager = $this->Context->ObjectFactory->NewContextObject($this->Context, 'UserManager');
				
				// Check for an already active session
				if ($this->Context->Session->UserID != 0) {
					$this->PostBackValidated = 1;
				} else {
					// Attempt to create a new session for the user
					if ($UserManager->ValidateUserCredentials($this->Username, $this->Password, $this->RememberMe)) {
						$this->PostBackValidated = 1;
						// Automatically redirect if this user isn't a user administrator or there aren't any new applicants
                  $AutoRedirect = 1;
						if ($this->Context->Session->User->Permission('PERMISSION_APPROVE_APPLICANTS')) {
							$this->ApplicantCount = $UserManager->GetApplicantCount();
							if ($this->ApplicantCount > 0) $AutoRedirect = 0;
						}
						if ($this->ReturnUrl == '') {
							$this->ReturnUrl = $this->Context->Configuration['FORWARD_VALIDATED_USER_URL'];
						} else {
							$this->ReturnUrl = str_replace('&amp;', '&', $this->ReturnUrl);
						}
                  if ($AutoRedirect && $this->ReturnUrl != '') {
							header('location: '.$this->ReturnUrl);
							// die();
						}
					}
				}				
			} 
			$this->Context->BodyAttributes = " onload=\"Focus('txtUsername');\"";
		}
	}
	
	function Render_ValidPostBack() {
		$this->CallDelegate('PreValidPostBackRender');
		include(ThemeFilePath($this->Context->Configuration, 'people_signin_form_validpostback.php'));
		$this->CallDelegate('PostValidPostBackRender');
	}
	
	function Render_NoPostBack() {
		$this->Username = FormatStringForDisplay($this->Username, 1);
		$this->PostBackParams->Add('PostBackAction', 'SignIn');
		$this->PostBackParams->Add('ReturnUrl', $this->ReturnUrl);
		
		$this->CallDelegate('PreNoPostBackRender');
		include(ThemeFilePath($this->Context->Configuration, 'people_signin_form_nopostback.php'));
		$this->CallDelegate('PostNoPostBackRender');
	}
	
	// Because this form switches the user from having no session to having a session,
   // I need to override the default render method of the PostBackForm control so
   // that it doesn't check for a PostBackKey
	function Render() {
		if ($this->IsPostBack) {
			$this->CallDelegate('PreRender');
			// Call different render methods based on the PostBack state.
			if ($this->PostBackValidated) {
				$this->Render_ValidPostBack();
			} else {
				$this->Render_NoPostBack();
			}
			$this->CallDelegate('PostRender');
		}
	}   
}
?>