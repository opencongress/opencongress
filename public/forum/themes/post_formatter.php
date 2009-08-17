<?php
// Note: This file is included from the library/Vanilla/Vanilla.Control.DiscussionForm.php class.

if ($this->Context->Session->User->Preference('ShowFormatSelector') && $FormatCount > 1) {   
   $sReturn .= '<li id="CommentFormats">'
      .$this->Context->GetDefinition('FormatCommentsAs')
      .$f->Get()
   .'</li>';
} else {
   $FormatTypeToUse = $this->Context->Session->User->DefaultFormatType;
   if (!array_key_exists($FormatTypeToUse, $this->Context->StringManipulator->Formatters)) {
      $FormatTypeToUse = $this->Context->Configuration['DEFAULT_FORMAT_TYPE'];
   }
   
   $sReturn .= '<li class="Invisible"><input type="hidden" name="FormatType" value="'.$FormatTypeToUse.'" /></li>';
}
?>