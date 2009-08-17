<?php
// Note: This file is included from the library/Vanilla/Vanilla.Control.SearchForm.php class.

$ShowIcon = ($u->DisplayIcon != '' && $this->Context->Session->User->Preference('HtmlOn'));
$UserList .= '<li class="UserAccount'.($Alternate ? ' Alternate' : '').($FirstRow?' FirstUser':'').'">
   <ul>
      <li class="User Name'.($ShowIcon?' WithIcon':'').'">';
         if ($ShowIcon) $UserList .= '<div class="UserIcon" style="'."background-image:url('".$u->DisplayIcon."');\">&nbsp;</div>";
         $UserList .= '
         <span>'.$this->Context->GetDefinition('User').'</span> <a href="'.GetUrl($this->Context->Configuration, 'account.php', '', 'u', $u->UserID).'">'.$u->Name.'</a> ('.$u->Role.')
      </li>
      <li class="User AccountCreated">
         <span>'.$this->Context->GetDefinition('AccountCreated').'</span> '.TimeDiff($this->Context, $u->DateFirstVisit,mktime()).'
      </li>
      <li class="User LastActive">
         <span>'.$this->Context->GetDefinition('LastActive').'</span> '.TimeDiff($this->Context, $u->DateLastActive,mktime()).'
      </li>
      <li class="User VisitCount">
         <span>'.$this->Context->GetDefinition('VisitCount').'</span> '.$u->CountVisit.'
      </li>
      <li class="User DiscussionsCreated">
         <span>'.$this->Context->GetDefinition('DiscussionsCreated').'</span> '.$u->CountDiscussions.'
      </li>
      <li class="User CommentsAdded">
         <span>'.$this->Context->GetDefinition('CommentsAdded').'</span> '.$u->CountComments.'
      </li>
   </ul>
</li>';

?>