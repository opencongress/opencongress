<?php
// Note: This file is included from the library/Vanilla/Vanilla.Control.SearchForm.php class.

$CommentList .= '<li class="SearchComment'.($Alternate ? ' Alternate' : '').'">
   <ul>
      <li class="DiscussionTopic">
         <span>'.$this->Context->GetDefinition('DiscussionTopic').'</span>
         <a href="'.GetUrl($this->Context->Configuration, 'comments.php', '', 'DiscussionID', $Comment->DiscussionID).'">'.$Comment->Discussion.'</a>
      </li>
      <li class="CommentText">
         <span>'.$this->Context->GetDefinition('Comment').'</span>
         <a href="'.GetUrl($this->Context->Configuration, 'comments.php', '', 'DiscussionID', $Comment->DiscussionID, '', 'Focus='.$Comment->CommentID.'#Comment_'.$Comment->CommentID).'">'.HighlightTrimmedString($Comment->Body, $HighlightWords, 300).'</a>
      </li>
      <li class="DiscussionCategory">
         <span>'.$this->Context->GetDefinition('Category').'</span>
         <a href="'.GetUrl($this->Context->Configuration, 'index.php', '', 'CategoryID', $Comment->CategoryID).'">'.$Comment->Category.'</a>
      </li>
      <li class="CommentAuthor">
         <span>'.$this->Context->GetDefinition('WrittenBy').'</span>
         <a href="'.GetUrl($this->Context->Configuration, 'account.php', '', 'u', $Comment->AuthUserID).'">'.$Comment->AuthUsername.'</a>
      </li>
      <li class="CommentAdded">
         <span>'.$this->Context->GetDefinition('Added').'</span>
         '.TimeDiff($this->Context, $Comment->DateCreated,mktime()).'
      </li>
   </ul>
</li>
';

?>