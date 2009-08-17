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
* Description: Manages the global variables for the context of the page.
* Applications utilizing this file: Vanilla;
*/
class Context {
   // Public Properties
   var $Authenticator;
   var $Session;
   var $Database;
   var $WarningCollector;
   var $ErrorManager;
   var $SqlCollector;
	var $ObjectFactory;
   var $SelfUrl;
   var $StyleUrl;
   var $Mode;              // Debug, Release, etc
   var $BodyAttributes;
   var $PageTitle;
	var $StringManipulator;
	var $Dictionary;
	var $Configuration;
	var $DelegateCollection;
	var $DatabaseTables;
	var $DatabaseColumns;
	var $PassThruVars;		// An associative array of variables that can be passed down through the context object into various parts of the application
   
	function AddToDelegate($ClassName, $DelegateName, $FunctionName) {
		if (!array_key_exists($ClassName, $this->DelegateCollection)) $this->DelegateCollection[$ClassName] = array();
		if (!array_key_exists($DelegateName, $this->DelegateCollection[$ClassName])) $this->DelegateCollection[$ClassName][$DelegateName] = array();
		$this->DelegateCollection[$ClassName][$DelegateName][] = $FunctionName;
	}
	
   // Constructor
   function Context(&$Configuration) {
		$this->Configuration = &$Configuration;
		$this->BodyAttributes = '';
		$this->StyleUrl = '';
		$this->PageTitle = '';		
		$this->Dictionary = array();
		$this->DelegateCollection = array();
		$this->PassThruVars = array();
		
		$this->CommentFormats = array();
		$this->CommentFormats[] = 'Text';
		
		// Create an object factory
      $this->ObjectFactory = new ObjectFactory();

      // Current Mode
      $this->Mode = ForceIncomingCookieString('Mode', '');
		
      // Url of the current page (this should be hard-coded by each page since php server vars are unreliable)
      $this->SelfUrl = ForceString($Configuration['SELF_URL'], 'index.php');
      
      // Instantiate a SqlCollector (for debugging)
      $this->SqlCollector = new MessageCollector();
      $this->SqlCollector->CssClass = 'Sql';
      
      // Instantiate a Warning collector (for user errors)
      $this->WarningCollector = new MessageCollector();
      
      // Instantiate an Error manager (for fatal errors)
      $this->ErrorManager = new ErrorManager();
		
      // Instantiate a Database object (for performing database actions)
      $this->Database = new $Configuration['DATABASE_SERVER']($this);
      
		// Instantiate the string manipulation object
      $this->StringManipulator = new StringManipulator($this->Configuration);
		// Add the plain text manipulator
      $TextFormatter = new TextFormatter();
		$this->StringManipulator->AddManipulator($Configuration['DEFAULT_FORMAT_TYPE'], $TextFormatter);
   }
	
	function FormatString($String, $Object, $Format, $FormatPurpose) {
		$sReturn = $this->StringManipulator->Parse($String, $Object, $Format, $FormatPurpose);
		// Now pass the string through global formatters
      $sReturn = $this->StringManipulator->GlobalParse($sReturn, $Object, $FormatPurpose);
		return $sReturn;
	}
	
	function GetDefinition($Code) {
      if (array_key_exists($Code, $this->Dictionary)) {
         return $this->Dictionary[$Code];
      } else {
         return $Code;
      }
	}

	// Can be used by extensions to define new definitions. This way, if a
   // translation exists in the translation file, the definition in the
   // extension will not override it.
	function SetDefinition($Code, $Definition) {
      if (!array_key_exists($Code, $this->Dictionary)) {
         $this->Dictionary[$Code] = $Definition;
      }
	}
	
	function StartSession() {
      $this->Authenticator = $this->ObjectFactory->NewContextObject($this, 'Authenticator');
		$this->Session = $this->ObjectFactory->NewObject($this, 'PeopleSession');
		$this->Session->Start($this, $this->Authenticator);
		// The style url (as defined by the user session)
      if (@$this->Session->User) {
			$this->StyleUrl = $this->Session->User->StyleUrl;
			// Make sure that the Database object knows what the StyleUrl is
         $this->Database->Context->StyleUrl = $this->StyleUrl;
		}
	}
	
	// Destructor
	function Unload() {
		if ($this->Database) $this->Database->CloseConnection();
		unset($this->Authenticator);
		unset($this->Session);
		unset($this->Database);
		unset($this->WarningCollector);
		unset($this->ErrorManager);
		unset($this->SqlCollector);
		unset($this->SelfUrl);
		unset($this->StyleUrl);
		unset($this->Mode);
		unset($this->BodyAttributes);
		unset($this->PageTitle);
		unset($this->StringManipulator);
		unset($this->Dictionary);
		unset($this->Configuration);
		unset($this->DelegateCollection);
		unset($this->DatabaseTables);
		unset($this->DatabaseColumns);
		unset($this->PassThruVars);
	}   
}
?>