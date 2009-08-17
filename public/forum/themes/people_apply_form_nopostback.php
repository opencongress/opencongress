<?php
// Note: This file is included from the library/People/People.Control.ApplyForm.php class.

echo '<div class="About">
   '.$this->Context->GetDefinition('AboutMembership').'
         <p><a href="'.GetUrl($this->Context->Configuration, $this->Context->SelfUrl).'">'.$this->Context->GetDefinition('BackToSignInForm').'</a></p>
      </div>
      <div id="Form" class="ApplyForm">
         <fieldset>
            <legend>'.$this->Context->GetDefinition('MembershipApplicationForm').'</legend>
            <p>'.$this->Context->GetDefinition('AllFieldsRequired').'</p>';
            
			$this->CallDelegate('PreWarningsRender');
			$this->Render_Warnings();
         
         $this->Render_PostBackForm($this->FormName);
         echo '<ul>';

         $this->CallDelegate('PreInputsRender');

         echo '<li>
            <label for="txtEmail">'.$this->Context->GetDefinition('EmailAddress').'</label>
            <input id="txtEmail" type="text" name="Email" value="'.$this->Applicant->Email.'" class="Input" maxlength="160" />
         </li>
         <li>
            <label for="txtUsername">'.$this->Context->GetDefinition('Username').'</label>
            <input id="txtUsername" type="text" name="Name" value="'.$this->Applicant->Name.'" class="Input" maxlength="20" />
         </li>
         <li>
            <label for="txtNewPassword">'.$this->Context->GetDefinition('Password').'</label>
            <input id="txtNewPassword" type="password" name="NewPassword" value="'.$this->Applicant->NewPassword.'" class="Input" />
         </li>
         <li>
            <label for="txtConfirmPassword">'.$this->Context->GetDefinition('PasswordAgain').'</label>
            <input id="txtConfirmPassword" type="password" name="ConfirmPassword" value="'.$this->Applicant->ConfirmPassword.'" class="Input" />
         </li>';

         $this->CallDelegate('PostInputsRender');      
         $this->CallDelegate('PreTermsCheckRender');
         
         $TermsOfServiceUrl = $this->Context->Configuration['WEB_ROOT'].'termsofservice.php';
      
         echo '<li id="TermsOfServiceCheckBox">
            '.GetBasicCheckBox('AgreeToTerms', 1, $this->Applicant->AgreeToTerms,'').' '.str_replace('//1', ' <a href="'.$TermsOfServiceUrl.'" onclick="PopTermsOfService('."'".$TermsOfServiceUrl."'".'); return false;">'.$this->Context->GetDefinition('TermsOfService').'</a>', $this->Context->GetDefinition('IHaveReadAndAgreeTo')).'
         </li>
         </ul>
         <div class="Submit">
            <input type="submit" name="btnApply" value="'.$this->Context->GetDefinition('Proceed').'" class="Button" />
         </div>
         </form>
         </fieldset>
   </div>';
?>