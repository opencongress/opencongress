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
* Description: Object representation of an extension in the Lussumo Framework.
* Applications using this file: Vanilla, Swell, etc (all Lussumo products)
*/

class Extension {
   var $Name;
   var $Url;
   var $Description;
   var $Version;
   var $Author;
   var $AuthorUrl;
	var $FileName;
	var $Enabled;
   
   function Clear() {
      $this->Name = '';
      $this->Url = '';
      $this->Description = '';
      $this->Version = '';
      $this->Author = '';
      $this->AuthorUrl = '';
		$this->FileName = '';
		$this->Enabled = 0;
   }
   
   function Extension() {
      $this->Clear();
   }
   
   function IsValid() {
      $Valid = 1;
      if ($this->Name == '') $Valid = 0;
      if ($this->Url == '') $Valid = 0;
      if ($this->Description == '') $Valid = 0;
      if ($this->Version == '') $Valid = 0;
      if ($this->Author == '') $Valid = 0;
      if ($this->AuthorUrl == '') $Valid = 0;
      return $Valid;
   }
}
?>