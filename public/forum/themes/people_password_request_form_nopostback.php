<?php
// Note: This file is included from the library/People/People.Control.PasswordRequestForm.php control.

echo '<div class="About">
   <h2>'.$this->Context->GetDefinition('AboutYourPassword').'</h2>
   <p>'.$this->Context->GetDefinition('AboutYourPasswordRequestNotes').'</p>
   <p><a href="'.GetUrl($this->Context->Configuration, $this->Context->SelfUrl).'">'.$this->Context->GetDefinition('BackToSignInForm').'</a></p>
</div>
<div id="Form" class="PasswordRequestForm">
   <fieldset>
      <legend>'.$this->Context->GetDefinition('PasswordResetRequestForm').'</legend>
      <p>'.$this->Context->GetDefinition('PasswordResetRequestFormNotes').'</p>';
$this->Render_Warnings();
$this->Render_PostBackForm($this->FormName);
echo '<ul>
   <li>
      <label for="txtUsername">'.$this->Context->GetDefinition('Username').'</label>
      <input id="txtUsername" type="text" name="Username" value="'.FormatStringForDisplay($this->Username, 1).'" class="Input" maxlength="20" />
   </li>
</ul>
<div class="Submit"><input type="submit" name="btnPassword" value="'.$this->Context->GetDefinition('SendRequest').'" class="Button" /></div>
</form>
</fieldset>
</div>';
?>