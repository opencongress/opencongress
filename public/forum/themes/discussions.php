<?php
// Note: This file is included from the library/Vanilla/Vanilla.Control.DiscussionGrid.php class.

echo '<div class="ContentInfo Top">
	<h1>
		'.$this->Context->PageTitle.'
	</h1>
	'.$this->PageJump.'
	<div class="PageInfo">
		<p>'.($PageDetails == '' ? $this->Context->GetDefinition('NoDiscussionsFound') : $PageDetails).'</p>
		'.$PageList.'
	</div>
</div>
<div id="ContentBody">
	<ol id="Discussions">';

$Discussion = $this->Context->ObjectFactory->NewContextObject($this->Context, 'Discussion');
$FirstRow = 1;
$CurrentUserJumpToLastCommentPref = $this->Context->Session->User->Preference('JumpToLastReadComment');
$DiscussionList = '';
$ThemeFilePath = ThemeFilePath($this->Context->Configuration, 'discussion.php');
$Alternate = 0;
while ($Row = $this->Context->Database->GetRow($this->DiscussionData)) {
   $Discussion->Clear();
   $Discussion->GetPropertiesFromDataSet($Row, $this->Context->Configuration);
   $Discussion->FormatPropertiesForDisplay();
	// Prefix the discussion name with the whispered-to username if this is a whisper
   if ($Discussion->WhisperUserID > 0) {
		$Discussion->Name = @$Discussion->WhisperUsername.': '.$Discussion->Name;
	}

	// Discussion search results are identical to regular discussion listings, so include the discussion search results template here.
	include($ThemeFilePath);
	
   $FirstRow = 0;
	$Alternate = FlipBool($Alternate);
}
echo $DiscussionList.'
	</ol>
</div>';
if ($this->DiscussionDataCount > 0) {
   echo '<div class="ContentInfo Bottom">
		<div class="PageInfo">
			<p>'.$pl->GetPageDetails($this->Context).'</p>
			'.$PageList.'
		</div>
		<a id="TopOfPage" href="'.GetRequestUri().'#pgtop">'.$this->Context->GetDefinition('TopOfPage').'</a>
	</div>';
}
?>