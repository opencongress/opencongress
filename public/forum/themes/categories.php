<?php
// Note: This file is included from the library/Vanilla/Vanilla.Control.CategoryList.php class.

$SessionPostBackKey = $this->Context->Session->GetVariable('SessionPostBackKey', 'string');

$CategoryList = '<div class="ContentInfo Top">
	<h1>'.$this->Context->PageTitle.'</h1>
</div>
<div id="ContentBody">
	<ol id="Categories">';
$Category = $this->Context->ObjectFactory->NewObject($this->Context, 'Category');
$FirstRow = 1;
$Alternate = 0;
while ($Row = $this->Context->Database->GetRow($this->Data)) {
   $Category->Clear();
   $Category->GetPropertiesFromDataSet($Row);
   $Category->FormatPropertiesForDisplay();
   $CategoryList .= '<li id="Category_'.$Category->CategoryID.'" class="Category'.($Category->Blocked?' BlockedCategory':' UnblockedCategory').($FirstRow?' FirstCategory':'').' Category_'.$Category->CategoryID.($Alternate ? ' Alternate' : '').'">
      <ul>
         <li class="CategoryName">
            <span>'.$this->Context->GetDefinition('Category').'</span> <a href="'.GetUrl($this->Context->Configuration, 'index.php', '', 'CategoryID', $Category->CategoryID).'">'.$Category->Name.'</a>
         </li>
         <li class="CategoryDescription">
            <span>'.$this->Context->GetDefinition('CategoryDescription').'</span> '.$Category->Description.'
         </li>
         <li class="CategoryDiscussionCount">
            <span>'.$this->Context->GetDefinition('Discussions').'</span> '.$Category->DiscussionCount.'
         </li>';
         if ($this->Context->Session->UserID > 0) {
            $CategoryList .= '
               <li class="CategoryOptions">
                  <span>'.$this->Context->GetDefinition('Options').'</span> ';
                  if ($Category->Blocked) {
                     $CategoryList .= '<a id="BlockCategory'.$Category->CategoryID.'" onclick="ToggleCategoryBlock('."'".$this->Context->Configuration['WEB_ROOT']."ajax/blockcategory.php', ".$Category->CategoryID.", 0, 'BlockCategory".$Category->CategoryID."', '".$SessionPostBackKey."');\">".$this->Context->GetDefinition('UnblockCategory').'</a>';
                  } else {
                     $CategoryList .= '<a id="BlockCategory'.$Category->CategoryID.'" onclick="ToggleCategoryBlock('."'".$this->Context->Configuration['WEB_ROOT']."ajax/blockcategory.php', ".$Category->CategoryID.", 1, 'BlockCategory".$Category->CategoryID."', '".$SessionPostBackKey."');\">".$this->Context->GetDefinition('BlockCategory').'</a>';
                  }
               $CategoryList .= '</li>
            ';
         }
      $CategoryList .= '</ul>
   </li>';
   $FirstRow = 0;
	$Alternate = FlipBool($Alternate);
}
echo $CategoryList
   .'</ol>
</div>';
?>