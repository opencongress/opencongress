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
* Description: The NoticeCollector control is simply a control that gathers html
* strings and then spits them out. In Vanilla it is used to report messages to
* administrators.
*/

// Panel control collection
class NoticeCollector extends Control {
	var $CssClass;			// The CSS Class to be applied to the containing div element (default is "Notices")
	var $Notices;			// A collection of customized strings to be echoed
	
	function NoticeCollector(&$Context) {
		$this->Name = 'NoticeCollector';
		$this->Control($Context);
		$this->Notices = array();
      $this->CssClass = "Notices";
	}
	
	function AddNotice($Notice, $Position = '0', $ForcePosition = '0') {
		$this->CallDelegate('AddNotice');
		$Position = ForceInt($Position, 0);
		$this->AddItemToCollection($this->Notices,
			$Notice,
			$Position,
			$ForcePosition);
	}
	
   function Render() {
		if (is_array($this->Notices)) ksort($this->Notices);
		$this->CallDelegate('PreRender');
		include(ThemeFilePath($this->Context->Configuration, 'notices.php'));
		$this->CallDelegate('PostRender');
   }
}
?>