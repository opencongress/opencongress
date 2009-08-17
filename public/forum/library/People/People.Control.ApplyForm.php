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
* Description: The ApplyForm control allows new users to apply for membership.
*/

class ApplyForm extends PostBackControl {
   var $Applicant;			// A user object for the applying user
   var $FormName;				// The name of this form
	
	function ApplyForm(&$Context, $FormName = '') {
		$this->Name = 'ApplyForm';
		$this->ValidActions = array('ApplyForm', 'Apply');
		$this->Constructor($Context);
		
		if ($this->IsPostBack) {
			// Set up the page
			global $Banner, $Foot;
			$Banner->Properties['CssClass'] = 'Apply';
			$Foot->CssClass = 'Apply';
			$this->Context->PageTitle = $this->Context->GetDefinition('ApplyForMembership');
			$this->FormName = $FormName;
			
			$this->Applicant = $Context->ObjectFactory->NewContextObject($Context, 'User');
			$this->Applicant->GetPropertiesFromForm();
			$this->CallDelegate('Constructor');
	
			if ($this->PostBackAction == 'Apply') {
				$um = $this->Context->ObjectFactory->NewContextObject($this->Context, 'UserManager');
				
				$this->CallDelegate('PreCreateUser');
				
				$this->PostBackValidated = $um->CreateUser($this->Applicant);
				
				$this->CallDelegate('PostCreateUser');
				
				// Sign them in
				if ($this->PostBackValidated && $this->Applicant->UserID > 0) {
					if ($this->Context->Configuration['ALLOW_IMMEDIATE_ACCESS']) {
						$this->Context->Authenticator->AssignSessionUserID($this->Applicant->UserID);
						header('location: '.$this->Context->Configuration['FORWARD_VALIDATED_USER_URL']);
						die();
					} else {
						// Do nothing and let the postbackvalidated template be displayed
					}
				}
			} 
			$this->CallDelegate('LoadData');
		}
	}
	
	function Render_NoPostBack() {
		$this->Applicant->FormatPropertiesForDisplay();
		$this->PostBackParams->Add('PostBackAction', 'Apply');
		$this->PostBackParams->Add('ReadTerms', $this->Applicant->ReadTerms);
		$this->CallDelegate('PreNoPostBackRender');
		include(ThemeFilePath($this->Context->Configuration, 'people_apply_form_nopostback.php'));
		$this->CallDelegate('PostNoPostBackRender');
	}
	
	function Render_ValidPostBack() {
		$this->CallDelegate('PreValidPostBackRender');
		include(ThemeFilePath($this->Context->Configuration, 'people_apply_form_validpostback.php'));
		$this->CallDelegate('PostValidPostBackRender');
	}
}
?>