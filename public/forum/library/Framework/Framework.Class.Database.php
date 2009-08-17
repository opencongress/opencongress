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
* DESCRIPTION: A database interface.
*/
class Database {
   // Public
   var $DatabaseType;      // The type of database to connect to and use (currently only handles mysql)
   
   // Private
   var $Name;              // The name of this class
   var $Context;				// A reference to the context object
   var $Connection;        // A connection to the default database
   var $FarmConnection;		// A connection to a farm database (for inserting, updating, and deleting)
   
   
	function CloseConnection() {}
	
	function ConnectionError() {}
	
   function Database(&$Context) {
		$this->Name = 'Database';
		$Context->ErrorManager->AddError($Context, $this->Name, 'Constructor', 'You can not generate a database object with the database interface. You must use an implementation of the interface like the MySQL implementation.');
	}
   
   // Returns the affected rows if successful (kills page execution if there is an error)
   function Delete($SqlBuilder, $SenderObject, $SenderMethod, $ErrorMessage, $KillOnFail = '1') {}
	
	// Executes a string of sql
   function Execute($Sql, $SenderObject, $SenderMethod, $ErrorMessage, $KillOnFail = '1') {}
	
	function GetConnection() {}
	
	function GetFarmConnection() {}
	
	function GetRow($DataSet) {}
   
   // Returns the inserted ID (kills page execution if there is an error)
   function Insert($SqlBuilder, $SenderObject, $SenderMethod, $ErrorMessage, $KillOnFail = '1') {}
	
	function RewindDataSet(&$DataSet, $Position = '0') {}
	
	function RowCount($DataSet) {}
   
   // Returns a dataset (kills page execution if there is an error)
   function Select($SqlBuilder, $SenderObject, $SenderMethod, $ErrorMessage, $KillOnFail = '1') {}

   // Returns the affected rows if successful (kills page execution if there is an error)
   function Update($SqlBuilder, $SenderObject, $SenderMethod, $ErrorMessage, $KillOnFail = '1') {}
	
}
?>