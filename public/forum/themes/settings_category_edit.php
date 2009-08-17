<?php
// Note: This file is included from the library/Vanilla/Vanilla.Control.CategoryForm.php control.

echo '<div id="Form" class="Account CategoryForm">
   <fieldset>
      <legend>'.$this->Context->GetDefinition('CategoryManagement').'</legend>'
      .$this->Get_Warnings()
      .$this->Get_PostBackForm('frmCategory');
      
   if ($CategoryID > 0) {
      $this->CategorySelect->Attributes = "onchange=\"document.location='".GetUrl($this->Context->Configuration, $this->Context->SelfUrl, '', '', '', '', 'PostBackAction=Category')."&amp;CategoryID='+this.options[this.selectedIndex].value;\" id=\"sCategorySelect\"";
      $this->CategorySelect->SelectedValue = $CategoryID;
      echo '<h2>'.$this->Context->GetDefinition('GetCategoryToEdit').'</h2>
         <ul>
            <li>
               <label for="sCategorySelect">'.$this->Context->GetDefinition('Categories').' <small>'.$this->Context->GetDefinition('Required').'</small></label>
               '.$this->CategorySelect->Get().'
            </li>
         </ul>
         <h2>'.$this->Context->GetDefinition('ModifyCategoryDefinition').'</h2>';
   } else {
      echo '<h2>'.$this->Context->GetDefinition('DefineNewCategory').'</h2>';
   }
   echo '<ul>
   <li>
      <label for="txtCategoryName">'.$this->Context->GetDefinition('CategoryName').' <small>'.$this->Context->GetDefinition('Required').'</small></label>
      <input type="text" name="Name" value="'.$this->Category->Name.'" maxlength="80" class="SmallInput" id="txtCategoryName" />
      <p class="Description">'.$this->Context->GetDefinition('CategoryNameNotes').'</p>
   </li>
   <li>
      <label for="txtCategoryDescription">'.$this->Context->GetDefinition('CategoryDescription').'</label>
      <textarea name="Description" id="txtCategoryDescription" class="LargeTextbox">'.$this->Category->Description.'</textarea>
      <p class="Description">'.$this->Context->GetDefinition('CategoryDescriptionNotes').'</p>
   </li>
   <li>
      <p class="Description">
         <strong>'.$this->Context->GetDefinition('Roles').'</strong>
         <br />'.$this->Context->GetDefinition('RolesInCategory')
      .'</p>
   </li>
   <li>
      <p class="Description">
      '.$this->Context->GetDefinition('Check')
      ." <a href=\"./\" onclick=\"CheckAll('RoleID_'); return false;\">".$this->Context->GetDefinition('All').'</a>, '
      ." <a href=\"./\" onclick=\"CheckNone('RoleID_'); return false;\">".$this->Context->GetDefinition('None').'</a>
      </p>
   </li>';
   
   $sRoles = '';
   $OptionCount = count($this->CategoryRoles->aOptions);
   for ($i = 0; $i < $OptionCount ; $i++) {
      $sRoles .= '<li>
         <p>
            <span>'.GetDynamicCheckBox($this->CategoryRoles->Name,
               $this->CategoryRoles->aOptions[$i]['IdValue'],
               $this->CategoryRoles->aOptions[$i]['Checked'],
               '',
               $this->CategoryRoles->aOptions[$i]['DisplayValue'],
               '',
               'RoleID_'.$this->CategoryRoles->aOptions[$i]['IdValue'])
            .'</span>
         </p>
      </li>';
   }
   echo $sRoles
   .'</ul>
   <div class="Submit">
      <input type="submit" name="btnSave" value="'.$this->Context->GetDefinition('Save').'" class="Button SubmitButton EditCategoryButton" />
      <a href="'.GetUrl($this->Context->Configuration, 'settings.php', '', '', '', '', 'PostBackAction=Categories').'" class="CancelButton">'.$this->Context->GetDefinition('Cancel').'</a>
   </div>
   </form>
   </fieldset>
</div>';
?>