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
* Description: Class that builds and maintains a list of messages. It is generally used for holding and then dumping user input errors.
* Applications utilizing this file: Vanilla;
*/
class MessageCollector {
	var $aMessages = array();
	var $CssClass = 'Error';
	
	function Add($sMessage) {
		$this->aMessages[] = $sMessage;	
	}
	
	function Clear() {
		$this->aMessages = array();
	}
	
	function Count() {
		return count($this->aMessages);
	}
	
	function GetMessages() {
		$sReturn = '';
		$i = 0;
		$MessageCount = $this->Count();
		for($i = 0; $i < $MessageCount; $i++) {
			$sReturn .= '<div class="'.$this->CssClass.'">'.$this->aMessages[$i].'</div>
			';
		}
		return $sReturn;	
	}
	
	function GetPlainMessages() {
		$sReturn = '';
		$i = 0;
		$MessageCount = $this->Count();
		for($i = 0; $i < $MessageCount; $i++) {
			$sReturn .= $this->aMessages[$i].'
			';
		}
		return $sReturn;	
	}
	
	function Iif($True = '1', $False = '0') {
		if ($this->Count() == 0) {
			return $True;
		} else {
			return $False;			
		}
	}
	
	function Write() {
		echo $this->GetMessages();
	}
	
	function WritePlain() {
		echo $this->GetPlainMessages();
	}
}
?>