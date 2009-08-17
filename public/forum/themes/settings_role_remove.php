<?php
// Note: This file is included from the library/People/People.Control.RoleForm.php control.

echo '<div id="Form" class="Account RoleRemoveForm">
   <fieldset>
      <legend>'.$this->Context->GetDefinition('RoleManagement').'</legend>'
      .$this->Get_Warnings()
      .$this->Get_PostBackForm('frmRoleRemove')
      .'<h2>'.$this->Context->GetDefinition('SelectRoleToRemove').'</h2>
      <ul>
         <li>
            <label for="sRoleToRemove">'.$this->Context->GetDefinition('Roles').' <small>'.$this->Context->GetDefinition('Required').'</small></label>';
            $this->RoleSelect->Attributes .= ' id="sRoleToRemove"';
            echo $this->RoleSelect->Get().'
         </li>
      </ul>';
      if ($RoleID > 0) {
         $this->RoleSelect->Attributes = ' id="sReplacementRole"';
         $this->RoleSelect->RemoveOption($this->RoleSelect->SelectedValue);
         $this->RoleSelect->Name = 'ReplacementRoleID';
         $this->RoleSelect->SelectedValue = ForceIncomingInt('ReplacementRoleID', 0);
         
         echo '<h2>'.$this->Context->GetDefinition('SelectReplacementRole').'</h2>
         <ul>
            <li>
               <label for="sReplacementRole">'.$this->Context->GetDefinition('ReplacementRole').' <small>'.$this->Context->GetDefinition('Required').'</small></label>
               '.$this->RoleSelect->Get().'
               <p class="Description">'.$this->Context->GetDefinition('ReplacementRoleNotes').'</p>
            </li>
         </ul>
         <div class="Submit">
            <input type="submit" name="btnSave" value="'.$this->Context->GetDefinition('Remove').'" class="Button SubmitButton RoleRemoveButton" />
            <a href="'.GetUrl($this->Context->Configuration, $this->Context->SelfUrl, '', '', '', '', 'PostBackAction=Roles').'" class="CancelButton">'.$this->Context->GetDefinition('Cancel').'</a>
         </div>';
      }
      echo '</form>
   </fieldset>
</div>';
?>