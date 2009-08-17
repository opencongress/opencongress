<?php
/*
* Copyright 2003 Mark O'Sullivan
* This file is part of Lussumo's Software Library.
* Lussumo's Software Library is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
* Lussumo's Software Library is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
* You should have received a copy of the GNU General Public License along with Vanilla; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
* The latest source code is available at www.lussumo.com
* Contact Mark O'Sullivan at mark [at] lussumo [dot] com
* 
* Description: Non-application specific helper functions
* Applications utilizing this file: Vanilla; Filebrowser;
*/

function AddConfigurationSetting(&$Context, $SettingName, $SettingValue = '1') {
	$Context->Configuration[$SettingName] = '';
	$SettingsManager = $Context->ObjectFactory->NewContextObject($Context, 'ConfigurationManager');
	$SettingsFile = $Context->Configuration['APPLICATION_PATH'].'conf/settings.php';
	$SettingsManager->DefineSetting($SettingName, $SettingValue, 1);
	$SettingsManager->SaveSettingsToFile($SettingsFile);	
}

function AddDaysToTimeStamp($TimeStamp, $NumberOfDaysToAdd) {
	if ($NumberOfDaysToSubtract == 0) {
		return $TimeStamp;
	} else {
		return strtotime('+'.$NumberOfDaysToAdd.' day', $TimeStamp);
	}
}

// Append a folder (or file) to an existing path (ensures the / exists)
function AppendFolder($RootPath, $FolderToAppend) {
	if (substr($RootPath, strlen($RootPath)-1, strlen($RootPath)) == '/') $RootPath = substr($RootPath, 0, strlen($RootPath) - 1);
	if (substr($FolderToAppend,0,1) == '/') $FolderToAppend = substr($FolderToAppend,1,strlen($FolderToAppend));
	return $RootPath.'/'.$FolderToAppend;
}

function AppendToConfigurationFile($File, $Append) {
	$Success = 1;
	if (file_exists($File)) {
		$Lines = file($File);
		for ($i = 0; $i < count($Lines); $i++) {
			if (substr($Lines[$i], 0, 2) == '?>') $Lines[$i] = '';
		}
		$Handle = @fopen($File, 'wb');
		if ($Handle) {
			$Lines[] = $Append;
			$Lines[] = '?>';			
			if (!@fwrite($Handle, implode('', $Lines))) $Success = 0;
			@fclose($Handle);
		} else {
			$Success = 0;
		}
	} else {
		$Success = 0;
	}
	return $Success;
}

// Makes sure that a url and some parameters are concatentated properly
// (ie. an ampersand is used instead of a question mark when necessary)
function AppendUrlParameters($Url, $Parameters) {
	$ReturnUrl = $Url;
	$ReturnUrl .= (strpos($Url, '?') === false) ? '?' : '&';
	$ReturnUrl .= $Parameters;
	return $ReturnUrl;
}

// Make sure objects can be cloned in PHP 4 and 5.
// Example: $NewObject = clone ($ObjectName);
// Note: Make sure the space appears between "clone" and the
// first parentheses so that the clone statement in 5
// doesn't break.
if (version_compare(phpversion(), '5.0') < 0) {
	eval('
		function clone($object) {
			return $object;
		}
	');
}

// Append two paths
function ConcatenatePath($OriginalPath, $PathToConcatenate) {
	global $Configuration;
	if (strpos($PathToConcatenate, $Configuration['HTTP_METHOD'].'://') !== false) return $PathToConcatenate;
	if (substr($OriginalPath, strlen($OriginalPath)-1, strlen($OriginalPath)) != '/') $OriginalPath .= '/';
	if (substr($PathToConcatenate,0,1) == '/') $PathToConcatenate = substr($PathToConcatenate,1,strlen($PathToConcatenate));
	return $OriginalPath.$PathToConcatenate;
}

// Based on the total number of items and the number of items per page,
// this function will calculate how many pages there are.
// Returns the number of pages available
function CalculateNumberOfPages($ItemCount, $ItemsPerPage) {
	$TmpCount = ($ItemCount/$ItemsPerPage);
	$RoundedCount = intval($TmpCount);
	$PageCount = 0;
	if ($TmpCount > 1) {
		if ($TmpCount > $RoundedCount) {
			$PageCount = $RoundedCount + 1;
		} else {
			$PageCount = $RoundedCount;
		}
	} else {
		$PageCount = 1;
	}
	return $PageCount;
}

function CleanupString($InString) {
	$Code = explode(',', '&lt;,&gt;,&#039;,&amp;,&quot;,À,Á,Â,Ã,Ä,&Auml;,Å,Ā,Ą,Ă,Æ,Ç,Ć,Č,Ĉ,Ċ,Ď,Đ,Ð,È,É,Ê,Ë,Ē,Ę,Ě,Ĕ,Ė,Ĝ,Ğ,Ġ,Ģ,Ĥ,Ħ,Ì,Í,Î,Ï,Ī,Ĩ,Ĭ,Į,İ,Ĳ,Ĵ,Ķ,Ł,Ľ,Ĺ,Ļ,Ŀ,Ñ,Ń,Ň,Ņ,Ŋ,Ò,Ó,Ô,Õ,Ö,&Ouml;,Ø,Ō,Ő,Ŏ,Œ,Ŕ,Ř,Ŗ,Ś,Š,Ş,Ŝ,Ș,Ť,Ţ,Ŧ,Ț,Ù,Ú,Û,Ü,Ū,&Uuml;,Ů,Ű,Ŭ,Ũ,Ų,Ŵ,Ý,Ŷ,Ÿ,Ź,Ž,Ż,Þ,Þ,à,á,â,ã,ä,&auml;,å,ā,ą,ă,æ,ç,ć,č,ĉ,ċ,ď,đ,ð,è,é,ê,ë,ē,ę,ě,ĕ,ė,ƒ,ĝ,ğ,ġ,ģ,ĥ,ħ,ì,í,î,ï,ī,ĩ,ĭ,į,ı,ĳ,ĵ,ķ,ĸ,ł,ľ,ĺ,ļ,ŀ,ñ,ń,ň,ņ,ŉ,ŋ,ò,ó,ô,õ,ö,&ouml;,ø,ō,ő,ŏ,œ,ŕ,ř,ŗ,š,ù,ú,û,ü,ū,&uuml;,ů,ű,ŭ,ũ,ų,ŵ,ý,ÿ,ŷ,ž,ż,ź,þ,ß,ſ,А,Б,В,Г,Д,Е,Ё,Ж,З,И,Й,К,Л,М,Н,О,П,Р,С,Т,У,Ф,Х,Ц,Ч,Ш,Щ,Ъ,Ы,Э,Ю,Я,а,б,в,г,д,е,ё,ж,з,и,й,к,л,м,н,о,п,р,с,т,у,ф,х,ц,ч,ш,щ,ъ,ы,э,ю,я');
	$Translation = explode(',', ',,,,,A,A,A,A,Ae,A,A,A,A,A,Ae,C,C,C,C,C,D,D,D,E,E,E,E,E,E,E,E,E,G,G,G,G,H,H,I,I,I,I,I,I,I,I,I,IJ,J,K,K,K,K,K,K,N,N,N,N,N,O,O,O,O,Oe,Oe,O,O,O,O,OE,R,R,R,S,S,S,S,S,T,T,T,T,U,U,U,Ue,U,Ue,U,U,U,U,U,W,Y,Y,Y,Z,Z,Z,T,T,a,a,a,a,ae,ae,a,a,a,a,ae,c,c,c,c,c,d,d,d,e,e,e,e,e,e,e,e,e,f,g,g,g,g,h,h,i,i,i,i,i,i,i,i,i,ij,j,k,k,l,l,l,l,l,n,n,n,n,n,n,o,o,o,o,oe,oe,o,o,o,o,oe,r,r,r,s,u,u,u,ue,u,ue,u,u,u,u,u,w,y,y,y,z,z,z,t,ss,ss,A,B,V,G,D,E,YO,ZH,Z,I,Y,K,L,M,N,O,P,R,S,T,U,F,H,C,CH,SH,SCH,Y,Y,E,YU,YA,a,b,v,g,d,e,yo,zh,z,i,y,k,l,m,n,o,p,r,s,t,u,f,h,c,ch,sh,sch,y,y,e,yu,ya');
	$sReturn = $InString;
	$sReturn = str_replace($Code, $Translation, $sReturn);
	$sReturn = urldecode($sReturn);
	$sReturn = preg_replace('/[^A-Za-z0-9 ]/', '', $sReturn);
	$sReturn = str_replace(' ', '-', $sReturn);
	return strtolower(str_replace('--', '-', $sReturn)); 
}

function CreateArrayEntry(&$Array, $Key, $Value) {
	if (!array_key_exists($Key, $Array)) $Array[$Key] = $Value;
}

// performs the opposite of htmlentities
function DecodeHtmlEntities($String) {
	/*
   $TranslationTable = get_html_translation_table(HTML_ENTITIES);
	print_r($TranslationTable);
   $TranslationTable = array_flip($TranslationTable);
   return strtr($String, $TranslationTable);
	
	return html_entity_decode(htmlentities($String, ENT_COMPAT, 'UTF-8'));
   */
   $String= html_entity_decode($String,ENT_QUOTES,'ISO-8859-1'); #NOTE: UTF-8 does not work!
   $String= preg_replace('/&#(\d+);/me','chr(\\1)',$String); #decimal notation
   $String= preg_replace('/&#x([a-f0-9]+);/mei','chr(0x\\1)',$String);  #hex notation
   return $String;
	
}

// Functions
function DefineExtensions(&$Context) {
   $Extensions = array();
   $CurrExtensions = array();
   $CurrentExtensions = @file($Context->Configuration["APPLICATION_PATH"].'conf/extensions.php');
   if (!$CurrentExtensions) {
      $Context->WarningCollector->Add($Context->GetDefinition('ErrReadFileExtensions').$Context->Configuration["APPLICATION_PATH"].'conf/extensions.php');
   } else {
      foreach ($CurrentExtensions as $ExLine) {
         if (substr($ExLine, 0, 7) == 'include') {
            $CurrExtensions[] = substr(trim($ExLine), 43, -15);
         }
      }
   }
    
   // Examine Extensions directory
   $FolderHandle = @opendir($Context->Configuration["EXTENSIONS_PATH"]);
   if (!$FolderHandle) {
      $Context->WarningCollector->Add(
         str_replace("//1", $Context->Configuration["EXTENSIONS_PATH"], $Context->GetDefinition('ErrOpenDirectoryExtensions')));
      return false;
   } else {
      // Loop through each Extension folder
      while (false !== ($Item = readdir($FolderHandle))) {
         $Extension = $Context->ObjectFactory->NewObject($Context, 'Extension');
         $RecordItem = true;
         // skip directories and hidden files
         if (
            strlen($Item) < 1
            || !is_dir($Context->Configuration["EXTENSIONS_PATH"].$Item)
            || !file_exists($Context->Configuration["EXTENSIONS_PATH"].$Item.'/default.php')
            ) continue;

         // Retrieve Extension properties
         $Lines = @file($Context->Configuration["EXTENSIONS_PATH"].$Item.'/default.php');
         if (!$Lines) {
            $Context->WarningCollector->Add($Context->GetDefinition('ErrReadExtensionDefinition')." {$Item}");
         } else {
            // We only examine the first 30 lines of the file
            $Header = array_slice($Lines, 0, 30);
            $Extension->FileName = $Item."/default.php";
            foreach ($Header as $CurrentLine) {
               @list($key, $val) = @explode(': ', trim($CurrentLine), 2);
               switch ($key) {
                  case 'Extension Name':
                     $Extension->Name = FormatStringForDisplay($val);
                     break;
                  case 'Extension Url':
                     $Extension->Url = FormatStringForDisplay($val);
                     break;
                  case 'Description':
                     $Extension->Description = FormatStringForDisplay($val);
                     break;
                  case 'Version':
                     $Extension->Version = FormatStringForDisplay($val);
                     break;
                  case 'Author':
                     $Extension->Author = FormatStringForDisplay($val);
                     break;
                  case 'Author Url':
                     $Extension->AuthorUrl = FormatStringForDisplay($val);
                     break;
                  default:
                     // nothing
               }
            }
            if ($Extension->IsValid()) {
               $Extension->Enabled = in_array($Item, $CurrExtensions);
               $Extensions[FormatExtensionKey($Extension->Name)] = $Extension;
            }
         }
      }
      ksort($Extensions);
      return $Extensions;
   }
}

// This function is compliments of Entriple on the Lussumo Community
function DefineVerificationKey() {
	return md5(
		sprintf(
			'%04x%04x%04x%03x4%04x%04x%04x%04x',
			mt_rand(0, 65535),
			mt_rand(0, 65535),
			mt_rand(0, 4095),
			bindec(substr_replace(sprintf('%016b', mt_rand(0, 65535)), '01', 6, 2)),
			mt_rand(0, 65535),
			mt_rand(0, 65535),
			mt_rand(0, 65535),
			mt_rand(0, 65535)
		)
	);
}

// return the opposite of the given boolean value
function FlipBool($Bool) {
	$Bool = ForceBool($Bool, 0);
	return $Bool?0:1;
}

// Take a value and force it to be an array.
function ForceArray($InValue, $DefaultValue) {
	if(is_array($InValue)) {
		$aReturn = $InValue;
	} else {
		// assume it's a string
		$sReturn = trim($InValue);
		$length = strlen($sReturn);
		if (empty($length) && strlen($sReturn) == 0) {
			$aReturn = $DefaultValue;
		} else {
			$aReturn = array($sReturn);
		}
	}
	return $aReturn;
}

// Force a boolean value
// Accept a default value if the input value does not represent a boolean value
function ForceBool($InValue, $DefaultBool) {
	// If the invalue doesn't exist (ie an array element that doesn't exist) use the default
	if (!$InValue) return $DefaultBool;
	$InValue = strtoupper($InValue);
	if ($InValue == 1) {
		return 1;
	} elseif ($InValue === 0) {
		return 0;
	} elseif ($InValue == 'Y') {
		return 1;
	} elseif ($InValue == 'N') {
		return 0;		
	} elseif ($InValue == 'TRUE') {
		return 1;
	} elseif ($InValue == 'FALSE') {
		return 0;
	} else {
		return $DefaultBool;
	}
}

// Take a value and force it to be a float (decimal) with a specific number of decimal places.
function ForceFloat($InValue, $DefaultValue, $DecimalPlaces = 2) {
	$fReturn = floatval($InValue);
	if ($fReturn == 0) $fReturn = $DefaultValue;
	$fReturn = number_format($fReturn, $DecimalPlaces);
	return $fReturn;
}

// Check both the get and post incoming data for a variable
function ForceIncomingArray($VariableName, $DefaultValue) {
	// First check the querystring
	$aReturn = ForceSet(@$_GET[$VariableName], $DefaultValue);
	$aReturn = ForceArray($aReturn, $DefaultValue);
	// If the default value was defined, then check the post variables
	if ($aReturn == $DefaultValue) {
		$aReturn = ForceSet(@$_POST[$VariableName], $DefaultValue);
		$aReturn = ForceArray($aReturn, $DefaultValue);
	}
	return $aReturn;	
}

// Check both the get and post incoming data for a variable
function ForceIncomingBool($VariableName, $DefaultBool) {
	// First check the querystring
	$bReturn = ForceSet(@$_GET[$VariableName], $DefaultBool);
	$bReturn = ForceBool($bReturn, $DefaultBool);
	// If the default value was defined, then check the post variables
	if ($bReturn == $DefaultBool) {
		$bReturn = ForceSet(@$_POST[$VariableName], $DefaultBool);
		$bReturn = ForceBool($bReturn, $DefaultBool);
	}
	return $bReturn;	
}

function ForceIncomingCookieString($VariableName, $DefaultValue) {
	$sReturn = ForceSet(@$_COOKIE[$VariableName], $DefaultValue);
	$sReturn = ForceString($sReturn, $DefaultValue);
	return $sReturn;	
}

// Check both the get and post incoming data for a variable
// Does not allow integers to be less than 0
function ForceIncomingInt($VariableName, $DefaultValue) {
	// First check the querystring
	$iReturn = ForceSet(@$_GET[$VariableName], $DefaultValue);
	$iReturn = ForceInt($iReturn, $DefaultValue);
	// If the default value was defined, then check the form variables
	if ($iReturn == $DefaultValue) {
		$iReturn = ForceSet(@$_POST[$VariableName], $DefaultValue);
		$iReturn = ForceInt($iReturn, $DefaultValue);
	}
	// If the value found was less than 0, set it to the default value
	if($iReturn < 0) $iReturn == $DefaultValue;

	return $iReturn;	
}

// Check both the get and post incoming data for a variable
function ForceIncomingString($VariableName, $DefaultValue) {
	if (isset($_GET[$VariableName])) {
		return Strip_Slashes(ForceString($_GET[$VariableName], $DefaultValue));
	} elseif (isset($_POST[$VariableName])) {
		return Strip_Slashes(ForceString($_POST[$VariableName], $DefaultValue));
	} else {
		return $DefaultValue;
	}
}

// Take a value and force it to be an integer.
function ForceInt($InValue, $DefaultValue) {
	$iReturn = intval($InValue);
	return ($iReturn == 0) ? $DefaultValue : $iReturn;
}

// Takes a variable and checks to see if it's set. 
// Returns the value if set, or the default value if not set.
function ForceSet($InValue, $DefaultValue) {
	return isset($InValue) ? $InValue : $DefaultValue;
}

// Take a value and force it to be a string.
function ForceString($InValue, $DefaultValue) {
	if (is_string($InValue)) {
		$sReturn = trim($InValue);
		if (empty($sReturn) && strlen($sReturn) == 0) $sReturn = $DefaultValue;
	} else {
		$sReturn = $DefaultValue;
	}
	return $sReturn;
}

function FormatExtensionKey($Key) {
	return preg_replace("/[^[:alnum:]]/i", '', unhtmlspecialchars($Key));
}

function FormatFileSize($FileSize) {
	if ($FileSize > 1048576) {
		return intval((($FileSize / 1048576) * 100) + 0.5) / 100 ."mb";
	} elseif ($FileSize > 1024) {
		return ceil($FileSize / 1024)."kb";
	} else {
		return $FileSize."b";
	}
}

function FormatHyperlink($InString, $ExternalTarget = '1', $LinkText = '', $CssClass = '') {
	$Display = $LinkText;
	if (strpos($InString, 'http://') == 0 && strpos($InString, 'http://') !== false) {
		if ($LinkText == '') {
			$Display = $InString;
			if (substr($Display, strlen($Display)-1,1) == '/') $Display = substr($Display, 0, strlen($Display)-1);
			$Display = str_replace('http://', '', $Display);
		}
	} elseif (strpos($InString, 'mailto:') == 0 && strpos($InString, 'mailto:') !== false) {
		if ($LinkText == '') {
			$Display = str_replace('mailto:', '', $InString);
		}
	} elseif (strpos($InString, 'ftp://') == 0 && strpos($InString, 'ftp://') !== false) {
		if ($LinkText == '') {
			$Display = str_replace('ftp://', '', $InString);
		}
	} elseif (strpos($InString, 'aim:goim?screenname=') == 0 && strpos($InString, 'aim:goim?screenname=') !== false) {
		if ($LinkText == '') {
			$Display = str_replace('aim:goim?screenname=', '', $InString);
		}
	} else {
		return $LinkText == '' ? $InString : $LinkText;
	}
	return '<a href="'.$InString.'"'.($CssClass != '' ? ' class="'.$CssClass.'"' : '').'>'.$Display.'</a>';
}

function FormatHtmlStringForNonDisplay($inValue) {
	return str_replace("\r\n", '<br />', htmlspecialchars($inValue));
}

function FormatHtmlStringInline($inValue, $StripSlashes = '0', $StripTags = '0') {
	// $sReturn = ForceString($inValue, '');
   $sReturn = $inValue;
	if ($StripTags) $sReturn = strip_tags($sReturn);
	if (ForceBool($StripSlashes, 0)) $sReturn = Strip_Slashes($sReturn);
	return str_replace("\r\n", ' ', htmlspecialchars($sReturn));
}

function FormatPlural($Number, $Singular, $Plural) {
	return ($Number == 1) ? $Singular : $Plural;
}

// Formats a value so it's safe to insert into the database
function FormatStringForDatabaseInput($inValue, $bStripHtml = '0') {
	$bStripHtml = ForceBool($bStripHtml, 0);
	// $sReturn = stripslashes($inValue);
   $sReturn = $inValue;
	if ($bStripHtml) $sReturn = trim(strip_tags($sReturn));
	// return MAGIC_QUOTES_ON ? $sReturn : addslashes($sReturn);
   return addslashes($sReturn);
}

// Takes a user defined string and formats it for page display. 
// You can optionally remove html from the string.
function FormatStringForDisplay($inValue, $bStripHtml = true, $AllowEncodedQuotes = true) {
	$sReturn = trim($inValue);
	if ($bStripHtml) $sReturn = strip_tags($sReturn);
	if (!$AllowEncodedQuotes) $sReturn = preg_replace("/(\"|\')/", '', $sReturn);
	global $Configuration;
	$sReturn = htmlspecialchars($sReturn, ENT_QUOTES, $Configuration['CHARSET']);
	if ($bStripHtml) $sReturn = str_replace("\r\n", "<br />", $sReturn);
	return $sReturn;
}

function GetBasicCheckBox($Name, $Value = 1, $Checked, $Attributes = '') {
	return '<input type="checkbox" name="'.$Name.'" value="'.$Value.'" '.(($Checked == 1)?' checked="checked"':'').' '.$Attributes.' />';
}

function GetBool($Bool, $True = 'Yes', $False = 'No') {
	return ($Bool ? $True : $False);
}

function GetDynamicCheckBox($Name, $Value = 1, $Checked, $OnClick, $Text, $Attributes = '', $CheckBoxID = '') {
	if ($CheckBoxID == '') $CheckBoxID = $Name.'ID';
	$Attributes .= ' id="'.$CheckBoxID.'"';
	if ($OnClick != '') $Attributes .= ' onclick="'.$OnClick.'"';
   return '<label for="'.$CheckBoxID.'">'.GetBasicCheckBox($Name, $Value, $Checked, $Attributes).' '.$Text.'</label>';
}

function GetEmail($Email, $LinkText = '') {
	if ($Email == '') {
		return '&nbsp;';
	} else {
		$EmailParts = explode('@', $Email);
		if (count($EmailParts) == 2) {
			return "<script type=\"text/javascript\">\r\nWriteEmail('".$EmailParts[1]."', '".$EmailParts[0]."', '".$LinkText."');\r\n</script>";
		} else {
			// Failsafe
			return '<a href="mailto:'.$Email.'">'.($LinkText==''?$Email:$LinkText).'</a>';
		}
	}
}

function GetImage($ImageUrl, $Height = '', $Width = '', $TagIdentifier = '', $EmptyImageReplacement = '&nbsp;') {
	$sReturn = '';
	if (ReturnNonEmpty($ImageUrl) == '&nbsp;') {
		$sReturn =  $EmptyImageReplacement;
	} else {
		$sReturn = '<img src="'.$ImageUrl.'"';
		if ($Height != '') $sReturn .= ' height="'.$Height.'"';
		if ($Width != '') $sReturn .= ' width="'.$Width.'"';
		if ($TagIdentifier != '') $sReturn .= ' id="'.$TagIdentifier.'"';
		$sReturn .= ' alt="" />';
	}
	return $sReturn;
}

function GetRemoteIp($FormatIpForDatabaseInput = '0') {
	$FormatIpForDatabaseInput = ForceBool($FormatIpForDatabaseInput, 0);
	$sReturn = ForceString(@$_SERVER['REMOTE_ADDR'], '');
	if (strlen($sReturn) > 20) $sReturn = substr($sReturn, 0, 19);
	if ($FormatIpForDatabaseInput) $sReturn = FormatStringForDatabaseInput($sReturn, 1);
	return $sReturn;	
}

function GetRequestUri() {
	global $Configuration;
	$Host = ForceString($_SERVER['HTTP_HOST'], '');
	if ($Host != '') $Host = PrependString($Configuration['HTTP_METHOD'].'://', $Host);
	$Path = @$_SERVER['REQUEST_URI'];
	// If the path wasn't provided in the REQUEST_URI variable, let's look elsewhere for it
	if ($Path == '') $Path = @$_SERVER['HTTP_X_REWRITE_URL']; // Some servers use this instead
   // If the path still wasn't found, let's try building it with other variables
   if ($Path == '') {
		$Path = @$_SERVER['SCRIPT_NAME'];
		$Path .= (@$_SERVER['QUERY_STRING'] == '' ? '' : '?' . @$_SERVER['QUERY_STRING']);
	}
	$FullPath = ConcatenatePath($Host, $Path);
	return FormatStringForDisplay($FullPath);
}

function GetTableName($Key, &$TableCollection, $Prefix) {
	if ($Key == "User") {
		return $TableCollection[$Key];
	} else {
		return $Prefix.$TableCollection[$Key];
	}
}

function GetUrl(&$Configuration, $PageName, $Divider = '', $Key = '', $Value = '', $PageNumber='', $Querystring='', $Suffix = '') {
	if ($Configuration['URL_BUILDING_METHOD'] == 'mod_rewrite') {
		if ($PageName == './') $PageName = 'index.php';
		return $Configuration['BASE_URL']
			.($PageName == 'index.php' && $Value != '' ? '' : $Configuration['REWRITE_'.$PageName])
			.(strlen($Value) != 0 ? $Divider : '')
			.(strlen($Value) != 0 ? $Value.'/' : '')
			.(($PageNumber != '' && $PageNumber != '0' && $PageNumber != '1') ? $PageNumber.'/' : '')
			.($Suffix != '' ? $Suffix : '')
			.($Querystring != '' && substr($Querystring, 0, 1) != '#' ? '?' : '')
			.($Querystring != '' ? $Querystring : '');
	} else {
		if ($PageName == './' || $PageName == 'index.php') $PageName = '';
		$sReturn = ($Value != '' && $Value != '0' ? $Key.'='.$Value : '');
		if ($PageNumber != '') {
			if ($sReturn != '') $sReturn .= '&amp;';
			$sReturn .= 'page='.$PageNumber;
		}
		if ($Querystring != '' && substr($Querystring, 0, 1) != '#') {
			if ($sReturn != '') $sReturn .= '&amp;';
			$sReturn .= $Querystring;
		}
		if ($sReturn != '') $sReturn = '?'.$sReturn;
		if ($Querystring != '' && substr($Querystring, 0, 1) == '#') $sReturn .= $Querystring;
		return $Configuration['BASE_URL'].$PageName.$sReturn;
	}
}

// Create the html_entity_decode function for users prior to PHP 4.3.0
if (!function_exists('html_entity_decode')) {
	function html_entity_decode($String) {
		return strtr($String, array_flip(get_html_translation_table(HTML_ENTITIES)));
	}
}

// allows inline if statements
function Iif($Condition, $True, $False) {
	return $Condition ? $True : $False;
}

// Checks for a custom version of the specified file
// Returns the path to the custom file (if it exists) or the default otherwise
function ThemeFilePath(&$Configuration, $FileName) {
	if (file_exists($Configuration['THEME_PATH'].$FileName)) {
		return $Configuration['THEME_PATH'].$FileName;
	} else {
		return $Configuration["APPLICATION_PATH"]."themes/".$FileName;
	}
}

function MysqlDateTime($Timestamp = '') {
	if ($Timestamp == '') $Timestamp = mktime();
	return date('Y-m-d H:i:s', $Timestamp);
}

function OpenURL($URL, &$Context) {
	$ParsedUrl = parse_url($URL);
	$Host = ForceString(@$ParsedUrl['host'], '');
	$Port = ForceInt(@$ParsedUrl['port'], 0);
	if ($Port == 0) $Port = 80;
	$Path = (array_key_exists('path', $ParsedUrl)) ? $ParsedUrl['path'] : '';
	if (empty($Path)) $Path = '/';
	if (array_key_exists('query', $ParsedUrl) && $ParsedUrl['query'] != '') {
		// Do some encoding and cleanup on the querystring
      $QueryString = urlencode($ParsedUrl['query']);
		$QueryString = str_replace(array('%26', '%3D'), array('&', '='), $QueryString);
		$Path .= '?' . $QueryString;
	}
	
	$UrlContents = false;
	
	if (empty($Host)) {
		$Context->WarningCollector->Add(str_replace('\\1', $URL, $Context->GetDefinition('InvalidHostName')));
	} else {
		$Headers = "GET $Path HTTP/1.0\r\nHost: $Host\r\n\r\n";
		// echo("<div>$Headers</div>");
		$ErrorNumber = '';
		$ErrorMessage = '';
		$Handle = @fsockopen($Host, $Port, $ErrorNumber, $ErrorMessage, 30);
		if (!$Handle) {
			$Context->WarningCollector->Add(str_replace('\\1', $Host, $Context->GetDefinition("ErrorFopen")).($php_errormsg ? str_replace('\\1', $php_errormsg, $Context->GetDefinition('ErrorFromPHP')) : ''));
		} else {
			fwrite($Handle, $Headers);
			$UrlContents = '';
			$HeaderFinished = false;
			$String = '';
			while (!feof($Handle)) {
				 $String = fgets($Handle, 128);
				 if ($HeaderFinished) $UrlContents .= $String;
				 if ($String == "\r\n") $HeaderFinished = true;
			}
			fclose($Handle);
		}
	}
	return $UrlContents;
}

function PrefixString($string, $prefix, $length) {
	if (strlen($string) >= $length) {
		return $string;
	} else {
		return substr(($prefix.$string),strlen($prefix.$string)-$length, $length);
	}
}

function PrependString($Prepend, $String) {
	$pos = strpos(strtolower($String), strtolower($Prepend));
	if (($pos !== false && $pos == 0) || $String == '') {
		return $String;
	} else {
		return $Prepend.$String;
	}
}

function RemoveIllegalChars($FileName) {
	return preg_replace('![\s<"\']+!s', '', $FileName);
}

// If a value is empty, return the non-empty value
function ReturnNonEmpty($InValue, $NonEmptyValue = '&nbsp;') {
	return trim($InValue) == '' ? $NonEmptyValue : $InValue;
}

function SaveAsDialogue($FolderPath, $FileName, $DeleteFile = '0') {
	$DeleteFile = ForceBool($DeleteFile, 0);
	if ($FolderPath != '') {
		if (substr($FolderPath,strlen($FolderPath)-1) != '/') $FolderPath = $FolderPath.'/';
	}
	$FolderPath = $FolderPath.$FileName;
	header('Pragma: public');
	header('Expires: 0');
	header('Cache-Control: must-revalidate, post-check=0, pre-check=0'); 
	header('Content-Type: application/force-download');
	header('Content-Type: application/octet-stream');
	header('Content-Type: application/download');
	header('Content-Disposition: attachment; filename="'.$FileName.'"');
	header('Content-Transfer-Encoding: binary');
	readfile($FolderPath);
	if ($DeleteFile) unlink($FolderPath);
	die();
}

function SerializeArray($InArray) {
	$sReturn = '';
	if (is_array($InArray)) {
		if (count($InArray) > 0) {
			$sReturn = serialize($InArray);
			$sReturn = addslashes($sReturn);
		}
	}
	return $sReturn;
}

// Cuts a string to the specified length. 
// Then moves back to the previous space so words are not sliced half-way through.
function SliceString($InString, $Length) {
	$Space = ' ';
	$sReturn = '';
	if (strlen($InString) > $Length) {
		$sReturn = substr(trim($InString), 0, $Length); 
		$sReturn = substr($sReturn, 0, strlen($sReturn) - strpos(strrev($sReturn), $Space));
	   $sReturn .= '...';
	} else {
		$sReturn = $InString;
	}
	return $sReturn;
}

function Strip_Slashes($InString) {
	return MAGIC_QUOTES_ON ? stripslashes($InString) : $InString;		
}

function SubtractDaysFromTimeStamp($TimeStamp, $NumberOfDaysToSubtract) {
	if ($NumberOfDaysToSubtract == 0) {
		return $TimeStamp;
	} else {
		return strtotime('-'.$NumberOfDaysToSubtract.' day', $TimeStamp);
	}
}

function TimeDiff(&$Context, $Time, $TimeToCompare = '') {
	if ($TimeToCompare == '') $TimeToCompare = time();
	$Difference = $TimeToCompare-$Time;
	$Days = floor($Difference/60/60/24);
   
	if ($Days > 7) {
		return date($Context->GetDefinition('OldPostDateFormatCode'), $Time);
	} elseif ($Days > 1) {
		return str_replace('//1', $Days, $Context->GetDefinition('XDaysAgo'));
	} elseif ($Days == 1) {
		return str_replace('//1', $Days, $Context->GetDefinition('XDayAgo'));
	} else {
		
		$Difference -= $Days*60*60*24;
		$Hours = floor($Difference/60/60);
		if ($Hours > 1) {
			return str_replace('//1', $Hours, $Context->GetDefinition('XHoursAgo'));
		} elseif ($Hours == 1) {
			return str_replace('//1', $Hours, $Context->GetDefinition('XHourAgo'));
		} else {
			
			$Difference -= $Hours*60*60;
			$Minutes = floor($Difference/60);			
			if ($Minutes > 1) {
				return str_replace('//1', $Minutes, $Context->GetDefinition('XMinutesAgo'));
			} elseif ($Minutes == 1) {
				return str_replace('//1', $Minutes, $Context->GetDefinition('XMinuteAgo'));
			} else {
				
				$Difference -= $Minutes*60;
				$Seconds = $Difference;
				if ($Seconds == 1) {
					return str_replace('//1', $Seconds, $Context->GetDefinition('XSecondAgo'));
				} else {
					return str_replace('//1', $Seconds, $Context->GetDefinition('XSecondsAgo'));
				}
			}
		}
	}
}

function unhtmlspecialchars($String) {
	 $String = str_replace('&amp;', '&', $String);
	 $String = str_replace('&#039;', '\'', $String);
	 $String = str_replace('&quot;', '\"', $String);
	 $String = str_replace('&lt;', '<', $String);
	 $String = str_replace('&gt;', '>', $String);
	 return $String;
}

// Convert a datetime to a timestamp
function UnixTimestamp($DateTime) {
	if (preg_match('/^(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2})$/', $DateTime, $Matches)) {
		$Year = $Matches[1];
		$Month = $Matches[2];
		$Day = $Matches[3];
		$Hour = $Matches[4];
		$Minute = $Matches[5];
		$Second = $Matches[6];
		return mktime($Hour, $Minute, $Second, $Month, $Day, $Year);
	
	} elseif (preg_match('/^(\d{4})-(\d{2})-(\d{2})$/', $DateTime, $Matches)) {
		$Year = $Matches[1];
		$Month = $Matches[2];
		$Day = $Matches[3];	
		return mktime(0, 0, 0, $Month, $Day, $Year);	
	}
}

function UnserializeArray($InSerialArray) {
	$aReturn = array();
	if ($InSerialArray != '' && !is_array($InSerialArray)) {
		$aReturn = unserialize($InSerialArray);
		if (is_array($aReturn)) {
			$Count = count($aReturn);
			$i = 0;
			for ($i = 0; $i < $Count; $i++) {
				$aReturn[$i] = array_map('Strip_Slashes', $aReturn[$i]);
			}
		}
	}
	return $aReturn;	
}

function UnserializeAssociativeArray($InSerialArray) {
	$aReturn = array();
	if ($InSerialArray != '' && !is_array($InSerialArray)) {
		$aReturn = @unserialize($InSerialArray);
		if (!is_array($aReturn)) $aReturn = array();
	}
	return $aReturn;	
}

// Instantiate a simple validator
function Validate($InputName, $IsRequired, $Value, $MaxLength, $ValidationExpression, &$Context) {
	$Validator = $Context->ObjectFactory->NewContextObject($Context, 'Validator');
	$Validator->InputName = $InputName;
	$Validator->isRequired = $IsRequired;
	$Validator->Value = $Value;
	$Validator->MaxLength = $MaxLength;
	if ($ValidationExpression != '') {
		$Validator->ValidationExpression = $ValidationExpression;
		$Validator->ValidationExpressionErrorMessage = $Context->GetDefinition('ErrImproperFormat').' '.$InputName;
	}
	return $Validator->Validate();
}

function WriteEmail($Email, $LinkText = '') {
	echo(GetEmail($Email, $LinkText));
}
	
?>