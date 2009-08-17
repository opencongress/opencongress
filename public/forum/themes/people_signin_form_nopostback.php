<?php
// Note: This file is included from the library/People/People.Control.SignInForm.php control.

$this->Render_Warnings();
echo '<div id="Form" class="SignInForm">
   <fieldset>';
$this->Render_PostBackForm($this->FormName);
echo '<ul>
   <li>
      <label for="txtUsername">'.$this->Context->GetDefinition('Username').'</label>
      <input id="txtUsername" type="text" name="Username" value="'.$this->Username.'" class="Input" maxlength="20" />
   </li>
   <li>
      <label for="txtPassword">'.$this->Context->GetDefinition('Password').'</label>
      <input id="txtPassword" type="password" name="Password" value="" class="Input" />
   </li>
   <li id="RememberMe">
      '.GetDynamicCheckBox('RememberMe', 1, ForceIncomingBool('RememberMe', 0), '', $this->Context->GetDefinition('RememberMe')).'
   </li>
</ul>
<div class="Submit"><input type="submit" name="btnSignIn" value="'.$this->Context->GetDefinition('Proceed').'" class="Button" /></div>
</form>
</fieldset>
<ul class="MembershipOptionLinks">
   <li class="ForgotPasswordLink"><a href="'.GetUrl($this->Context->Configuration, $this->Context->SelfUrl, '', '', '', '', 'PostBackAction=PasswordRequestForm').'">'.$this->Context->GetDefinition('ForgotYourPassword').'</a></li>
   <li class="ApplyForMembershipLink"><a href="'.GetUrl($this->Context->Configuration, $this->Context->SelfUrl, '', '', '', '', 'PostBackAction=ApplyForm').'">'.$this->Context->GetDefinition('ApplyForMembership').'</a></li>
</ul>
</div>';
?>