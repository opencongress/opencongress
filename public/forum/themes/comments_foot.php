<?php
// Note: This file is included from the library/Vanilla/Vanilla.Control.CommentFoot.php class.

echo '<div class="ContentInfo Bottom">
   <a href="'.GetUrl($this->Context->Configuration, 'index.php').'" class="left">'.$this->Context->GetDefinition('BackToDiscussions').'</a>
   <a href="'.GetRequestUri().'#pgtop">'.$this->Context->GetDefinition('TopOfPage').'</a>
</div>';

?>