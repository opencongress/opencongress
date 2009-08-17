<?php
/*
* Copyright 2003 Mark O'Sullivan
* This file is part of Vanilla.
* Vanilla is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
* Vanilla is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
* You should have received a copy of the GNU General Public License along with Vanilla; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
* The latest source code for Vanilla is available at www.lussumo.com
* Contact Mark O'Sullivan at mark [at] lussumo [dot] com
*
* Description: Assigns headers to all pages
*/
// PREVENT PAGE CACHING
header ('Expires: Mon, 26 Jul 1997 05:00:00 GMT'); // Date in the past
header ('Last-Modified: ' . gmdate('D, d M Y H:i:s') . ' GMT'); // always modified
header ('Cache-Control: no-cache, must-revalidate'); // HTTP/1.1
header ('Pragma: no-cache'); // HTTP/1.0

// PROPERLY ENCODE THE CONTENT
header ('content-type: text/html; charset='.$Configuration['CHARSET']);

// REPORT ALL ERRORS
error_reporting(E_ALL);

// DO NOT ALLOW PHP_SESS_ID TO BE PASSED IN THE QUERYSTRING
ini_set('session.use_only_cookies', 1);
// Track errors so explicit error messages can be reported should errors be encountered
@ini_set('track_errors', 1);
?>