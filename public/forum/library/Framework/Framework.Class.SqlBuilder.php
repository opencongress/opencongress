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
* DESCRIPTION: Class that builds a string of sql to be executed
* Applications utilizing this file: Vanilla;
*/
class SqlBuilder {
	var $Fields;		// String of select fields
	var $FieldValues;	// Array of field name/value pairs for inserting/updating
	var $MainTable;		// Associative array with information about the main table in the statement
	var $Joins;			// String of join clauses
	var $Wheres;		// Array of where claus parameters
	var $GroupBys;		// String of group by fields
	var $OrderBys;		// String of order by clauses
	var $Limit;			// Limit for a select
	var $Name;			// The name of this class
	var $TablePrefix;	// Prefix all tables with this string
   var $TableMap;		// An alias -> Key map of tables in the query
   var $Context;
	
	// $CaseArray should be in this format:
   // array("WhenValue" => "WhenVal", "ThenValue" => "ThenVal");
	function AddCaseSelect($CaseTableAlias, $CaseField, $CaseFieldAlias, $CaseArray, $ElseValue = 'null') {
		if ($this->Fields != '') $this->Fields .= ', ';
		$this->Fields .= 'case '.$CaseTableAlias.'.'.$this->Context->DatabaseColumns[$this->TableMap[$CaseTableAlias]][$CaseField];
		for ($i = 0; $i < count($CaseArray); $i++) {
			$this->Fields .= 'when '.$CaseArray[$i]['WhenValue'].' then '.$CaseArray[$i]['ThenValue'];
		}
		$this->Fields .= ' else '.$ElseValue.' end';
		$this->Fields .= ' as '.$CaseFieldAlias;
	}
	
	function AddFieldNameValue($FieldName, $FieldValue = '', $QuoteValue = 1, $Function = '') {
		if ($QuoteValue) $FieldValue = "'".$FieldValue."'";
		if ($Function != '') $FieldValue = $Function.'('.$FieldValue.')';
		$this->FieldValues[$FieldName] = $FieldValue;
	}
	
	function AddGroupBy($Field, $TableAlias) {
		if (is_array($Field)) {
			$FieldCount = count($Field);
			$i = 0;
			for ($i = 0; $i < $FieldCount; $i++) {
				$this->AddGroupBy($Field[$i],$TableAlias);
			}
		} else {
			if ($Field != '') {
				if ($TableAlias != '') $Field = $TableAlias.'.'.$this->Context->DatabaseColumns[$this->TableMap[$TableAlias]][$Field];
				if ($this->GroupBys != '') $this->GroupBys .= ', ';
				$this->GroupBys .= $Field;
			}
		}
	}
	
	// Adds a table to the join clause
	function AddJoin($NewTable, $NewTableAlias, $NewTableField, $ExistingAlias, $ExistingField, $JoinMethod, $AdditionalJoinMethods = '', $CustomTablePrefix = '') {
		$CustomTablePrefix = $CustomTablePrefix == '' ? $this->TablePrefix : $CustomTablePrefix;
		$this->TableMap[$NewTableAlias] = $NewTable;
		
		$this->Joins .= $JoinMethod.' '.GetTableName($NewTable, $this->Context->DatabaseTables, $CustomTablePrefix).' '.$NewTableAlias
			.' on '.$ExistingAlias.'.'.$this->Context->DatabaseColumns[$this->TableMap[$ExistingAlias]][$ExistingField].' = '.$NewTableAlias.'.'.$this->Context->DatabaseColumns[$NewTable][$NewTableField].' '.$AdditionalJoinMethods.' ';
	}
	
	function AddLimit($Index, $Length) {
		$this->Limit = ' limit '.$Index.', '.$Length;
	}
	
	function AddOrderBy($FieldName, $TableAlias, $SortDirection = 'asc', $Function = '', $InnerFunction = '', $InnerFunctionParams = '') {
		if ($this->OrderBys != '') $this->OrderBys .= ', ';
		if (is_array($FieldName)) {
			$i = 0;
			$NewOrderBys = '';
			$NewField = '';
			for ($i = 0; $i < count($FieldName); $i++) {
				if ($NewOrderBys != '') $NewOrderBys .= ', ';
				if ($TableAlias[$i] == '') {
					$NewField = $FieldName[$i];
				} else {
					$NewField = $TableAlias[$i].'.'.$this->Context->DatabaseColumns[$this->TableMap[$TableAlias[$i]]][$FieldName[$i]];
				}
				if ($InnerFunction != '') $NewField = $InnerFunction.'('.$NewField.$InnerFunctionParams.')';
				$NewOrderBys .= $NewField;
			}
			$this->OrderBys .= ' '.$Function.'('.$NewOrderBys.') '.$SortDirection;
			
		} else {
			$this->OrderBys .= ' '.$TableAlias.'.'.$this->Context->DatabaseColumns[$this->TableMap[$TableAlias]][$FieldName].' '.$SortDirection;
		}
	}
	
	// $Field == the field to select (or fields if you supply an array)
	// $TableAlias == the alias of the table to select the field from
	// $FieldAlias == the alternate name for a field (ie. select field as blah) - ignored if you supply an array for $Field
	function AddSelect($Field, $TableAlias, $FieldAlias = '', $Function = '', $FunctionParameters = '', $GroupByThisField = '0', $FieldAddendum = '') {
		if (is_array($Field)) {
			$FieldCount = count($Field);
			$i = 0;
			for ($i = 0; $i < $FieldCount; $i++) {
				$this->AddSelect($Field[$i], $TableAlias, '', '', '', $GroupByThisField);
			}
		} else {
			if ($Field != '') {
				// $GroupByThisField = ForceBool($GroupByThisField, 0);
				if ($GroupByThisField) {
					if ($this->GroupBys != '') $this->GroupBys .= ', ';
					$this->GroupBys .= ($TableAlias != '' ? $TableAlias.'.'.$this->Context->DatabaseColumns[$this->TableMap[$TableAlias]][$Field] : $Field);
					// $this->AddGroupBy($Field, $TableAlias);
				}
				$QualifiedField = $Field;
				if ($TableAlias != '') $QualifiedField = $TableAlias.'.'.$this->Context->DatabaseColumns[$this->TableMap[$TableAlias]][$Field];
				if ($Function != '' && $FunctionParameters == '') $QualifiedField = $Function.'('.$QualifiedField.')';
				if ($Function != '' && $FunctionParameters != '') $QualifiedField = $Function.'('.$QualifiedField.', '.$FunctionParameters.')';
				if ($this->Fields != '') $this->Fields .= ', ';
				$this->Fields .= $QualifiedField.$FieldAddendum.' ';
				if ($FieldAlias != '') {
					$this->Fields .= ' as '.$FieldAlias;
				} else {
					$this->Fields .= ' as '.$Field;
				}
			}
		}
	}
	
	// $Parameter1 == the first field in the comparison operation
	// $Parameter2 == the second field in the comparison operation
	// $Comparison operator == '=,>,<,in,<>,like' etc
	// $AppendMethod == the method by which this where should be attached to existing wheres
	function AddWhere($TableAlias1, $Parameter1, $TableAlias2, $Parameter2, $ComparisonOperator, $AppendMethod = 'and', $Function = '', $QuoteParameter2 = '1', $StartWhereGroup = '0') {
		if (!is_array($this->Wheres)) $this->Wheres = array();
		$this->Wheres[] = array('TableAlias1' => $TableAlias1,
			'Param1' => $Parameter1,
			'TableAlias2' => $TableAlias2,
			'Param2' => $Parameter2,
			'ComparisonOperator' => $ComparisonOperator,
			'AppendMethod' => $AppendMethod,
			'Function' => $Function,
			'QuoteParameter2' => $QuoteParameter2,
			'StartWhereGroup' => $StartWhereGroup);			
	}
	
	function Clear() {
		$this->Fields = '';
		$this->FieldValues = array();
		$this->MainTable = array();
		$this->Joins = '';
		$this->Wheres = array();
		$this->GroupBys = '';
		$this->OrderBys = '';
		$this->Limit = '';
		$this->Name = 'SqlBuilder';
		$this->TablePrefix = $this->Context->Configuration['DATABASE_TABLE_PREFIX'];
		$this->TableMap = array();
	}
	
	function EndWhereGroup() {
		$this->Wheres[] = ') ';
	}
	
	// Returns a delete statement
	function GetDelete() {
		$sReturn = "delete ";
		$sReturn .= "from ".$this->MainTable["TableName"]." ";
		$sReturn .= $this->GetWheres(1);
		$this->WriteDebug($sReturn);
		return $sReturn;
	}

	// Returns an insert statement
	function GetInsert($UseIgnore = "0") {
		$sReturn = "insert ";
		if ($UseIgnore == "1") $sReturn .= "ignore ";
		$sReturn .= "into ";
		$sReturn .= $this->MainTable["TableName"]." ";
		$Fields = "";
		$Values = "";
		while (list($name, $value) = each($this->FieldValues)) {
			if ($Fields != "") {
				$Fields .= ", ";
				$Values .= ", ";
			}
			$Fields .= $this->Context->DatabaseColumns[$this->TableMap[$this->MainTable['TableAlias']]][$name];
			$Values .= $value;
		}
		reset($this->FieldValues);
		$sReturn .= "($Fields) ";
		$sReturn .= "values ($Values)";
		$this->WriteDebug($sReturn);
		return $sReturn;
	}
	
	// Returns a select statement
	function GetSelect($SelectPrefix = "") {
		$sReturn = $SelectPrefix." select ";
		$sReturn .= $this->Fields." ";
		
		// Build the from statement
		$sReturn .= "from ".$this->MainTable["TableName"]." ";
		$TableAlias = ForceString($this->MainTable["TableAlias"], "");
		if ($TableAlias != "") $sReturn .= $TableAlias." ";
		
		$sReturn .= $this->Joins." ";
		$sReturn .= $this->GetWheres();
		if ($this->GroupBys != "") $sReturn .= " group by ".$this->GroupBys;
		if ($this->OrderBys != "") $sReturn .= " order by ".$this->OrderBys;
		$sReturn .= $this->Limit;
		$this->WriteDebug($sReturn);
		return $sReturn;
	}

	// returns an update statement
	function GetUpdate() {
      $sReturn = 'update '.$this->MainTable['TableName'].' set ';
		$Delimiter = '';
		while (list($name, $value) = each($this->FieldValues)) {
			$sReturn .= $Delimiter.$this->Context->DatabaseColumns[$this->TableMap[$this->MainTable['TableAlias']]][$name].'='.$value;
			$Delimiter = ', ';
		}
		reset($this->FieldValues);
		$sReturn .= $this->GetWheres(1);
		$this->WriteDebug($sReturn);
		return $sReturn;
	}
	
	function GetWheres($ForUpdating = 0) {
		$sWheres = '';
		$WhereCount = count($this->Wheres);
		if ($WhereCount > 0) {
			for ($i = 0; $i < $WhereCount; $i++) {
				if (is_array($this->Wheres[$i])) {
					$TableAlias1 = $this->Wheres[$i]['TableAlias1'];
					$Param1 = $this->Wheres[$i]['Param1'];
					$TableAlias2 = $this->Wheres[$i]['TableAlias2'];
					$Param2 = $this->Wheres[$i]['Param2'];
					$ComparisonOperator = $this->Wheres[$i]['ComparisonOperator'];
					$AppendMethod = $this->Wheres[$i]['AppendMethod'];
					$Function = $this->Wheres[$i]['Function'];
					$QuoteParameter2 = $this->Wheres[$i]['QuoteParameter2'];
					$StartWhereGroup = $this->Wheres[$i]['StartWhereGroup'];
					
					if ($ForUpdating) {
						if ($TableAlias1 != '') $Param1 = $this->Context->DatabaseColumns[$this->TableMap[$TableAlias1]][$Param1];
						if ($TableAlias2 != '') $Param2 = $this->Context->DatabaseColumns[$this->TableMap[$TableAlias2]][$Param2];
					} else {
						if ($TableAlias1 != '') $Param1 = $TableAlias1.'.'.$this->Context->DatabaseColumns[$this->TableMap[$TableAlias1]][$Param1];
						if ($TableAlias2 != '') $Param2 = $TableAlias2.'.'.$this->Context->DatabaseColumns[$this->TableMap[$TableAlias2]][$Param2];
					}
					
					$StartWhereGroup = ForceBool($StartWhereGroup, 0);
			
					// Add the append method if there is an existing clause
					if (!empty($sWheres) && substr($sWheres,strlen($sWheres)-1) != '(') {
						$sWheres .= $AppendMethod.' ';
					}
					if ($StartWhereGroup) $sWheres .= '(';
					if ($QuoteParameter2 == '1') $Param2 = "'".$Param2."'";
					if ($Function != '') $Param2 = $Function.'('.$Param2.')';
					
					// Do the comparison operation
					$sWheres .= $Param1.' '.$ComparisonOperator.' '.$Param2.' ';
				} else {
					$sWheres .= $this->Wheres[$i];
				}
			}
			$sWheres = ' where '.$sWheres.' ';
		}
		// 2006-06-21 (mosullivan) I don't know why I cleared out this array, but it caused a bug
      // where I'd be using GetSelect during a test run and I'd want to echo the query before it
      // was executed. It would wipe out the where array so that when the actual query
      // was created and executed, there wouldn't be a where clause and it would return bogus data.
      
		// Clear out the array
		// $this->Wheres = array();
		// Return the where clause
		return $sWheres;
	}
	
	// Takes the current where clause and wraps it in parentheses
	function GroupWheres() {
		// Insert a paren in the first element of the wheres array and add one to the end as well
      array_unshift($this->Wheres, '(');
		$this->Wheres[] = ') ';
	}
	
	// If the user specifies two selectfrom's, this will effectively overwrite any previous items with the current one
	function SetMainTable($TableName, $TableAlias = '', $CustomTablePrefix = '') {
		$CustomTablePrefix = $CustomTablePrefix == '' ? $this->TablePrefix : $CustomTablePrefix;
		$MapKey = $TableAlias == "" ? $TableName : $TableAlias;
		$this->TableMap[$MapKey] = $TableName;
		$this->MainTable = array("TableName" => GetTableName($TableName, $this->Context->DatabaseTables, $CustomTablePrefix), "TableAlias" => $TableAlias);
	}

	function StartWhereGroup() {
		$this->Wheres[] = ' (';
	}
	
	function SqlBuilder(&$Context) {
		$this->Context = &$Context;
		$this->Clear();
	}
	
	function WriteDebug($String) {
		if ($this->Context->Session->User) {
			if ($this->Context->Session->User->Permission("PERMISSION_ALLOW_DEBUG_INFO") && $this->Context->Mode == MODE_DEBUG) $this->Context->SqlCollector->Add($String);
		}
	}
}
?>