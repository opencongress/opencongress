<?php
// Note: This file is included from the library/Vanilla/Vanilla.Control.CategoryForm.php control.

echo '<div id="Form" class="Account CategoryRemoveForm">
   <fieldset>
      <legend>'.$this->Context->GetDefinition('CategoryManagement').'</legend>'
      .$this->Get_Warnings()
      .$this->Get_PostBackForm("frmCategoryRemove")
      .'<h2>'.$this->Context->GetDefinition("SelectCategoryToRemove").'</h2>
      <ul>
         <li>
            <label for="sCategorySelect">'.$this->Context->GetDefinition('Categories').' <small>'.$this->Context->GetDefinition('Required').'</small></label>';
            $this->CategorySelect->Attributes .= ' id="sCategorySelect"';
            echo $this->CategorySelect->Get()
         .'</li>
      </ul>';
      if ($CategoryID > 0) {
         $this->CategorySelect->Attributes = ' id="sReplacementCategory"';
         $this->CategorySelect->RemoveOption($this->CategorySelect->SelectedValue);
         $this->CategorySelect->Name = 'ReplacementCategoryID';
         $this->CategorySelect->SelectedValue = ForceIncomingInt('ReplacementCategoryID', 0);
         echo '<h2>'.$this->Context->GetDefinition('SelectReplacementCategory').'</h2>
         <ul>
            <li>
               <label for="sReplacementCategory">'.$this->Context->GetDefinition('ReplacementCategory').' <small>'.$this->Context->GetDefinition('Required').'</small></label>
               '.$this->CategorySelect->Get().'
               <p class="Description">'.$this->Context->GetDefinition('ReplacementCategoryNotes').'</p>
            </li>
         </ul>
         <div class="Submit">
            <input type="submit" name="btnSave" value="'.$this->Context->GetDefinition('Remove').'" class="Button SubmitButton RemoveCategoryButton" />
            <a href="'.GetUrl($this->Context->Configuration, $this->Context->SelfUrl, '', '', '', '', 'PostBackAction=Categories').'" class="CancelButton">'.$this->Context->GetDefinition('Cancel').'</a>
         </div>';
      }
      echo '</form>
   </fieldset>
</div>';
?>