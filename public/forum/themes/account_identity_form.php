<?php
// Note: This file is included from the library/Vanilla/Vanilla.Control.IdentityForm.php class.

if ($this->Context->Session->UserID != $this->User->UserID && !$this->Context->Session->User->Permission('PERMISSION_EDIT_USERS')) {
   $this->Context->WarningCollector->Add($this->Context->GetDefinition('PermissionError'));
   echo '<div id="Form" class="Account Identity">
      '.$this->Get_Warnings().'
   </div>';
} else {				
   $this->PostBackParams->Set('PostBackAction', 'ProcessIdentity');
   $this->PostBackParams->Set('u', $this->User->UserID);
   $this->PostBackParams->Set('LabelValuePairCount', (count($this->User->Attributes) > 0? count($this->User->Attributes):1), 1, 'LabelValuePairCount');
   $Required = $this->Context->GetDefinition('Required');
   echo '<div id="Form" class="Account Identity">
      <fieldset>
         <legend>'.$this->Context->GetDefinition('ChangePersonalInfo').'</legend>';
      
         $this->CallDelegate('PreWarningsRender');
         
         echo $this->Get_Warnings()
         .$this->Get_PostBackForm('frmAccountPersonal');
         
         $this->CallDelegate('PreInputsRender');
         
         echo '<h2>'.$this->Context->GetDefinition('DefineYourAccountProfile').'</h2>
         <ul>';
            if ($this->Context->Configuration['ALLOW_NAME_CHANGE'] == "1") {
               echo '<li>
                  <label for="txtUsername">'.$this->Context->GetDefinition('YourUsername').' <small>'.$Required.'</small></label>
                  <input type="text" name="Name" value="'.$this->User->Name.'" maxlength="20" class="SmallInput" id="txtUsername" />
                  <p class="Description">'.$this->Context->GetDefinition('YourUsernameNotes').'</p>
               </li>';
            }
            if ($this->Context->Configuration['USE_REAL_NAMES'] == "1") {
               echo '<li>
                  <label for="txtFirstName">'.$this->Context->GetDefinition('YourFirstName').'</label>
                  <input type="text" name="FirstName" value="'.$this->User->FirstName.'" maxlength="50" class="SmallInput" id="txtFirstName" />
                  <p class="Description">'.$this->Context->GetDefinition('YourFirstNameNotes').'</p>
               </li>
               <li>
                  <label for="txtLastName">'.$this->Context->GetDefinition('YourLastName').'</label>
                  <input type="text" name="LastName" value="'.$this->User->LastName.'" maxlength="50" class="SmallInput" id="txtLastName" />
                  <p class="Description">
                     '.$this->Context->GetDefinition('YourLastNameNotes').'
                     <span>'.GetDynamicCheckBox('ShowName', 1, $this->User->ShowName, '', $this->Context->GetDefinition('MakeRealNameVisible')).'</span>
                  </p>
               </li>';
            }
            if ($this->Context->Configuration['ALLOW_EMAIL_CHANGE'] == '1') {
               echo '<li>
                  <label for="txtEmail">'.$this->Context->GetDefinition('YourEmailAddress').' <small>'.$Required.'</small></label>
                  <input type="text" name="Email" value="'.$this->User->Email.'" maxlength="200" class="SmallInput" id="txtEmail" />
                  <p class="Description">
                     '.$this->Context->GetDefinition('YourEmailAddressNotes').'
                     <span>'.GetDynamicCheckBox('UtilizeEmail', 1, $this->User->UtilizeEmail, '', $this->Context->GetDefinition('CheckForVisibleEmail')).'</span>
                  </p>
               </li>';
            } else {
               echo '<li>
                  <p class="Description">
                     <span>'.GetDynamicCheckBox('UtilizeEmail', 1, $this->User->UtilizeEmail, '', $this->Context->GetDefinition('CheckForVisibleEmail')).'</span>
                  </p>
               </li>';
            }
            echo '<li>
               <label for="txtPicture">'.$this->Context->GetDefinition('AccountPicture').'</label>
               <input type="text" name="Picture" value="'.$this->User->Picture.'" maxlength="255" class="SmallInput" id="txtPicture" />
               <p class="Description">
                  '.$this->Context->GetDefinition('AccountPictureNotes').'
               </p>
            </li>
            <li>
               <label for="txtIcon">'.$this->Context->GetDefinition('Icon').'</label>
               <input type="text" name="Icon" value="'.$this->User->Icon.'" maxlength="255" class="SmallInput" id="txtIcon" />
               <p class="Description">
                  '.$this->Context->GetDefinition('IconNotes').'
               </p>
            </li>
         </ul>';
         
         // Add the extension customization settings
         $Customizations = '';
         while (list($Key, $Value) = each($this->Context->Configuration)) {
            if (strpos($Key, 'CUSTOMIZATION_') !== false) {
               $Description = $this->Context->GetDefinition($Key.'_DESCRIPTION');
               $Customizations .= '<li>
                  <label for="'.$Key.'">'.$this->Context->GetDefinition($Key).'</label>
                  <input id="'.$Key.'" type="text" name="'.$Key.'" value="'.ForceIncomingString($Key, $this->User->Customization($Key)).'" maxlength="255" class="SmallInput" />
                  '.($Description != $Key.'_DESCRIPTION' ? '<p class="Description">'.$Description.'</p>' : '').'
               </li>';
            }
         }
         // If some customizations were found, write them out now
         if ($Customizations != '') {
            echo '<h2>'.$this->Context->GetDefinition('OtherSettings').'</h2>
            <ul>'
               .$Customizations
            .'</ul>';
         }
         
         $this->CallDelegate('PreCustomInputsRender');      
         
         echo '<h2>'.$this->Context->GetDefinition('AddCustomInformation').'</h2>
         <p class="Description">'.$this->Context->GetDefinition('AddCustomInformationNotes').'</p>
         <ul id="CustomInfo" class="clearfix">';
            $CurrentItem = 1;
            if (count($this->User->Attributes) > 0) {
               $AttributeCount = count($this->User->Attributes);
               for ($i = 0; $i < $AttributeCount; $i++) {
                  if ($i == 0) {
                     echo '<li>'.$this->Context->GetDefinition('Label').'</li>
                     <li>'.$this->Context->GetDefinition('Value').'</li>';
                  }
                  echo '<li><input type="text" name="Label'.$CurrentItem.'" value="'.$this->User->Attributes[$i]['Label'].'" maxlength="20" class="LVLabelInput" /></li>
                  <li><input type="text" name="Value'.$CurrentItem.'" value="'.$this->User->Attributes[$i]['Value'].'" maxlength="200" class="LVValueInput" /></li>';
                  $CurrentItem++;
               }
            } else {
               echo '<li>'.$this->Context->GetDefinition('Label').'</li>
               <li>'.$this->Context->GetDefinition('Value').'</li>
               <li><input type="text" name="Label'.$CurrentItem.'" value="" maxlength="20" class="LVLabelInput" /></li>
               <li><input type="text" name="Value'.$CurrentItem.'" value="" maxlength="200" class="LVValueInput" /></li>';
            }
         echo '</ul>';
         
         $this->CallDelegate('PreButtonsRender');
         
         echo '<p><a href="javascript:AddLabelValuePair();">'.$this->Context->GetDefinition('AddLabelValuePair').'</a></p>
         <div class="Submit">
            <input type="submit" name="btnSave" value="'.$this->Context->GetDefinition('Save').'" class="Button SubmitButton" />
            <a href="'.GetUrl($this->Context->Configuration, 'account.php', '', 'u', $this->User->UserID).'" class="CancelButton">'.$this->Context->GetDefinition('Cancel').'</a>
         </div>
         </form>
      </fieldset>
   </div>';
}
?>