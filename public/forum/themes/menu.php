<?php
// Note: This file is included from the library/Vanilla/Vanilla.Control.Menu.php class.

echo '<div id="Session">';
   if ($this->Context->Session->UserID > 0) {
      echo str_replace('//1',
         $this->Context->Session->User->Name,
         $this->Context->GetDefinition('SignedInAsX')).' (<a href="'.$this->Context->Configuration['SIGNOUT_URL'].'">'.$this->Context->GetDefinition('SignOut').'</a>)';
   } else {
      echo $this->Context->GetDefinition('NotSignedIn').' (<a href="'.AppendUrlParameters($this->Context->Configuration['SIGNIN_URL'], 'ReturnUrl='.GetRequestUri()).'">'.$this->Context->GetDefinition('SignIn').'</a>)';
   }
   echo '</div>';
	$this->CallDelegate('PreHeadRender');	
   echo '<div id="Header">
			<a name="pgtop"></a>
			<h1>
				'.$this->Context->Configuration['BANNER_TITLE'].'
			</h1>
			
			<ul>';
				while (list($Key, $Tab) = each($this->Tabs)) {
					echo '<li'.$this->TabClass($this->CurrentTab, $Tab['Value']).'><a href="'.$Tab['Url'].'" '.$Tab['Attributes'].'>'.$Tab['Text'].'</a></li>';
		      }			
			echo '</ul>
   </div>';
	$this->CallDelegate('PreBodyRender');	
   echo '<div id="Body">';
?>