<?php
// Note: This file is included from the library/Framework/Framework.Control.NoticeCollector.php class.

$NoticeCount = count($this->Notices);
if ($NoticeCount > 0) {
   echo '<div id="NoticeCollector" class="'.$this->CssClass.'">';
   for ($i = 0; $i < $NoticeCount; $i++) {
      echo '<div class="Notice">'
         .$this->Notices[$i];
      echo '</div>';
   }
   echo '</div>';
}
?>