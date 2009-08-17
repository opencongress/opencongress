<?php
// Note: This file is included from the library/People/People.Control.ApplicantsForm.php control.

echo '<div id="Form" class="Account Extensions Applicants">';
   if ($this->PostBackAction == 'ProcessApplicants' && $this->Context->WarningCollector->Count() == 0) echo '<div id="Success">'.$this->Context->GetDefinition('ChangesSaved').'</div>';
   echo '<fieldset>
      <legend>'.$this->Context->GetDefinition('MembershipApplicants').'</legend>
      '.$this->Get_Warnings().'
      '.$this->Get_PostBackForm('frmApplicants').'
      <p>'.$this->Context->GetDefinition('ApplicantsNotes').'</p>
      
      <ul>';
         if ($this->Context->Database->RowCount($this->ApplicantData) > 0) {
            echo '<li class="CheckController"><p>'.$this->Context->GetDefinition('Check')            ." <a href=\"./\" onclick=\"CheckAll('ApplicantID'); return false;\">".$this->Context->GetDefinition('All').'</a>, '            ." <a href=\"./\" onclick=\"CheckNone('ApplicantID'); return false;\">".$this->Context->GetDefinition('None').'</a></p></li>';
            
            $ApplicantList = '';
            $Applicant = $this->Context->ObjectFactory->NewContextObject($this->Context, 'User');
            while ($Row = $this->Context->Database->GetRow($this->ApplicantData)) {
               $Applicant->Clear();
               $Applicant->GetPropertiesFromDataSet($Row);
               $Applicant->FormatPropertiesForDisplay();              
            
               $ApplicantList .= '<li class="Enabled">
                  <h3>
                     '.GetDynamicCheckBox(
                        'ApplicantID[]',
                        $Applicant->UserID,
                        0,
                        '',
                        $Applicant->Name,
                        '',
                        'ApplicantID'.$Applicant->UserID).'
                     <span class="Applied"><a href="'.GetUrl($this->Context->Configuration, 'account.php', '', 'u', $Applicant->UserID).'">'.TimeDiff($this->Context, $Applicant->DateFirstVisit, mktime()).'</a></span>
                     <span class="EmailAddress">'.FormatHyperlink('mailto:'.$Applicant->Email).'</span>';
                     
                     $this->DelegateParameters['ApplicantList'] = &$ApplicantList;
                     $this->CallDelegate('PostEmailAddress');
                     
                  $ApplicantList .= '</h3>
                  <p>'.$Applicant->Discovery.'</p>
               </li>';
            }
            echo $ApplicantList;
         } else {
            echo '<li class="NoApplicants"><p>'.$this->Context->GetDefinition('NoApplicants').'</p></li>';
         }
      echo '</ul>';
      if ($this->Context->Database->RowCount($this->ApplicantData) > 0) {
         echo '<div class="Approve">
            <input type="submit" name="btnSubmit" value="'.$this->Context->GetDefinition('ApproveForMembership').'" class="Button SubmitButton" />
            <input type="submit" name="btnSubmit" value="'.$this->Context->GetDefinition('DeclineForMembership').'" class="Button SubmitButton" />
         </div>';
      }
      echo '</form>
   </fieldset>
</div>';
?>