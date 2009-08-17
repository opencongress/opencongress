<?php
// Note: This file is included from the library/People/People.Control.RegistrationForm.php control.

if (!$this->Context->Session->User->Permission('PERMISSION_MANAGE_REGISTRATION')) {
   $this->Context->WarningCollector->Add($this->Context->GetDefinition('PermissionError'));
   echo '<div class="SettingsForm">
         '.$this->Get_Warnings().'
   </div>';
} else {				
   $this->PostBackParams->Set('PostBackAction', 'ProcessRegistrationChange');
   echo '<div id="Form" class="Account Identity">';
   if ($this->PostBackValidated) echo '<div id="Success">'.$this->Context->GetDefinition('RegistrationChangesSaved').'</div>';
      echo '<fieldset>
         <legend>'.$this->Context->GetDefinition('RegistrationManagement').'</legend>
         '.$this->Get_Warnings().'
         '.$this->Get_PostBackForm('frmRegistrationChange').'
         <ul>
            <li>
               <label for="ddRoleID">'.$this->Context->GetDefinition('NewMemberRole').'</label>
               '.$this->RoleSelect->Get().'
               <p class="Description">'.$this->Context->GetDefinition('NewMemberRoleNotes').'</p>
            </li>
            <li>
               <label for="ddApprovedRoleID">'.$this->Context->GetDefinition('ApprovedMemberRole').'</label>
               '.$this->ApprovedRoleSelect->Get().'
               <p class="Description">'.$this->Context->GetDefinition('ApprovedMemberRoleNotes').'</p>
            </li>';
            $this->CallDelegate('PostRegistrationOptions');
         echo '</ul>
         <div class="Submit">
            <input type="submit" name="btnSave" value="'.$this->Context->GetDefinition('Save').'" class="Button SubmitButton" />
            <a href="'.GetUrl($this->Context->Configuration, $this->Context->SelfUrl).'" class="CancelButton">'.$this->Context->GetDefinition('Cancel').'</a>
         </div>
         </form>
      </fieldset>
   </div>';
}
?>