<?php
/*
* Copyright 2003 Mark O'Sullivan
* This file is part of People: The Lussumo User Management System.
* Vanilla is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
* Vanilla is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
* You should have received a copy of the GNU General Public License along with Vanilla; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
* The latest source code for Vanilla is available at www.lussumo.com
* Contact Mark O'Sullivan at mark [at] lussumo [dot] com
*
* Description: The PeopleFoot control is used to render the footer for all "People" pages.
*/

// Writes the page footer
class PeopleFoot extends Control {
	var $CssClass;
	
	function PeopleFoot(&$Context, $CssClass = '') {
		$this->Name = 'ExternalFoot';
		$this->Control($Context);
		$this->CssClass = $CssClass;
	}
	
	function Render() {
		if ($this->CssClass != '') $this->CssClass = ' '.$this->CssClass;
		$this->CallDelegate('PreRender');
		include(ThemeFilePath($this->Context->Configuration, 'people_foot.php'));
		$this->CallDelegate('PostRender');
	}
}
?>