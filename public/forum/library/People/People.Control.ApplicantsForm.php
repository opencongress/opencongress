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
* Description: The ApplicantsForm control is used to accept or decline applicants in a batch process.
*/

class ApplicantsForm extends PostBackControl {
	
	var $ApplicantData;
		
	function ApplicantsForm(&$Context) {
      $this->Name = "ApplicantsForm";
		$this->ValidActions = array("Applicants", "ProcessApplicants");
		$this->Constructor($Context);
		if (!$this->Context->Session->User->Permission("PERMISSION_APPROVE_APPLICANTS")) {
			$this->IsPostBack = 0;
		} elseif ($this->IsPostBack) {
			$this->Context->PageTitle = $this->Context->GetDefinition('MembershipApplicants');
         
         // See if the form has been submitted
         if ($this->PostBackAction == 'ProcessApplicants' && $this->IsValidFormPostBack()) {
            $Action = ForceIncomingString('btnSubmit', '');
            // Compare to language dictionary to figure out exactly what should be done
            if ($Action != '') $Action = ($Context->GetDefinition('ApproveForMembership') == $Action) ? 'Approve' : 'Decline';
            // Retrieve the id's to manipulate
            $ApplicantIDs = ForceIncomingArray('ApplicantID', array());
            
            // Approve or decline the applicants
            if ($Action != '' && is_array($ApplicantIDs) && count($ApplicantIDs) > 0) {
               $um = $this->Context->ObjectFactory->NewContextObject($this->Context, 'UserManager');
               if ($Action == 'Approve') {
                  $um->ApproveApplicant($ApplicantIDs);
               } else {
                  $um->RemoveApplicant($ApplicantIDs);
               }
            }
         }
         
         // There is no need to load all of the applicants since they were already loaded by the settings.php page
         // $um = $this->Context->ObjectFactory->NewContextObject($this->Context, 'UserManager');
         // $this->ApplicantData = $um->GetUsersByRoleId(0);
		}
      $this->CallDelegate("Constructor");
	}
	
	function Render() {
		if ($this->IsPostBack) {
			$this->CallDelegate("PreRender");
         $this->PostBackParams->Set('PostBackAction', 'ProcessApplicants');
			include(ThemeFilePath($this->Context->Configuration, 'settings_applicants_form.php'));
			$this->CallDelegate("PostRender");
		}
	}
}
?>