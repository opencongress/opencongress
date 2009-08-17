<?php
// Note: This file is included from the library/Vanilla/Vanilla.Control.SettingsHelp.php control.

echo '<div id="Form" class="Settings Help">
   <fieldset>
      <legend>'.$this->Context->GetDefinition('AboutSettings').'</legend>
      <form method="post" action="">
      '.$this->Context->GetDefinition('AboutSettingsNotes').'
      </form>
   </fieldset>
</div>';
?>