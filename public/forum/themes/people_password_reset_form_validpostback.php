<?php
// Note: This file is included from the library/People/People.Control.PasswordResetForm.php control.

echo '<div class="FormComplete">
   <h2>'.$this->Context->GetDefinition('PasswordReset').'</h2>
   <ul>
      <li><a href="'.GetUrl($this->Context->Configuration, $this->Context->SelfUrl).'">'.$this->Context->GetDefinition('SignInNow').'</a>.</li>
   </ul>
</div>';
?>