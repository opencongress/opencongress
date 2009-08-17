<?php
// Note: This file is included from the library/Vanilla/Vanilla.Control.GlobalsForm.php control.
echo '<div id="Form" class="Account GlobalsForm">';
   if (ForceIncomingBool('Success',0)) echo '<div id="Success">'.$this->Context->GetDefinition('GlobalApplicationChangesSaved').'</div>';
   echo '<fieldset>
      <legend>'.$this->Context->GetDefinition('GlobalApplicationSettings').'</legend>
      '.$this->Get_Warnings().'
      '.$this->Get_PostBackForm('frmApplicationGlobals').'
      <h2>'.$this->Context->GetDefinition('Warning').'</h2>
      <p>
         '.$this->Context->GetDefinition('GlobalApplicationSettingsNotes').'
      </p>
      
      <h2>'.$this->Context->GetDefinition('ApplicationTitles').'</h2>
      <ul>
         <li>
            <label for="txtApplicationTitle">'.$this->Context->GetDefinition('ApplicationTitle').'</label>
            <input type="text" name="APPLICATION_TITLE" value="'.$this->ConfigurationManager->GetSetting('APPLICATION_TITLE').'" maxlength="50" class="SmallInput" id="txtApplicationTitle" />
         </li>
         <li>
            <label for="txtBannerTitle">'.$this->Context->GetDefinition('BannerTitle').'</label>
            <input type="text" name="BANNER_TITLE" value="'.$this->ConfigurationManager->GetSetting('BANNER_TITLE').'" class="SmallInput" id="txtBannerTitle" />
            <p class="Description">'.$this->Context->GetDefinition('ApplicationTitlesNotes').'</p>
         </li>
      </ul>

      <h2>'.$this->Context->GetDefinition('ForumOptions').'</h2>
      <ul>
         <li id="ForumOptions">
            <p><span>'.GetDynamicCheckBox('ENABLE_WHISPERS', 1, $this->ConfigurationManager->GetSetting('ENABLE_WHISPERS'), '', $this->Context->GetDefinition('EnableWhispers')).'</span></p>
            <p><span>'.GetDynamicCheckBox('ALLOW_NAME_CHANGE', 1, $this->ConfigurationManager->GetSetting('ALLOW_NAME_CHANGE'), '', $this->Context->GetDefinition('AllowNameChange')).'</span></p>
            <p><span>'.GetDynamicCheckBox('PUBLIC_BROWSING', 1, $this->ConfigurationManager->GetSetting('PUBLIC_BROWSING'), '', $this->Context->GetDefinition('AllowPublicBrowsing')).'</span></p>
            <p><span>'.GetDynamicCheckBox('USE_CATEGORIES', 1, $this->ConfigurationManager->GetSetting('USE_CATEGORIES'), '', $this->Context->GetDefinition('UseCategories')).'</span></p>
            <p><span>'.GetDynamicCheckBox('LOG_ALL_IPS', 1, $this->ConfigurationManager->GetSetting('LOG_ALL_IPS'), '', $this->Context->GetDefinition('LogAllIps')).'</span></p>
         </li>
      </ul>
      
      <h2>'.$this->Context->GetDefinition('CountsTitle').'</h2>
      <ul>
         <li>
            <label for="ddDiscussionsPerPage">'.$this->Context->GetDefinition('DiscussionsPerPage').'</label>
            ';
            $Selector = $this->Context->ObjectFactory->NewObject($this->Context, 'Select');
            $Selector->CssClass = 'SmallSelect';
            $Selector->Name = 'DISCUSSIONS_PER_PAGE';
            $Selector->Attributes = ' id="ddDiscussionsPerPage"';
            $i = 10;
            while ($i < 101) {
               $Selector->AddOption($i, $i);
               $i += 10;
            }
            $Selector->SelectedValue = $this->ConfigurationManager->GetSetting('DISCUSSIONS_PER_PAGE');
            echo $Selector->Get().'
         </li>
         <li>
            <label for="ddCommentsPerPage">'.$this->Context->GetDefinition('CommentsPerPage').'</label>
            ';
            $Selector->Name = 'COMMENTS_PER_PAGE';
            $Selector->Attributes = ' id="ddCommentsPerPage"';
            $Selector->SelectedValue = $this->ConfigurationManager->GetSetting('COMMENTS_PER_PAGE');
            echo $Selector->Get().'
         </li>
         <li>
            <label for="ddSearchResultsPerPage">'.$this->Context->GetDefinition('SearchResultsPerPage').'</label>
            ';
            $Selector->Name = 'SEARCH_RESULTS_PER_PAGE';
            $Selector->Attributes = ' id="ddSearchResultsPerPage"';
            $Selector->SelectedValue = $this->ConfigurationManager->GetSetting('SEARCH_RESULTS_PER_PAGE');
            echo $Selector->Get().'
         </li>';
         
         $this->CallDelegate('PostCounts');
         
      echo '</ul>

      <h2>'.$this->Context->GetDefinition('SpamProtectionTitle').'</h2>
      <ul>
         <li>
            <label for="txtMaxCommentLength">'.$this->Context->GetDefinition('MaxCommentLength').'</label>
            <input type="text" name="MAX_COMMENT_LENGTH" value="'.$this->ConfigurationManager->GetSetting('MAX_COMMENT_LENGTH').'" maxlength="255" class="SmallInput" id="txtMaxCommentLength" />
            <p class="Description">
               '.$this->Context->GetDefinition('MaxCommentLengthNotes');
               $Selector->Clear();
               $Selector->CssClass = 'SmallSelect';
               for ($i = 1; $i < 31; $i++) {
                  $Selector->AddOption($i, $i);
               }
               $Selector->Name = 'DISCUSSION_POST_THRESHOLD';
               $Selector->SelectedValue = $this->Context->Configuration['DISCUSSION_POST_THRESHOLD'];
               
               $SecondsSelector = $this->Context->ObjectFactory->NewObject($this->Context, 'Select');
               $SecondsSelector2 = $this->Context->ObjectFactory->NewObject($this->Context, 'Select');
               $SecondsSelector->CssClass = 'SmallSelect';
               $SecondsSelector2->CssClass = 'SmallSelect';
               for ($i = 10; $i < 601; $i++) {
                  $SecondsSelector->AddOption($i, $i);
                  $SecondsSelector2->AddOption($i, $i);
                  $i += 9;							
               }
               $SecondsSelector->Name = 'DISCUSSION_TIME_THRESHOLD';
               $SecondsSelector->SelectedValue = $this->Context->Configuration['DISCUSSION_TIME_THRESHOLD'];
               $SecondsSelector2->Name = 'DISCUSSION_THRESHOLD_PUNISHMENT';
               $SecondsSelector2->SelectedValue = $this->Context->Configuration['DISCUSSION_THRESHOLD_PUNISHMENT'];
               
               echo '<br /><br />'.str_replace(array('//1', '//2', '//3'),
                  array($Selector->Get(), $SecondsSelector->Get(), $SecondsSelector2->Get()),
                  $this->Context->GetDefinition('XDiscussionsYSecondsZFreeze'));
                  
               $Selector->Name = 'COMMENT_POST_THRESHOLD';
               $Selector->SelectedValue = $this->Context->Configuration['COMMENT_POST_THRESHOLD'];
               
               $SecondsSelector->Name = 'COMMENT_TIME_THRESHOLD';
               $SecondsSelector->SelectedValue = $this->Context->Configuration['COMMENT_TIME_THRESHOLD'];
               
               $SecondsSelector2->Name = 'COMMENT_THRESHOLD_PUNISHMENT';
               $SecondsSelector2->SelectedValue = $this->Context->Configuration['COMMENT_THRESHOLD_PUNISHMENT'];
               
               echo '<br /><br />'
                  .str_replace(array('//1', '//2', '//3'),
                     array($Selector->Get(), $SecondsSelector->Get(), $SecondsSelector2->Get()),
                     $this->Context->GetDefinition('XCommentsYSecondsZFreeze'))
               .'</p>
         </li>
      </ul>
      <h2>'.$this->Context->GetDefinition('EmailSettings').'</h2>
      <ul>
         <li>
            <label for="txtSupportName">'.$this->Context->GetDefinition('SupportName').'</label>
            <input type="text" name="SUPPORT_NAME" value="'.$this->ConfigurationManager->GetSetting('SUPPORT_NAME').'" maxlength="255" class="SmallInput" id="txtSupportName" />
         </li>
         <li>
            <label for="txtSupportEmail">'.$this->Context->GetDefinition('SupportEmail').'</label>
            <input type="text" name="SUPPORT_EMAIL" value="'.$this->ConfigurationManager->GetSetting('SUPPORT_EMAIL').'" maxlength="255" class="SmallInput" id="txtSupportEmail" />
            <p class="Description">'.$this->Context->GetDefinition('SupportContactNotes').'</p>
         </li>
         <li>
            <label for="txtSMTPHost">'.$this->Context->GetDefinition('SMTPHost').'</label>
            <input type="text" name="SMTP_HOST" value="'.$this->ConfigurationManager->GetSetting('SMTP_HOST').'" maxlength="255" class="SmallInput" id="txtSMTPHost" />
         </li>
         <li>
            <label for="txtSMTPUser">'.$this->Context->GetDefinition('SMTPUser').'</label>
            <input type="text" name="SMTP_USER" value="'.$this->ConfigurationManager->GetSetting('SMTP_USER').'" maxlength="255" class="SmallInput" id="txtSMTPUser" />
         </li>
         <li>
            <label for="txtSMTPPassword">'.$this->Context->GetDefinition('SMTPPassword').'</label>
            <input type="password" name="SMTP_PASSWORD" value="'.$this->ConfigurationManager->GetSetting('SMTP_PASSWORD').'" maxlength="255" class="SmallInput" id="txtSMTPPassword" />
            <p class="Description">'.$this->Context->GetDefinition('SMTPSettingsNotes').'</p>
         </li>
      </ul>
      
      <h2>'.$this->Context->GetDefinition('ApplicationSettings').'</h2>
      <ul>
         <li>
            <label for="txtWebPathtoVanilla">'.$this->Context->GetDefinition('WebPathToVanilla').'</label>
            <input type="text" name="BASE_URL" value="'.$this->ConfigurationManager->GetSetting('BASE_URL').'" maxlength="255" class="SmallInput" id="txtWebPathToVanilla" />
            <p class="Description">'.$this->Context->GetDefinition('WebPathNotes').'</p>
         </li>
         <li>
            <label for="txtCookieDomain">'.$this->Context->GetDefinition('CookieDomain').'</label>
            <input type="text" name="COOKIE_DOMAIN" value="'.$this->ConfigurationManager->GetSetting('COOKIE_DOMAIN').'" maxlength="255" class="SmallInput" />
         </li>
         <li>
            <label for="txtCookiePath">'.$this->Context->GetDefinition('CookiePath').'</label>
            <input type="text" name="COOKIE_PATH" value="'.$this->ConfigurationManager->GetSetting('COOKIE_PATH').'" maxlength="255" class="SmallInput" id="txtCookiePath" />
            <p class="Description">'.$this->Context->GetDefinition('CookieSettingsNotes').'</p>
         </li>
      </ul>
      
      <div class="Submit">
         <input type="submit" name="btnSave" value="'.$this->Context->GetDefinition('Save').'" class="Button SubmitButton" />
         <a href="'.GetUrl($this->Context->Configuration, $this->Context->SelfUrl).'" class="CancelButton">'.$this->Context->GetDefinition('Cancel').'</a>
      </div>
      </form>
   </fieldset>
</div>';
?>