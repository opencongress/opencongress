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
* Description: Handles objects global to page execution and adding elements to the page.
* Applications utilizing this file: Vanilla;
*/
class Page {
   // Private Properties
   var $Controls;          // An associative array of control collections
   var $Context;
   var $Events;				// An array of ordered event names to be fired
   
   // Add a control to an event
   function AddControl($Event, $Control, $Position = '0') {
		$Position = ForceInt($Position, -1);
		if ($Position >= 0) {
			// Create the key/array if it doesn't exist yet
			if (!array_key_exists($Event, $this->Controls)) $this->Controls[$Event] = array();
			$this->InsertControlAt($this->Controls[$Event], $Control, $Position);
		} else {
	      $this->Controls[$Event][] = $Control;
		}
   }
	
	// Add a control to the 'Page_Render' event
	function AddRenderControl($Control, $Position = '0') {
		$this->AddControl('Page_Render', $Control, $Position);
	}
   
   function FireEvent($Event) {
      // Loop through the elements of this type and write them.
      if (array_key_exists($Event, $this->Controls)) $this->WriteControls($this->Controls[$Event]);
		// Destruct
		if ($Event == 'Page_Unload') $this->Context->Unload();
   }
	
	function FireEvents() {
		$EventCount = count($this->Events);
		$i = 0;
		for ($i = 0; $i < $EventCount; $i++) {
			$this->FireEvent($this->Events[$i]);
		}
	}
	
	function InsertControlAt(&$Collection, $Control, $Position) {
		if (array_key_exists($Position, $Collection)) {
			$this->InsertControlAt($Collection, $Collection[$Position], $Position+1);
		}
		$Collection[$Position] = $Control;
	}
   
   // Constructor
   function Page(&$Context, $Events) {
		$this->Context = &$Context;
		$this->Controls = array();
		$this->Events = $Events;
   }
	
   function WriteControls($Controls) {
      // Loop through the controls and write them
      if (is_array($Controls)) {
			ksort($Controls);
			while (list($key, $Control) = each($Controls)) {
				$Control->Render();         
			}
		}
   }
}
?>