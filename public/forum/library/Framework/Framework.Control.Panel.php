<?php
/*
* Copyright 2003 Mark O'Sullivan
* This file is part of The Lussumo Software Library.
* Vanilla is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
* Vanilla is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
* You should have received a copy of the GNU General Public License along with Vanilla; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
* The latest source code for Vanilla is available at www.lussumo.com
* Contact Mark O'Sullivan at mark [at] lussumo [dot] com
*
* Description: The Panel control is used to display a sidebar/control panel.
*/

// Panel control collection
class Panel extends Control {
	var $CssClass;			// The CSS Class to be applied to the containing panel element
   var $BodyCssClass;	// The CSS Class to be applied to the adjacent body element
	var $Lists;				// A collection of list items to be placed in the panel
	var $Strings;			// A collection of customized strings to be placed in the panel
	var $PanelElements;	// A collection of elements to be placed in the panel (strings, lists, etc)
   var $Template;			// Allows a custom template to be used in the panel on different pages
	
	function Panel(&$Context, $Template = '') {
		$this->Name = 'Panel';
		$this->Control($Context);
		$this->Lists = array();
		$this->Strings = array();
		$this->PanelElements = array();
		$this->NewDiscussionText = '';
		$this->NewDiscussionAttributes = '';
		$this->Template = $Template != '' ? $Template : 'panel.php';
	}
	
	function AddList($ListName, $Position = '0', $ForcePosition = '0') {
		$this->CallDelegate('AddList');
		$Position = ForceInt($Position, 0);
		if (!array_key_exists($ListName, $this->Lists)) {
			$this->AddItemToCollection($this->PanelElements,
				array('Type' => 'List', 'Key' => $ListName),
				$Position,
				$ForcePosition);			
			$this->Lists[$ListName] = array();
		}
	}
	
	// ListName is the name of the list you want to add this item to (if the list does not exist, it will be created)
	function AddListItem($ListName, $Item, $Link, $Suffix = '', $LinkAttributes = '', $Position = '0', $ForcePosition = '0') {
		$this->CallDelegate('AddListItem');
		$this->AddList($ListName);
		$Position = is_numeric($Position) ? $Position : -1;
		$ListItem = array('Item' => $Item, 'Link' => $Link, 'Suffix' => $Suffix, 'LinkAttributes' => $LinkAttributes);
		$this->AddItemToCollection($this->Lists[$ListName], $ListItem, $Position, $ForcePosition);
	}
	
	function AddString($String, $Position = '0', $ForcePosition = '0') {
		$this->CallDelegate('AddString');
		$Position = ForceInt($Position, 0);
		$StringKey = count($this->Strings);
		$this->Strings[] = $String;
		$this->AddItemToCollection($this->PanelElements,
			array('Type' => 'String', 'Key' => $StringKey),
			$Position,
			$ForcePosition);
	}
	
   function Render() {
		if (is_array($this->PanelElements)) ksort($this->PanelElements);
		if ($this->CssClass != '') $this->CssClass = ' '.$this->CssClass;
		$this->CallDelegate('PreRender');
		include(ThemeFilePath($this->Context->Configuration, $this->Template));
		$this->CallDelegate('PostRender');
   }
}
?>