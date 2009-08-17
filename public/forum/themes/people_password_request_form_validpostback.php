<?php
// Note: This file is included from the library/People/People.Control.PasswordRequestForm.php control.

echo '<div class="FormComplete">
   <h2>'.$this->Context->GetDefinition('RequestProcessed').'</h2>
   <ul>
      <li>'.str_replace('//1',
         FormatStringForDisplay($this->EmailSentTo, 1),
         $this->Context->GetDefinition('MessageSentToXContainingPasswordInstructions')).'</li>
   </ul>
</div>';
?>