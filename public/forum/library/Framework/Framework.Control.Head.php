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
* Description: The Head control is used to display all of the elements in the html head of the page.
*/

// Writes out the page head
class Head extends Control {
	var $Scripts;			// Script collection
	var $StyleSheets;		// Stylesheet collection
   var $Strings;			// String collection
   var $BodyId;			// identifier assigned to the body tag
   var $Meta;				// An associative array of meta tags/content to be added to the head.
	
	function AddScript($ScriptLocation, $ScriptRoot = '~') {
		if (!is_array($this->Scripts)) $this->Scripts = array();
		if ($ScriptRoot == '~') $ScriptRoot = $this->Context->Configuration['WEB_ROOT'];
		$ScriptPath = $ScriptLocation;
		if ($ScriptRoot != '') $ScriptPath = ConcatenatePath($ScriptRoot, $ScriptLocation);
		$this->Scripts[] = $ScriptPath;
	}
	
	function AddStyleSheet($StyleSheetLocation, $Media = '', $Position = '100', $StyleRoot = '~') {
		if ($StyleRoot == '~') $StyleRoot = $this->Context->Configuration['WEB_ROOT'];
		if (!is_array($this->StyleSheets)) $this->StyleSheets = array();
		$StylePath = $StyleSheetLocation;
		if ($StylePath != '') $StylePath = ConcatenatePath($StyleRoot, $StyleSheetLocation);
		$this->InsertItemAt($this->StyleSheets,
			array('Sheet' => $StylePath, 'Media' => $Media),
			$Position);
	}
	
	function AddString($String) {
		if (!is_array($this->Strings)) $this->Strings = array();
		$this->Strings[] = $String;
	}
	
	function Clear() {
		$this->ClearStrings();
		$this->ClearStyleSheets();
		$this->ClearScripts();		
	}
	
	function ClearStrings() {
		$this->Strings = array();
	}
	
	function ClearStyleSheets() {
		$this->StyleSheets = array();
	}
	
	function ClearScripts() {
		$this->Scripts = array();
	}

	function Head(&$Context) {
		$this->Name = 'Head';
		$this->BodyId = '';
		$this->Control($Context);
		$this->Meta = array();
	}
	
   function Render() {
		// First sort the stylesheets by key
      if (is_array($this->StyleSheets)) ksort($this->StyleSheets);
		$this->CallDelegate('PreRender');
		include(ThemeFilePath($this->Context->Configuration, 'head.php'));
		$this->CallDelegate('PostRender');
   }
}
?>