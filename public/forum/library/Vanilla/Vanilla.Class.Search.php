<?php
/*
* Copyright 2003 Mark O'Sullivan
* This file is part of Vanilla.
* Vanilla is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
* Vanilla is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
* You should have received a copy of the GNU General Public License along with Vanilla; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
* The latest source code for Vanilla is available at www.lussumo.com
* Contact Mark O'Sullivan at mark [at] lussumo [dot] com
*
* Description: Search class (represents a saved search)
*/

class Search {
   var $SearchID;			// The unique identifier assigned to this search by the system
   var $Label;				// The label assigned to this search by the user
   var $Type;				// The type of search to perform
   var $Keywords;			// The keywords defined by the user
	var $Query;				// The actual string to be searched on in the sql query
   var $Categories;		// The category names to search in (comment & discussion search)
   var $AuthUsername;	// The author's username to filter to (comment & discussion search)
   var $WhisperFilter;	// Should the search be limited to whispers
	var $Roles;				// The roles to filter to (user search)
	var $UserOrder;		// The order to sort results in (user search)
   var $HighlightWords;	// Breaks the query into words to be highlighted in search results
	
   // Clears all properties
   function Clear() {
      $this->SearchID = 0;
      $this->Label = '';
      $this->Type = 'Topics';
      $this->Keywords = '';
		$this->Query = '';
      $this->Categories = 0;
      $this->AuthUsername = '';
		$this->WhisperFilter = 0;
		$this->Roles = 0;
		$this->UserOrder = '';
		$this->HighlightWords = array();
   }
	
	function DefineType($InValue) {
      if ($InValue != 'Users' && $InValue != 'Comments') $InValue = 'Topics';
		return $InValue;
	}

   function GetPropertiesFromDataSet($DataSet, $ParseKeywords = '0') {
		$ParseKeywords = ForceBool($ParseKeywords, 0);
		
      $this->SearchID = ForceInt(@$DataSet['SearchID'], 0);
      $this->Label = ForceString(@$DataSet['Label'], '');
      $this->Type = $this->DefineType(ForceString(@$DataSet['Type'], ''));
      $this->Keywords = urldecode(ForceString(@$DataSet['Keywords'], ''));
		if ($ParseKeywords) $this->ParseKeywords($this->Type, $this->Keywords);
   }
    
   function GetPropertiesFromForm() {
      $this->SearchID = ForceIncomingInt('SearchID', 0);
      $this->Label = ForceIncomingString('Label', '');
		$this->Type = $this->DefineType(ForceIncomingString('Type', ''));
		$this->Keywords = urldecode(ForceIncomingString('Keywords', ''));
		
		// Parse out the keywords differently based on the type of search
		$Advanced = ForceIncomingBool('Advanced', 0);
		if ($Advanced) {
			// Load all of the search variables from the form
	      $this->Categories = ForceIncomingString('Categories', '');
			$this->AuthUsername = ForceIncomingString('AuthUsername', '');
			$this->Roles = ForceIncomingString('Roles', '');
			$this->UserOrder = ForceIncomingString('UserOrder', '');
			$this->Query = $this->Keywords;
         
			// Build the keyword definition
         $KeyDef = '';
         if ($this->Type == 'Users') {
				if ($this->Roles != '') $KeyDef = 'roles:'.$this->Roles.';';
				if ($this->UserOrder != '') $KeyDef .= 'sort:'.$this->UserOrder.';';
				$this->Keywords = $KeyDef.$this->Keywords;
			} else {
				if ($this->Categories != '') $KeyDef = 'cats:'.$this->Categories.';';
				if ($this->AuthUsername != '') $KeyDef .= $this->AuthUsername.':';
				$this->Keywords = $KeyDef.$this->Keywords;
			}			
		} else {
			// Load all of the search variables from the keyword definition
         $this->ParseKeywords($this->Type, $this->Keywords);			
		}
   }
	
	function ParseKeywords($Type, $Keywords) {
		if ($Type == 'Users') {
			// Parse twice to hit both of the potential keyword assignment operators (roles or sort)
			$this->Query = $this->ParseUserKeywords($Keywords);
			$this->Query = $this->ParseUserKeywords($this->Query);
		} else {
			// Check for category assignments
			$this->Query = $Keywords;
			$CatPos = strpos($this->Query, 'cats:');
			if ($CatPos !== false && $CatPos == 0) {
				$this->Query = $this->ParsePropertyAssignment('Categories', 5, $this->Query);
			}
			
			// Check for whisper filtering
			$WhisperPos = strpos($this->Query, 'whisper;');
			if ($WhisperPos !== false && $WhisperPos == 0) {
				$this->WhisperFilter = 1;
				$this->Query = substr($this->Query, 8);
			}
			
			// Check for username assignment
         $ColonPos = strpos($this->Query, ':');
			if ($ColonPos !== false && $ColonPos != 0) {
				// If a colon was found, check to see that it didn't occur before any quotes
            $QuotePos = strpos($this->Query, '"');
				
				if ($QuotePos === false || $QuotePos > $ColonPos) {
					$this->AuthUsername = substr($this->Query, 0, $ColonPos);
					$this->Query = substr($this->Query, $ColonPos+1);
				}
			}
		}
		$Highlight = $this->Query;
		if ($Highlight != '') {
			$Highlight = eregi_replace('\'', '', $Highlight);
			$Highlight = eregi_replace(' and ', '', $Highlight);
			$Highlight = eregi_replace(' or ', '', $Highlight);
			$this->HighlightWords = explode(' ', $Highlight);
		}
	}
	
	function ParsePropertyAssignment($Property, $PropertyLength, $Keywords) {
		$sReturn = $Keywords;
		$DelimiterPos = false;
		$sReturn = substr($sReturn, $PropertyLength);
		$DelimiterPos = strpos($sReturn, ';');
		if ($DelimiterPos !== false) {
			$this->$Property = substr($sReturn, 0, $DelimiterPos);
		} else {
			$this->$Property = substr($sReturn, 0);
		}
		return substr($sReturn, $DelimiterPos+1);
	}
	
	function ParseUserKeywords($Keywords) {
		$sReturn = $Keywords;
		// Check for roles or sort definition
		$RolePos = strpos($sReturn, 'roles:');
		$SortPos = strpos($sReturn, 'sort:');
		if ($RolePos !== false && $RolePos == 0) {
			$sReturn = $this->ParsePropertyAssignment('Roles', 6, $sReturn);
		} elseif ($SortPos !== false && $SortPos == 0) {
			$sReturn = $this->ParsePropertyAssignment('UserOrder', 5, $sReturn);			
		}
		return $sReturn;
	}
	
	function FormatPropertiesForDatabaseInput() {
		$this->Label = FormatStringForDatabaseInput($this->Label);
		$this->Keywords = FormatStringForDatabaseInput($this->Keywords);
		$this->Query = FormatStringForDatabaseInput($this->Query);
		$this->AuthUsername = FormatStringForDatabaseInput($this->AuthUsername);
		$this->Categories = FormatStringForDatabaseInput($this->Categories);
		$this->Roles = FormatStringForDatabaseInput($this->Roles);
	}

   function FormatPropertiesForDisplay() {
      $this->Label = FormatStringForDisplay($this->Label);
      $this->Keywords = FormatStringForDisplay($this->Keywords);
      $this->AuthUsername = FormatStringForDisplay($this->AuthUsername);
		$this->Query = FormatStringForDisplay($this->Query);
   }
}
?>