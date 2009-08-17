<?php
// Note: This file is included from the library/Vanilla/Vanilla.Control.Account.php class.

echo '<div id="AccountProfile">';

      if (ForceIncomingBool('Success',0)) echo '<div id="Success">'.$this->Context->GetDefinition('ChangesSaved').'</div>';
      $this->Render_Warnings();
      
   echo '<ul class="vcard">';

      $this->CallDelegate('PreUsernameRender');
      
      if ($this->User->DisplayIcon != '') {
         echo '<li class="ProfileTitle WithIcon clearfix">
            <div class="ProfileIcon" style="background-image:url(\''.$this->User->DisplayIcon.'\')">&nbsp;</div>';
      } else {
         echo '<li class="ProfileTitle clearfix">';
      }
         echo '<h2>'.$this->User->Name.'</h2>
         <p>'.$this->User->Role.'</p>
      </li>';
      if ($this->User->RoleDescription != '') echo('<li class="Tagline">'.$this->User->RoleDescription.'</li>');
      if ($this->User->Picture != "" && $this->User->Permission('PERMISSION_HTML_ALLOWED')) echo "<li class=\"Picture\" style=\"background-image: url('".$this->User->Picture."');\">&nbsp;</li>";
      
      $this->CallDelegate('PostPictureRender');
      
      if ($this->Context->Configuration['USE_REAL_NAMES'] && ($this->User->ShowName || $this->Context->Session->User->Permission('PERMISSION_EDIT_USERS'))) {
         echo '<li>
            <h3>'.$this->Context->GetDefinition('RealName').'</h3>
            <p class="fn">'.ReturnNonEmpty($this->User->FullName).'</p>
         </li>';
      }
      echo '<li>
         <h3>'.$this->Context->GetDefinition('Email').'</h3>
         <p class="email">'.(($this->Context->Session->UserID > 0 && $this->User->UtilizeEmail) ? GetEmail($this->User->Email) : $this->Context->GetDefinition('NA')).'</p>
      </li>
      <li>
         <h3>'.$this->Context->GetDefinition('AccountCreated').'</h3>
         <p>'.TimeDiff($this->Context, $this->User->DateFirstVisit, mktime()).'</p>
      </li>
      <li>
         <h3>'.$this->Context->GetDefinition('LastActive').'</h3>
         <p>'.TimeDiff($this->Context, $this->User->DateLastActive, mktime()).'</p>
      </li>
      <li>
         <h3>'.$this->Context->GetDefinition('VisitCount').'</h3>
         <p>'.$this->User->CountVisit.'</p>
      </li>
      <li>
         <h3>'.$this->Context->GetDefinition('DiscussionsStarted').'</h3>
         <p>'.$this->User->CountDiscussions.'</p>
      </li>
      <li>
         <h3>'.$this->Context->GetDefinition('CommentsAdded').'</h3>
         <p>'.$this->User->CountComments.'</p>
      </li>';
         
      $this->CallDelegate('PostBasicPropertiesRender');
         
      if ($this->Context->Session->User->Permission('PERMISSION_IP_ADDRESSES_VISIBLE')) {
         echo '<li>
            <h3>'.$this->Context->GetDefinition('LastKnownIp').'</h3>
            <p>'.$this->User->RemoteIp.'</p>
         </li>';
      }
         
      if (count($this->User->Attributes) > 0) {
         $AttributeCount = count($this->User->Attributes);
         for ($i = 0; $i < $AttributeCount; $i++) {
            $CssClass = (strpos($this->User->Attributes[$i]['Value'], 'http://') == 0 && strpos($this->User->Attributes[$i]['Value'], 'http://') !== false) ? 'url' : '';
            echo '<li>
               <h3>'.htmlspecialchars($this->User->Attributes[$i]['Label']).'</h3>
               <p>'.FormatHyperlink(htmlspecialchars($this->User->Attributes[$i]['Value']), 1, '', $CssClass).'</p>
            </li>';
         }
      }
      
      $this->CallDelegate('PostAttributesRender');
         
   echo '</ul>
</div>
<div id="AccountHistory">';

$this->CallDelegate('PostProfileRender');

?>