<?php
// Note: This file is included from the library/People/People.Control.PasswordResetForm.php control.

echo '<div class="About">
   <h2>'.$this->Context->GetDefinition('AboutYourPassword').'</h2>
   <p>'.$this->Context->GetDefinition('AboutYourPasswordNotes').'</p>
</div>
<div id="Form" class="PasswordResetForm">
   <fieldset>
   <legend>'.$this->Context->GetDefinition('PasswordResetForm').'</legend>
   <p>'.$this->Context->GetDefinition('ChooseANewPassword').'</p>';
$this->Render_Warnings();   
$this->Render_PostBackForm($this->FormName);
echo '<ul>
   <li>
      <label for="txtNewPassword">'.$this->Context->GetDefinition('NewPassword').'</label>
      <input id="txtNewPassword" type="password" name="NewPassword" value="" class="Input" maxlength="20" />
   </li>
   <li>
      <label for="txtConfirmPassword">'.$this->Context->GetDefinition('ConfirmPassword').'</label>
      <input id="txtConfirmPassword" type="password" name="ConfirmPassword" value="" class="Input" maxlength="20" />
   </li>
</ul>
<div class="Submit"><input type="submit" name="btnPassword" value="'.$this->Context->GetDefinition('Proceed').'" class="Button" /></div>
</form>
</fieldset>
</div>';
?>