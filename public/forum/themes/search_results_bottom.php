<?php
// Note: This file is included from the library/Vanilla/Vanilla.Control.SearchForm.php class.

echo '</ol>
</div>';
if ($this->DataCount > 0) {
   echo '<div class="ContentInfo Bottom">
      <div class="PageInfo">
         <p>'.$this->PageDetails.'</p>
         '.$this->PageList.'
      </div>
      <a href="'.GetRequestUri().'#pgtop">'.$this->Context->GetDefinition('TopOfPage').'</a>
   </div>';
}
?>