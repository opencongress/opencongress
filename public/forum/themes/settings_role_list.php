<?php
// Note: This file is included from the library/Vanilla/Vanilla.Control.RoleForm.php control.

echo '<div id="Form" class="Account Roles">';
   $Action = ForceIncomingString("Action", "");
   if ($Action == 'Removed') {
      echo '<div id="Success">'.$this->Context->GetDefinition('RoleRemoved').'</div>';
   } else if ($Action == 'Saved') {
      echo '<div id="Success">'.$this->Context->GetDefinition('RoleSaved').'</div>';
   } else if ($Action == 'SavedNew') {
      echo '<div id="Success">'.$this->Context->GetDefinition('NewRoleSaved').'</div>';
   }

   echo '<fieldset>
      <legend>'.$this->Context->GetDefinition('RoleManagement').'</legend>'
      .$this->Get_Warnings().
      '<form method="get" action="'.GetUrl($this->Context->Configuration, $this->Context->SelfUrl).'">
      <input type="hidden" name="PostBackAction" value="Role" />
      <p>'.$this->Context->GetDefinition('RoleReorderNotes').'</p>
      
      <div class="SortList" id="SortRoles">';
         if ($this->RoleData) {
            $r = $this->Context->ObjectFactory->NewContextObject($this->Context, 'Role');
            
            while ($Row = $this->Context->Database->GetRow($this->RoleData)) {
               $r->Clear();
               $r->GetPropertiesFromDataSet($Row);
               $r->FormatPropertiesForDisplay();
               echo '<div class="SortListItem'.($this->Context->Session->User->Permission('PERMISSION_SORT_ROLES') ? ' MovableSortListItem' : '').'" id="item_'.$r->RoleID.'">
                  <div class="SortListOptions">';
                  if ($this->Context->Session->User->Permission('PERMISSION_EDIT_ROLES')) echo '<a class="SortEdit" href="'.GetUrl($this->Context->Configuration, $this->Context->SelfUrl, '', '', '', '', 'PostBackAction=Role&amp;RoleID='.$r->RoleID).'">'.$this->Context->GetDefinition('Edit').'</a>';
                  if ($this->Context->Session->User->Permission('PERMISSION_REMOVE_ROLES')) {
                     if (!$r->Unauthenticated) {
                        echo '<a class="SortRemove" href="'.GetUrl($this->Context->Configuration, $this->Context->SelfUrl, '', '', '', '', 'PostBackAction=RoleRemove&amp;RoleID='.$r->RoleID).'">&nbsp;</a>';
                     } else {
                        echo '<span class="SortNoRemove">&nbsp;</span>';
                     }
                  }
                  echo '</div>'
                  .$r->RoleName
               .'</div>';
            }
         }
      echo '</div>';
      if ($this->Context->Session->User->Permission('PERMISSION_SORT_ROLES')) {
         echo "<script type=\"text/javascript\" language=\"javascript\">
         // <![CDATA[
            Sortable.create('SortRoles', {dropOnEmpty:true, tag:'div', constraint: 'vertical', ghosting: false, onUpdate: function() {new Ajax.Updater('SortResult', '".$this->Context->Configuration['WEB_ROOT']."ajax/sortroles.php', {onComplete: function(request) { new Effect.Highlight('SortRoles',{startcolor:'#ffff99'});}, parameters:Sortable.serialize('SortRoles', {tag:'div', name:'RoleID'}), evalScripts:true, asynchronous:true})}});
         // ]]>
         </script>";
         // Debug
         echo '<div id="SortResult" style="display: none;"></div>';
      }
      if ($this->Context->Session->User->Permission('PERMISSION_ADD_ROLES')) {
         echo '<div class="Submit">
            <input type="submit" name="btnSave" value="'.$this->Context->GetDefinition('CreateANewRole').'" class="Button SubmitButton NewRoleButton" />
            <a href="'.GetUrl($this->Context->Configuration, $this->Context->SelfUrl).'" class="CancelButton">'.$this->Context->GetDefinition('Cancel').'</a>
         </div>';
      }
   echo '</form>
   </fieldset>
</div>';
?>