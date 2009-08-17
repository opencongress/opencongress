<?php
// Note: This file is included from the library/Framework/Framework.Control.Panel.php class.

echo '<div id="Panel">';

// Add the start button to the panel
if ($this->Context->Session->UserID > 0 && $this->Context->Session->User->Permission('PERMISSION_START_DISCUSSION')) {
   $CategoryID = ForceIncomingInt('CategoryID', 0);
	if ($CategoryID == 0) $CategoryID = '';
	echo '<h1><a href="'.GetUrl($this->Context->Configuration, 'post.php', 'category/', 'CategoryID', $CategoryID).'">'
      .$this->Context->GetDefinition('StartANewDiscussion')
      .'</a></h1>';
}

$this->CallDelegate('PostStartButtonRender');

while (list($Key, $PanelElement) = each($this->PanelElements)) {
   $Type = $PanelElement['Type'];
   $Key = $PanelElement['Key'];
   if ($Type == 'List') {
      $sReturn = '';
      $Links = $this->Lists[$Key];
      if (count($Links) > 0) {
         ksort($Links);
         $sReturn .= '<ul>
            <li>
               <h2>'.$Key.'</h2>
               <ul>';
               while (list($LinkKey, $Link) = each($Links)) {
                  $sReturn .= '<li>
                     <a '.($Link['Link'] != '' ? 'href="'.$Link['Link'].'"' : '').' '.$Link['LinkAttributes'].'>'
                        .$Link['Item'];
                        if ($Link['Suffix'] != '') $sReturn .= ' <span>'.$this->Context->GetDefinition($Link['Suffix']).'</span>';
                     $sReturn .= '</a>';
                  $sReturn .= '</li>';
               }
               $sReturn .= '</ul>
            </li>
         </ul>';
      }
      echo $sReturn;
   } elseif ($Type == 'String') {
      echo $this->Strings[$Key];
   }
}

$this->CallDelegate('PostElementsRender');

echo '</div>
<div id="Content">';
?>