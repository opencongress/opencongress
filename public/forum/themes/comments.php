<?php
// Note: This file is included from the library/Vanilla/Vanilla.Control.CommentGrid.php class.

$CommentList = '';
if ($this->Context->WarningCollector->Count() > 0) {
   $CommentList .= '<div class="ErrorContainer">
      <div class="ErrorTitle">'.$this->Context->GetDefinition('ErrorTitle').'</div>'
      .$this->Context->WarningCollector->GetMessages()
   .'</div>';
} else {
   $PageDetails = $this->pl->GetPageDetails($this->Context);
   $PageList = $this->pl->GetNumericList();
	$SessionPostBackKey = $this->Context->Session->GetVariable('SessionPostBackKey', 'string');
   
   $CommentList .= '<div class="ContentInfo Top">
      <h1>';
         if ($this->Context->Configuration['USE_CATEGORIES']) $CommentList .= '<a href="'.GetUrl($this->Context->Configuration, 'index.php', '', 'CategoryID', $this->Discussion->CategoryID).'">'.$this->Discussion->Category.'</a>: ';
        $CommentList .= DiscussionPrefix($this->Context, $this->Discussion).' ';
         if ($this->Discussion->WhisperUserID > 0) {
            $CommentList .= $this->Discussion->WhisperUsername.': ';
         }
         $CommentList .= $this->Discussion->Name
      .'</h1>
		<a href="#pgbottom">'.$this->Context->GetDefinition('BottomOfPage').'</a>
      <div class="PageInfo">
         <p>'.$PageDetails.'</p>
         '.$PageList.'
      </div>
   </div>
   <div id="ContentBody">
		<ol id="Comments">';

   $Comment = $this->Context->ObjectFactory->NewContextObject($this->Context, 'Comment');
   $RowNumber = 0;
   $CommentID = 0;
   $Alternate = 0;
	
   // Define the current user's permissions and preferences
   // (small optimization so they don't have to be checked every loop):
   $PERMISSION_EDIT_COMMENTS = $this->Context->Session->User->Permission('PERMISSION_EDIT_COMMENTS');
   $PERMISSION_HIDE_COMMENTS = $this->Context->Session->User->Permission('PERMISSION_HIDE_COMMENTS');
   $PERMISSION_EDIT_DISCUSSIONS = $this->Context->Session->User->Permission('PERMISSION_EDIT_DISCUSSIONS');
   
   while ($Row = $this->Context->Database->GetRow($this->CommentData)) {
      if ($RowNumber > 0) $PERMISSION_EDIT_DISCUSSIONS = 0;
      $RowNumber++;			
      $Comment->Clear();
      $Comment->GetPropertiesFromDataSet($Row, $this->Context->Session->UserID);
		$CommentAuthUsername = $Comment->AuthUsername; // Get an unencoded version of the author's username
      $ShowHtml = $Comment->FormatPropertiesForDisplay();
      $ShowIcon = $Comment->AuthIcon != '' ? 1 : 0;
      $this->DelegateParameters['ShowHtml'] = &$ShowHtml;
      $this->DelegateParameters['ShowIcon'] = &$ShowIcon;
      $this->DelegateParameters['RowNumber'] = &$RowNumber;
		
		$CommentClass = '';
		if ($Comment->WhisperUserID > 0) {
			if (
				($Comment->WhisperUserID == $this->Context->Session->UserID && $Comment->AuthUserID == $this->Context->Session->UserID)
				or $Comment->WhisperUserID == $this->Context->Session->UserID
				) {
				$CommentClass = 'WhisperTo';
			} else {
				$CommentClass = 'WhisperFrom';
			}
		} else if ($this->Discussion->WhisperUserID > 0) {
			$CommentClass = ($Comment->AuthUserID == $this->Context->Session->UserID) ? 'WhisperFrom' : 'WhisperTo';
		}
		
		if ($Comment->Deleted) $CommentClass .= ' Hidden';
		if ($Alternate) $CommentClass .= ' Alternate';
		$CommentClass = trim($CommentClass);

      $CommentList .= '<li id="Comment_'.$Comment->CommentID.'"'.($CommentClass == ''?'':' class="'.$CommentClass.'"').'>
         <a name="Item_'.$RowNumber.'"></a>
			<div class="CommentHeader">
            <ul>
               <li>
						'.($ShowIcon?'<div class="CommentIcon" style="'."background-image:url('".$Comment->AuthIcon."');".'">&nbsp;</div>':'').'
                  <span>'.$this->Context->GetDefinition('CommentAuthor').'</span><a href="'.GetUrl($this->Context->Configuration, 'account.php', '', 'u', $Comment->AuthUserID).'">'.$Comment->AuthUsername.'</a>';
                  
                  // Point out who it was whispered to if necessary
                  if ($Comment->WhisperUserID > 0) {
                     if ($Comment->WhisperUserID == $this->Context->Session->UserID && $Comment->AuthUserID == $this->Context->Session->UserID) {
                        $CommentList .= $this->Context->GetDefinition('ToYourself');
                     } elseif ($Comment->WhisperUserID == $this->Context->Session->UserID) {
                        $CommentList .= $this->Context->GetDefinition('ToYou');
                     } else {
                        $CommentList .= str_replace('//1', $Comment->WhisperUsername, $this->Context->GetDefinition('ToX'));
                     }
                  }
                  
               $CommentList .= '</li>
               <li>
                  <span>'.$this->Context->GetDefinition('CommentTime').'</span>'.TimeDiff($this->Context, $Comment->DateCreated);
                  if ($Comment->DateEdited != '') $CommentList .= ' <em>'.$this->Context->GetDefinition('Edited').'</em>';
						if ($Comment->Deleted) $CommentList .= ' <i>'.str_replace(array('//1', '//2'), array(TimeDiff($this->Context, $Comment->DateDeleted), $Comment->DeleteUsername), $this->Context->GetDefinition('CommentHiddenOnXByY')).'</i>';
						// Whisper back button
						if (!$this->Discussion->Closed && $Comment->WhisperUserID > 0 && $Comment->WhisperUserID == $this->Context->Session->UserID) $CommentList .= '<a class="WhisperBack" onclick="'
							."WhisperBack('".$Comment->DiscussionID."', '".str_replace("'", "\'", $CommentAuthUsername)."', '".$this->Context->Configuration['BASE_URL']."');"
						 .'">'.$this->Context->GetDefinition('WhisperBack').'</a>';
						
               $CommentList .= '</li>
            </ul>
            <span>
					&nbsp;';
            
               // Set up comment options            
               $this->DelegateParameters['Comment'] = &$Comment;
               $this->DelegateParameters['CommentList'] = &$CommentList;
					$this->DelegateParameters['RowNumber'] = &$RowNumber;
               $CommentList .= $this->CallDelegate('PreCommentOptionsRender');
               if ($this->Context->Session->UserID > 0) {
                  if ($Comment->AuthUserID == $this->Context->Session->UserID || $PERMISSION_EDIT_COMMENTS || $PERMISSION_EDIT_DISCUSSIONS) {
                     if ((!$this->Discussion->Closed && $this->Discussion->Active) || $PERMISSION_EDIT_COMMENTS || $PERMISSION_EDIT_DISCUSSIONS) $CommentList .= '<a href="'.GetUrl($this->Context->Configuration, 'post.php', '', 'CommentID', $Comment->CommentID).'">'.$this->Context->GetDefinition('edit').'</a>
                     ';
                  }
                  if ($PERMISSION_HIDE_COMMENTS) $CommentList .= '<a id="HideComment'.$Comment->CommentID.'" href="./" onclick="'
                  ."HideComment('".$this->Context->Configuration['WEB_ROOT']."ajax/switch.php', '".($Comment->Deleted?"0":"1")."', '".$this->Discussion->DiscussionID."', '".$Comment->CommentID."', '".$this->Context->GetDefinition("ShowConfirm")."', '".$this->Context->GetDefinition("HideConfirm")."', 'HideComment".$Comment->CommentID."', '".$SessionPostBackKey."');"
                  .' return false;">'.$this->Context->GetDefinition($Comment->Deleted?'Show':'Hide').'</a>
                  ';
					}
               $this->DelegateParameters['CommentList'] = &$CommentList;
               $this->CallDelegate('PostCommentOptionsRender');
               $CommentList .= '
               
            </span>
         </div>';
         if ($Comment->AuthRoleDesc != '') $CommentList .= '<div class="CommentNotice">'.$Comment->AuthRoleDesc.'</div>';
         $CommentList .= '<div class="CommentBody" id="CommentBody_'.$Comment->CommentID.'">';
            $CommentList .= $Comment->Body.'
         </div>
      </li>';
		$Alternate = FlipBool($Alternate);
   }
   
   $CommentList .= '</ol>
   </div>';
   
   if (@$PageList && @$PageDetails) {
      $CommentList .= '<div class="ContentInfo Middle">
         <div class="PageInfo">
            <p>'.$PageDetails.'</p>
            '.$PageList.'
         </div>
      </div>';
   }
}
echo $CommentList;
?>