<?php
// Note: This file is included from the library/Vanilla/Vanilla.Control.LanguageForm.php control.

if (!$this->Context->Session->User->Permission('PERMISSION_MANAGE_LANGUAGE')) {
   $this->Context->WarningCollector->Add($this->Context->GetDefinition('PermissionError'));
   echo '<div class="SettingsForm">
         '.$this->Get_Warnings().'
   </div>';				
} else {
   $this->PostBackParams->Set('PostBackAction', 'ProcessLanguageChange');
   echo '<div id="Form" class="Account Identity">';
   if ($this->PostBackValidated) echo '<div id="Success">'.$this->Context->GetDefinition('LanguageChangesSaved').'</div>';
      echo '<fieldset>
         <legend>'.$this->Context->GetDefinition('LanguageManagement').'</legend>
         '.$this->Get_Warnings().'
         '.$this->Get_PostBackForm('frmLanguageChange').'
         <ul>
            <li>
               <label for="ddLanguage">'.$this->Context->GetDefinition('ChangeLanguage').'</label>
               '.$this->LanguageSelect->Get().'
               <p class="Description">'.$this->Context->GetDefinition('ChangeLanguageNotes').'</p>
            </li>
         </ul>
         <div class="Submit">
            <input type="submit" name="btnSave" value="'.$this->Context->GetDefinition('Save').'" class="Button SubmitButton" />
            <a href="'.GetUrl($this->Context->Configuration, $this->Context->SelfUrl).'" class="CancelButton">'.$this->Context->GetDefinition('Cancel').'</a>
         </div>
         </form>
      </fieldset>
   </div>';
}
?>