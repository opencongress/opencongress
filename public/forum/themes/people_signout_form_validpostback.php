<?php
// Note: This file is included from the library/People/People.Control.Leave.php class.

echo '<div class="FormComplete">
   <h2>'.$this->Context->GetDefinition('SignOutSuccessful').'</h2>
   <ul>
      <li><a href="'.GetUrl($this->Context->Configuration, $this->Context->SelfUrl).'">'.$this->Context->GetDefinition('SignInAgain').'</a></li>
   </ul>
</div>';
?>