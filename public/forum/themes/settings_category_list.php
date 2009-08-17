<?php
// Note: This file is included from the library/Vanilla/Vanilla.Control.CategoryForm.php control.

echo '<div id="Form" class="Account CategoryList">';
   $Action = ForceIncomingString("Action", "");
   if ($Action == 'Removed') {
      echo '<div id="Success">'.$this->Context->GetDefinition('CategoryRemoved').'</div>';
   } else if ($Action == 'Saved') {
      echo '<div id="Success">'.$this->Context->GetDefinition('CategorySaved').'</div>';
   } else if ($Action == 'SavedNew') {
      echo '<div id="Success">'.$this->Context->GetDefinition('NewCategorySaved').'</div>';
   }
   echo '<fieldset>
      <legend>'.$this->Context->GetDefinition('CategoryManagement').'</legend>'
      .$this->Get_Warnings()
      .'<form method="get" action="'.GetUrl($this->Context->Configuration, $this->Context->SelfUrl).'">
      <input type="hidden" name="PostBackAction" value="Category" />
      <p>'.$this->Context->GetDefinition('CategoryReorderNotes').'</p>
      <div class="SortList" id="SortCategories">
      ';
         if ($this->CategoryData) {
            $c = $this->Context->ObjectFactory->NewObject($this->Context, 'Category');
            while ($Row = $this->Context->Database->GetRow($this->CategoryData)) {
               $c->Clear();
               $c->GetPropertiesFromDataSet($Row);
               $c->FormatPropertiesForDisplay();
               echo '<div class="SortListItem'.($c->RoleBlocked?' RoleBlocked':'').($this->Context->Session->User->Permission('PERMISSION_SORT_CATEGORIES') ? ' MovableSortListItem':'').'" id="item_'.$c->CategoryID.'">
                  <div class="SortListOptions">';
                  if ($this->Context->Session->User->Permission('PERMISSION_EDIT_CATEGORIES')) echo '<a class="SortEdit" href="'.GetUrl($this->Context->Configuration, $this->Context->SelfUrl, '', '', '', '', 'PostBackAction=Category&amp;CategoryID='.$c->CategoryID).'">'.$this->Context->GetDefinition('Edit').'</a>';
                  if ($this->Context->Session->User->Permission('PERMISSION_REMOVE_CATEGORIES')) echo '<a class="SortRemove" href="'.GetUrl($this->Context->Configuration, $this->Context->SelfUrl, '', '', '', '', 'PostBackAction=CategoryRemove&amp;CategoryID='.$c->CategoryID).'">&nbsp;</a>';
                  echo '</div>'
                  .$c->Name.'
               </div>
               ';
            }
         }
      echo '</div>
      <div id="SortResult" style="display: none;"></div>';
      
      if ($this->Context->Session->User->Permission('PERMISSION_SORT_CATEGORIES')) {
         echo "
         <script type=\"text/javascript\" language=\"javascript\">
         // <![CDATA[
            Sortable.create('SortCategories', {dropOnEmpty:true, tag:'div', constraint: 'vertical', ghosting: false, onUpdate: function() {new Ajax.Updater('SortResult', '".$this->Context->Configuration['WEB_ROOT']."ajax/sortcategories.php', {onComplete: function(request) { new Effect.Highlight('SortCategories',{startcolor:'#ffff99'});}, parameters:Sortable.serialize('SortCategories', {tag:'div', name:'CategoryID'}), evalScripts:true, asynchronous:true})}});
         // ]]>
         </script>";
      }
      echo '<div class="Submit">
         <input type="submit" name="btnSave" value="'.$this->Context->GetDefinition('CreateNewCategory').'" class="Button SubmitButton NewCategoryButton" />
         <a href="'.GetUrl($this->Context->Configuration, $this->Context->SelfUrl).'" class="CancelButton">'.$this->Context->GetDefinition('Cancel').'</a>
      </div>
   </form>
   </fieldset>
</div>';
?>