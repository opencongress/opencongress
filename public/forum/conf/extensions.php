<?php
// Make sure this file was not accessed directly and prevent register_globals configuration array attack
if (!defined('IN_VANILLA')) exit();		
// Enabled Extensions
include($Configuration['EXTENSIONS_PATH']."Notify/default.php");
include($Configuration['EXTENSIONS_PATH']."ExtendedTextFormatter/default.php");
?>