<?php
/*
Extension Name: Extended Text Formatter
Extension Url: http://lussumo.com/docs/
Description: Extends the text formatter to make it replace /me and autolink urls.
Version: 1.2
Author: Mark O'Sullivan
Author Url: N/A

Copyright 2003 - 2005 Mark O'Sullivan
This file is part of Lussumo's Software Library.
Lussumo's Software Library is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
Lussumo's Software Library is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
You should have received a copy of the GNU General Public License along with Vanilla; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
The latest source code is available at www.lussumo.com
Contact Mark O'Sullivan at mark [at] lussumo [dot] com
*/

if (in_array($Context->SelfUrl, array("comments.php", "post.php"))) {
   // An implementation of the string filter interface for plain text strings
   class ExtendedTextFormatter extends StringFormatter {
      function Parse ($String, $Object, $FormatPurpose) {
         $sReturn = $String;
         // Only format plain text strings if they are being displayed (save in database as is)
         if ($FormatPurpose == FORMAT_STRING_FOR_DISPLAY) {
            $sReturn = $this->AutoLink($sReturn);
            $sReturn = preg_replace("/\/\bme\b/", $this->GetAccountLink($Object), $sReturn);
         }
         return $sReturn;
      }

      function AutoLink($String) {

		$String = str_replace(array("&quot;","&amp;"),array('"','&'),$String);
		$String = preg_replace(
            "/
			(?<!<a href=\")
			(?<!\")(?<!\">)
			((https?|ftp):\/\/)
			([\@a-z0-9\x21\x23-\x27\x2a-\x2e\x3a\x3b\/;\x3f-\x7a\x7e\x3d]+)
			/msxi",
			"<a href=\"$0\" target=\"_blank\" rel=\"nofollow\">$0</a>",
			$String);
        return $String;
      }

      function GetAccountLink($Object) {
         if (isset($Object->AuthUserID) && $Object->AuthUserID != "" && isset($Object->AuthUsername) && $Object->AuthUsername != "") {
            return '<a href="'.GetUrl($Object->Context->Configuration, 'account.php', '', 'u', $Object->AuthUserID).'">'.$Object->AuthUsername.'</a>';
         } else {
            return '/me';
         }
      }
   }
   
   $ExtendedTextFormatter = $Context->ObjectFactory->NewObject($Context, "ExtendedTextFormatter");
   $Context->StringManipulator->Formatters[$Configuration["DEFAULT_FORMAT_TYPE"]]->AddChildFormatter($ExtendedTextFormatter);
}

?>