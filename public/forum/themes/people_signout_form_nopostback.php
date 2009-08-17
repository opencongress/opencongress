<?php
// Note: This file is included from the library/People/People.Control.Leave.php class.

echo '<div class="BlankMessage">'.$this->Context->GetDefinition('Processing').'</div>
<script>'
."   setTimeout(\"window.location='".$this->Context->SelfUrl."?PostBackAction=SignOut'\",600);".'
</script>';
?>