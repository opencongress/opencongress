<?php
// Note: This file is included from the library/Vanilla/Vanilla.Control.SearchForm.php
// class and also from the library/Vanilla/Vanilla.Control.DiscussionForm.php's
// themes/discussions.php include template.

$UnreadUrl = GetUnreadQuerystring($Discussion, $this->Context->Configuration, $CurrentUserJumpToLastCommentPref);
$NewUrl = GetUnreadQuerystring($Discussion, $this->Context->Configuration, 1);
$LastUrl = GetLastCommentQuerystring($Discussion, $this->Context->Configuration, $CurrentUserJumpToLastCommentPref);

$DiscussionList .= '
<li id="Discussion_'.$Discussion->DiscussionID.'" class="Discussion'.$Discussion->Status.($Discussion->CountComments == 1?' NoReplies':'').($this->Context->Configuration['USE_CATEGORIES'] ? ' Category_'.$Discussion->CategoryID:'').($Alternate ? ' Alternate' : '').'">
   <ul>
      <li class="DiscussionType">
         <span>'.$this->Context->GetDefinition('DiscussionType').'</span>'.DiscussionPrefix($this->Context, $Discussion).'
      </li>
      <li class="DiscussionTopic">
         <span>'.$this->Context->GetDefinition('DiscussionTopic').'</span><a href="'.$UnreadUrl.'">'.$Discussion->Name.'</a>
      </li>
      ';
      if ($this->Context->Configuration['USE_CATEGORIES']) {
         $DiscussionList .= '
         <li class="DiscussionCategory">
            <span>'.$this->Context->GetDefinition('Category').' </span><a href="'.GetUrl($this->Context->Configuration, 'index.php', '', 'CategoryID', $Discussion->CategoryID).'">'.$Discussion->Category.'</a>
         </li>
         ';
      }
      $DiscussionList .= '<li class="DiscussionStarted">
         <span><a href="'.GetUrl($this->Context->Configuration, 'comments.php', '', 'DiscussionID', $Discussion->DiscussionID, '', '#Item_1', CleanupString($Discussion->Name).'/').'">'.$this->Context->GetDefinition('StartedBy').'</a> </span><a href="'.GetUrl($this->Context->Configuration, 'account.php', '', 'u', $Discussion->AuthUserID).'">'.$Discussion->AuthUsername.'</a>
      </li>
      <li class="DiscussionComments">
         <span>'.$this->Context->GetDefinition('Comments').' </span>'.$Discussion->CountComments.'
      </li>
      <li class="DiscussionLastComment">
         <span><a href="'.$LastUrl.'">'.$this->Context->GetDefinition('LastCommentBy').'</a> </span><a href="'.GetUrl($this->Context->Configuration, 'account.php', '', 'u', $Discussion->LastUserID).'">'.$Discussion->LastUsername.'</a>
      </li>
      <li class="DiscussionActive">
         <span><a href="'.$LastUrl.'">'.$this->Context->GetDefinition('LastActive').'</a> </span>'.TimeDiff($this->Context, $Discussion->DateLastActive,mktime()).'
      </li>';
      if ($this->Context->Session->UserID > 0) {
            $DiscussionList .= '
         <li class="DiscussionNew">
            <a href="'.$NewUrl.'"><span>'.$this->Context->GetDefinition('NewCaps').' </span>'.$Discussion->NewComments.'</a>
         </li>
         ';
      }
   $this->DelegateParameters['Discussion'] = &$Discussion;
   $this->DelegateParameters['DiscussionList'] = &$DiscussionList;
   
   $this->CallDelegate('PostDiscussionOptionsRender');
   
$DiscussionList .= '</ul>
</li>';   
?>