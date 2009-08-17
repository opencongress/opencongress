<?php
// Note: This file is included from the library/Framework/Framework.ErrorManager.class.php
// file in the ErrorManager class.

echo '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
   <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en-ca">
   <head>
   <title>The page could not be displayed</title>
   <base href="'.$Context->Configuration['BASE_URL'].'" />
   ';
   if ($this->StyleSheet == '') {
      echo '<link rel="stylesheet" type="text/css" href="'.$Context->StyleUrl.'utility.css" />';
   } else {
      echo '<link rel="stylesheet" href="'.$this->StyleSheet.'" />
      ';
   }
   echo '</head>
   <body>
   <div class="PageContainer">
      <h1>A fatal, non-recoverable error has occurred</h1>
      <h2>Technical information (for support personel):</h2>';
      $ErrorCount = count($this->Errors);
      for ($i = 0; $i < $ErrorCount; $i++) {
         echo '<dl>
            <dt>Error Message</dt>
            <dd>'.ForceString($this->Errors[$i]->Message, 'No error message supplied').'</dd>
            <dt>Affected Elements</dt>
            <dd>'.ForceString($this->Errors[$i]->AffectedElement, 'undefined').'.'.ForceString($this->Errors[$i]->AffectedFunction, 'undefined').'();</dd>
         </dl>';
         $Code = ForceString($this->Errors[$i]->Code, '');
         if ($Code != '') {
            echo '<blockquote>The error occurred on or near:
               <code>'.$Code.'</code>
               </blockquote>';
         }
      }
      if ($Context) {
         if ($Context->Mode == MODE_DEBUG && $Context->SqlCollector && $Context->SqlCollector->Count() > 0) {
            echo '<h2>Database queries run prior to error</h2>';
            $Context->SqlCollector->Write();
         }
      }
      echo '<p>For additional support documentation, visit the Lussumo Documentation website at: <a href="http://lussumo.com/docs">lussumo.com/docs</a></p>
   </div>
</body>
</html>';
?>