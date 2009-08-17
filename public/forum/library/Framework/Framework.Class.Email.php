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
* Description:  Handle creating and sending emails
* Applications utilizing this file: Vanilla;
*/
class Email {
	var $Recipients;		// Array of recipients
	var $CCRecipients;	// Array of cc'd recipients
	var $BCCRecipients;	// Array of bcc'd recipients
	var $FromName;			// String
	var $FromEmail;		// String
	var $Subject;			// Subject line of the email
	var $Body;
	var $FatalError;		// Throw a fatal error if the mail fails to send? (default true)
	// Standard properties
	var $Name;				// The name of this class
	var $Context;

	function AddBCCRecipient($Email, $Name = "") {
		$this->AddTo("BCCRecipients", $Email, $Name);
	}
	
	function AddCCRecipient($Email, $Name = "") {
		$this->AddTo("CCRecipients", $Email, $Name);
	}
	
	function AddFrom($Email, $Name = "") {
		$this->FromEmail = $Email;
		$this->FromName = $Name;
	}
	
	function AddRecipient($Email, $Name = "") {
		$this->AddTo("Recipients", $Email, $Name);
	}
	
	function AddTo($ToType, $Email, $Name = "") {
		$Found = 0;
		if ($this->$ToType) {
			foreach($this->$ToType as $key => $value) {
				if ($value["Email"] == $Email) $Found = 1;
			}
		}
		if (!$Found) {
			if ($ToType == "Recipients") {
				if (count($this->Recipients) >= 1) {
					$this->CCRecipients[] = array("Email" => $Email, "Name" => $Name);
				} else {
					$this->Recipients[] = array("Email" => $Email, "Name" => $Name);
				}
			} elseif ($ToType == "CCRecipients") {
				$this->CCRecipients[] = array("Email" => $Email, "Name" => $Name);
			} elseif ($ToType == "BCCRecipients") {
				$this->BCCRecipients[] = array("Email" => $Email, "Name" => $Name);
			}
		}
	}
	
	function AddToHeader($ToType) {
		$Header = "";
		$ToTypeCount = count($this->$ToType);
		for ($i = 0; $i < $ToTypeCount; $i++) {
			if ($i > 0) $Header .= ", ";
			if ($ToType == "CCRecipients") {
				$Header .= $this->CCRecipients[$i]["Name"]." <".$this->CCRecipients[$i]["Email"].">"; 
			} elseif ($ToType == "BCCRecipients") {
				$Header .= $this->BCCRecipients[$i]["Name"]." <".$this->BCCRecipients[$i]["Email"].">"; 
			}			
		}
		if ($Header != "") $Header .= "\r\n";
		return $Header;
	}
	
	function Clear() {
		$this->Name = "Email";
		$this->Recipients = array();
		$this->CCRecipients = array();
		$this->BCCRecipients = array();
		$this->FromName = "";
		$this->FromEmail = "";
		$this->Subject = "";
		$this->Body = "";
		$this->FatalError = 1;
	}
	
	function ClearRecipients() {
		$this->Recipients = array();
		$this->CCRecipients = array();
		$this->BCCRecipients = array();
	}
	
	function Email(&$Context) {
		$this->Clear();
		$this->Context = &$Context;
	}
	
	// I took snippets of this function from Rickard Andersson's GNU GPL'd PunBB
   // (rickard@punbb.org). He deserves all of the credit for writing it.
	function Send($FatalError = 1) {
		$this->FatalError = $FatalError;
		
		// Check that requied properties are supplied
		if ($this->ValidateEmail()) {
			$To = $this->Recipients[0]["Email"];
			
			// Make the linebreaks consistent
				$Message = str_replace("\r\n", "\n", $this->Body);
				$Message = str_replace("\r", "\n", $Message);
				$Message = str_replace("\n", "\r\n", $Message);

			// Build the headers
				$Header = "";
				$Header .= "From: ".$this->FromName." <".$this->FromEmail.">\r\n"; 
				if (count($this->CCRecipients) > 0) $Header .= "Cc: ".$this->AddToHeader("CCRecipients");
				if (count($this->BCCRecipients) > 0) $Header .= "Bcc: ".$this->AddToHeader("BCCRecipients");
				$Header .= "Reply-To: ".$this->FromName." <".$this->FromEmail.">\r\n";
				$Header .= 'Date: '.date('r')
					."\r\n"
					.'MIME-Version: 1.0'
					."\r\n"
					.'Content-transfer-encoding: 8bit'
					."\r\n"
					.'Content-type: text/plain; charset='
					.$this->Context->Configuration['CHARSET']
					."\r\n"
					.'X-Mailer: Lussumo Mailer';
						
			if ($this->Context->Configuration['SMTP_HOST'] != '') {
				$this->SMTPSend($To, $this->Subject, $Message, $Header);
			} else {
				// Change the linebreaks used in the headers according to OS
				if (strtoupper(substr(PHP_OS, 0, 3)) == 'MAC') {
					$Header = str_replace("\r\n", "\r", $Header);
				} else if (strtoupper(substr(PHP_OS, 0, 3)) != 'WIN') {
					$Header = str_replace("\r\n", "\n", $Header);
				}
					
				// And send the message
				if (!@mail($To, $this->Subject, $Message, $Header) && $this->FatalError) $this->Context->ErrorManager->AddError($this->Context, $this->Name, "Send", "An error occurred while sending the email.", $php_errormsg);
			}
		}
	}

	/*
	I found the following two SMTP functions in the GNU GPL'd PunBB by Rickard
   Andersson (rickard@punbb.org). Rickard's notes indicated that the code was
   originally a part of the phpBB Group forum software phpBB2
   (http://www.phpbb.com). They deserve all the credit for writing it. Like
   Rickard, I made small modifications for it to suit my needs for the Lussumo
   Framework and it's coding standards.
	*/
	function ServerParse($Socket, $ExpectedResponse) {
		$ServerResponse = '';
		while (substr($ServerResponse, 3, 1) != ' ') {
			if (!($ServerResponse = fgets($Socket, 256))) {
				$this->Context->ErrorManager->AddError($this->Context, $this->Name, "ServerParse", "An error occurred while sending the email.", "Couldn't get mail server response codes.");
			}
		}
	
		if (!(substr($ServerResponse, 0, 3) == $ExpectedResponse)) {
			$this->Context->ErrorManager->AddError($this->Context, $this->Name, "ServerParse", "Unable to send email. The SMTP server reported the following error:", $ServerResponse);
		}
	}
	
	function SMTPSend($To, $Subject, $Message, $Headers = '') {
		// Are we using port 25 or a custom port?
		if (strpos($this->Context->Configuration['SMTP_HOST'], ':') !== false) {
			list($SMTPHost, $SMTPPort) = explode(':', $this->Context->Configuration['SMTP_HOST']);
		} else {
			$SMTPHost = $this->Context->Configuration['SMTP_HOST'];
			$SMTPPort = 25;
		}
		
		$ErrorNumber = "";
		$ErrorString = "";
	
		if (!($Socket = fsockopen($SMTPHost, $SMTPPort, $ErrorNumber, $ErrorString, 15))) {
			if ($this->FatalError) {
				$this->Context->ErrorManager->AddError($this->Context, $this->Name, "SMTPSend", "Could not connect to SMTP host ".$SMTPHost.":".$SMTPPort, $ErrorNumber.": ".$ErrorString);
			} else {
				return false;
			}
		}
	
		$this->ServerParse($Socket, '220');
	
		if ($this->Context->Configuration['SMTP_USER'] != '' && $this->Context->Configuration['SMTP_PASSWORD'] != '') {
			fwrite($Socket, 'EHLO '.$SMTPHost."\r\n");
			$this->ServerParse($Socket, '250');
	
			fwrite($Socket, 'AUTH LOGIN'."\r\n");
			$this->ServerParse($Socket, '334');
	
			fwrite($Socket, base64_encode($this->Context->Configuration['SMTP_USER'])."\r\n");
			$this->ServerParse($Socket, '334');
	
			fwrite($Socket, base64_encode($this->Context->Configuration['SMTP_PASSWORD'])."\r\n");
			$this->ServerParse($Socket, '235');
		} else {
			fwrite($Socket, 'HELO '.$SMTPHost."\r\n");
			$this->ServerParse($Socket, '250');
		}
	
		fwrite($Socket, 'MAIL FROM: <'.$this->Context->Configuration['SUPPORT_EMAIL'].'>'."\r\n");
		$this->ServerParse($Socket, '250');
	
		$ToHeader = 'To: ';
		fwrite($Socket, 'RCPT TO: <'.$To.'>'."\r\n");
		$this->ServerParse($Socket, '250');
		$ToHeader .= '<'.$To.'>, ';
	
		fwrite($Socket, 'DATA'."\r\n");
		$this->ServerParse($Socket, '354');
	
		fwrite($Socket,
			'Subject: '
				.$Subject
				."\r\n"
				.$ToHeader
				."\r\n"
				.$Headers
				."\r\n\r\n"
				.$Message
				."\r\n"
		);
	
		fwrite($Socket, '.'."\r\n");
		$this->ServerParse($Socket, '250');
	
		fwrite($Socket, 'QUIT'."\r\n");
		fclose($Socket);
	
		return true;
	}

	function ValidateEmail() {
		$this->Subject = str_replace(array("\r","\n"),"",$this->Subject);
		if ($this->Subject == "") $this->Context->WarningCollector->Add($this->Context->GetDefinition("ErrEmailSubject"));
		if (count($this->Recipients) == 0) $this->Context->WarningCollector->Add($this->Context->GetDefinition("ErrEmailRecipient"));
		if ($this->FromEmail == "") $this->Context->WarningCollector->Add($this->Context->GetDefinition("ErrEmailFrom"));
		if ($this->Body == "") $this->Context->WarningCollector->Add($this->Context->GetDefinition("ErrEmailBody"));
		return $this->Context->WarningCollector->Iif();
	}
}
?>