<?php
// Note: This file is included from the library/Vanilla/Vanilla.Control.ThemeAndStyle.php control.

if (!$this->Context->Session->User->Permission('PERMISSION_MANAGE_THEMES') && !$this->Context->Session->User->Permission('PERMISSION_MANAGE_STYLES')) {
   $this->Context->WarningCollector->Add($this->Context->GetDefinition('PermissionError'));
   echo '<div class="SettingsForm">
         '.$this->Get_Warnings().'
   </div>';
} else {
   echo '<div id="Form" class="Account Theme">';
      if (ForceIncomingBool('Saved', 0)) echo '<div id="Success">'.$this->Context->GetDefinition('ThemeChangesSaved').'</div>';   
      echo '<fieldset>
         <legend>'.$this->Context->GetDefinition('ThemeAndStyleManagement').'</legend>
         '.$this->Get_Warnings().'
         '.$this->Get_PostBackForm('frmThemeChange').'
         <p>'.$this->Context->GetDefinition('ThemeAndStyleNotes').'</p>
         <ul>';
   
   if ($this->Context->Session->User->Permission('PERMISSION_MANAGE_THEMES')) {
      $this->PostBackParams->Set('PostBackAction', 'ProcessThemeChange');
      echo '<li>
         <label for="ddTheme">'.$this->Context->GetDefinition('ThemeLabel').'</label>
         '.$this->ThemeSelect->Get().'
      </li>';
   }
   
   if ($this->Context->Session->User->Permission('PERMISSION_MANAGE_STYLES')) {
      echo '<li>
         <label for="ddStyle">'.$this->Context->GetDefinition('StyleLabel').'</label>
         '.$this->StyleSelect->Get().'
      </li>
      <li>
         <p><span>'.GetDynamicCheckBox('ApplyStyleToUsers', 1, ForceIncomingBool('ApplyStyleToUsers', 0), '', $this->Context->GetDefinition('ApplyStyleToAllUsers')).'</span></p>
      </li>';
   }
   
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