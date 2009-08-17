<?php
// Note: This file is included from the library/Vanilla/Vanilla.Control.PasswordForm.php class.

if ($this->Context->Session->UserID != $this->User->UserID && !$this->Context->Session->User->Permission('PERMISSION_EDIT_USERS')) {
   $this->Context->WarningCollector->Add($this->Context->GetDefinition('PermissionError'));
   echo '<div id="Form" class="Account Password">
      '.$this->Get_Warnings().'
   </div>';
} else {				
   $this->PostBackParams->Set('PostBackAction', 'ProcessPassword');
   $this->PostBackParams->Set('u', $this->User->UserID);
   $Required = $this->Context->GetDefinition('Required');
   echo '<div id="Form" class="Account Password">
      <fieldset>
         <legend>'.$this->Context->GetDefinition('ChangeYourPassword').'</legend>';
         
         $this->CallDelegate('PreWarningsRender');
         
         echo $this->Get_Warnings()
         .$this->Get_PostBackForm('frmAccountPassword');
         
         $this->CallDelegate('PreInputsRender');
         
         echo '<ul>
            <li>
               <label for="txtOldPassword">'.$this->Context->GetDefinition('YourOldPassword').' <small>'.$Required.'</small></label>
               <input type="password" name="OldPassword" value="'.$this->User->OldPassword.'" maxlength="100" class="SmallInput" id="txtOldPassword" />
               <p class="Description">'.$this->Context->GetDefinition('YourOldPasswordNotes').'</p>
            </li>
            <li>
               <label for="txtNewPassword">'.$this->Context->GetDefinition('YourNewPassword').' <small>'.$Required.'</small></label>
               <input type="password" name="NewPassword" value="'.$this->User->NewPassword.'" maxlength="100" class="SmallInput" id="txtNewPassword" />
               <p class="Description">'.$this->Context->GetDefinition('YourNewPasswordNotes').'</p>
            </li>
            <li>
               <label for="txtConfirmPassword">'.$this->Context->GetDefinition('YourNewPasswordAgain').' <small>'.$Required.'</small></label>
               <input type="password" name="ConfirmPassword" value="'.$this->User->ConfirmPassword.'" maxlength="100" class="SmallInput" id="txtConfirmPassword" />
               <p class="Description">'.$this->Context->GetDefinition('YourNewPasswordAgainNotes').'</p>
            </li>
         </ul>';
         
         $this->CallDelegate('PreButtonsRender');
         
         echo '<div class="Submit">
            <input type="submit" name="btnSave" value="'.$this->Context->GetDefinition('Save').'" class="Button SubmitButton" />
            <a href="'.GetUrl($this->Context->Configuration, "account.php", "", "u", $this->User->UserID).'" class="CancelButton">'.$this->Context->GetDefinition('Cancel').'</a>
         </div>
         </form>
      </fieldset>
   </div>';
}
?>