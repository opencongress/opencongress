<?php
// Note: This file is included from the library/Vanilla/Vanilla.Control.AccountRoleForm.php class.

if (!$this->Context->Session->User->Permission('PERMISSION_CHANGE_USER_ROLE')) {
   $this->Context->WarningCollector->Add($this->Context->GetDefinition('PermissionError'));
   echo '<div id="Form" class="Account Role">
      '.$this->Get_Warnings().'
   </div>';
} else {				
   $this->PostBackParams->Set('PostBackAction', 'ProcessRole');
   $this->PostBackParams->Set('u', $this->User->UserID);
   $Required = $this->Context->GetDefinition('Required');
   echo '<div id="Form" class="Account Role">
      <fieldset>
         <legend>'.$this->Context->GetDefinition('ChangeRole').': '.$this->User->Name.'</legend>
         '.$this->Get_Warnings().'
         '.$this->Get_PostBackForm('frmRole').'
         <ul>
            <li>
               <label for="ddRoleID">'.$this->Context->GetDefinition('AssignToRole').' <small>'.$Required.'</small></label>
               '.$this->RoleSelect->Get().'
               <p class="Description">'.$this->Context->GetDefinition('AssignToRoleNotes').'</p>
            </li>
            <li>
               <label for="txtNotes">'.$this->Context->GetDefinition('RoleChangeInfo').' <small>'.$Required.'</small></label>
               <input type="text" name="Notes" id="txtNotes" value="" class="PanelInput" />
               <p class="Description">'.$this->Context->GetDefinition('RoleChangeInfoNotes').'</p>
            </li>
         </ul>
         <div class="Submit">
            <input type="submit" name="btnSave" value="'.$this->Context->GetDefinition('ChangeRole').'" class="Button SubmitButton ChangeRoleButton" />
            <a href="'.GetUrl($this->Context->Configuration, 'account.php', '', 'u', $this->User->UserID).'" class="CancelButton">'.$this->Context->GetDefinition('Cancel').'</a>
         </div>
         </form>
      </fieldset>
   </div>';
}
?>