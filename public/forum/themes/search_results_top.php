<?php
// Note: This file is included from the library/Vanilla/Vanilla.Control.SearchForm.php class.
$SearchID = "Discussions";
switch ($this->Search->Type) {
   case "Comments":
      $SearchID = "CommentResults";
      break;
   case "Users":
      $SearchID = "UserResults";
      break;
   }
   
echo '<div class="ContentInfo Top">
	<h1>'.$this->Context->GetDefinition($this->Search->Type).'</h1>
   <div class="PageInfo">
		<p>'.($this->PageList != '' ? $this->PageDetails : $this->Context->GetDefinition('NoResultsFound')).'</p>
      '.$this->PageList.'
	</div>
</div>
<div id="ContentBody">
	<ol id="'.$SearchID.'">';

?>