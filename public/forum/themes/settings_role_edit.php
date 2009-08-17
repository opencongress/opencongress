<?php
// Note: This file is included from the library/People/People.Control.RoleForm.php control.

echo '<div id="Form" class="Account RoleEditForm">
   <fieldset>
      <legend>'.$this->Context->GetDefinition('RoleManagement').'</legend>';
   if ($RoleID > 0) {
      $this->RoleSelect->Attributes = "onchange=\"document.location='".GetUrl($this->Context->Configuration, $this->Context->SelfUrl, '', '', '', '', 'PostBackAction=Role')."&amp;RoleID='+this.options[this.selectedIndex].value;\" id=\"sRoleSelect\"";
      $this->RoleSelect->SelectedValue = $RoleID;
      echo $this->Get_Warnings()
         .$this->Get_PostBackForm('frmRole')
         .'<h2>'.$this->Context->GetDefinition('SelectRoleToEdit').'</h2>
         <ul>
            <li>
               <label for="sRoleSelect">'.$this->Context->GetDefinition('Roles').' <small>'.$this->Context->GetDefinition('Required').'</small></label>
               '.$this->RoleSelect->Get().'
            </li>
         </ul>
         <h2>'.$this->Context->GetDefinition('ModifyRoleDefinition').'</h2>
         <ul>';
   } else {
      echo $this->Get_Warnings()
         .$this->Get_PostBackForm('frmRole')
         .'<h2>'.$this->Context->GetDefinition('DefineNewRole').'</h2>
         <ul>';
   }
   echo '<li>
      <label for="txtRoleName">'.$this->Context->GetDefinition('RoleName').' <small>'.$this->Context->GetDefinition('Required').'</small></label>
      <input type="text" name="RoleName" value="'.$this->Role->RoleName.'" maxlength="80" class="SmallInput" id="txtRoleName" />
      <p class="Description">'.$this->Context->GetDefinition('RoleNameNotes').'</p>
   </li>';
   
   if (!$this->Role->Unauthenticated) {
      echo '<li>
         <label for="txtRoleIcon">'.$this->Context->GetDefinition('RoleIcon').'</label>
         <input type="text" name="Icon" value="'.$this->Role->Icon.'" maxlength="130" class="SmallInput" id="txtIcon" />
         <p class="Description">'.$this->Context->GetDefinition('RoleIconNotes').'</p>
      </li>
      <li>
         <label for="txtRoleDescription">'.$this->Context->GetDefinition('RoleTagline').'</label>
         <input type="text" name="Description" value="'.$this->Role->Description.'" maxlength="180" class="SmallInput" id="txtRoleDescription" />
         <p class="Description">'.$this->Context->GetDefinition('RoleTaglineNotes').'</p>
      </li>
      <li>
         <p class="Description">
            <strong>'.$this->Context->GetDefinition('RoleAbilities').'</strong>
            <br />'.$this->Context->GetDefinition('RoleAbilitiesNotes').'
         </p>
      </li>
      <li>         <p class="Description">         '.$this->Context->GetDefinition('Check')         ." <a href=\"./\" onclick=\"CheckAll('PERMISSION_'); return false;\">".$this->Context->GetDefinition('All').'</a>, '         ." <a href=\"./\" onclick=\"CheckNone('PERMISSION_'); return false;\">".$this->Context->GetDefinition('None').'</a>         </p>      </li>';      
      while (list($PermissionKey, $PermissionValue) = each($this->Role->Permissions)) {
         echo '<li>
            <p>
               <span>'.GetDynamicCheckBox($PermissionKey, 1, $PermissionValue, '', $this->Context->GetDefinition($PermissionKey)).'</span>
            </p>
         </li>';
      }

      // Add the option of specifying which categories this role can see if creating a new role
      if ($this->Role->RoleID == 0 && $this->CategoryData) {
         echo '<li>
            <p class="Description">
               <br /><strong>'.$this->Context->GetDefinition('RoleCategoryNotes').'</strong>
            </p>
         </li>
         <li>            <p class="Description">            '.$this->Context->GetDefinition('Check')            ." <a href=\"./\" onclick=\"CheckAll('AllowedCategoryID'); return false;\">".$this->Context->GetDefinition('All').'</a>, '            ." <a href=\"./\" onclick=\"CheckNone('AllowedCategoryID'); return false;\">".$this->Context->GetDefinition('None').'</a>            </p>         </li>';         
         while ($Row = $this->Context->Database->GetRow($this->CategoryData)) {
            echo '<li>
               <p>
                  <span>'.GetDynamicCheckBox('AllowedCategoryID[]', $Row['CategoryID'], in_array($Row['CategoryID'], ForceIncomingArray('AllowedCategoryID', array())), '', $Row['Name'], '', 'AllowedCategoryID'.$Row['CategoryID']).'</span>
               </p>
            </li>';
         }
      }
   }
   
   $this->CallDelegate('PreSubmitButton');
   
   echo '</ul>
   <div class="Submit">
         <input type="submit" name="btnSave" value="'.$this->Context->GetDefinition('Save').'" class="Button SubmitButton" />
         <a href="'.GetUrl($this->Context->Configuration, $this->Context->SelfUrl, '', '', '', '', 'PostBackAction=Roles').'" class="CancelButton">'.$this->Context->GetDefinition('Cancel').'</a>
      </div>
      </form>
   </fieldset>
</div>';
?>