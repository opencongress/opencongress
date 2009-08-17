<?php

class Uploader extends Delegation {
	var $OverwriteExistingFile;
	var $MaximumFileSize;
	var $AllowedFileTypes;
   var $WarningCollector;
	var $CurrentFileSize;
	
	function Uploader(&$Context) {
		$this->Name = "Uploader";
      $this->Delegation($Context);
      $this->Clear();
   }
   
   function Clear() {
		$this->MaximumFileSize = '1024000';
		$this->AllowedFileTypes = array (
			'image/gif' => array('gif'),
			'image/jpeg' => array('jpg'),
			'image/pjpeg' => array('jpg'),
			'application/zip' => array('zip'),
			'application/octet-stream' => array('rar'),
			'text/plain' => array('txt'),
			'application/x-gzip' => array('gz', 'tar.gz')
      );
		$this->CurrentFileSize = 0;
	}
	
   // Uploads a file from an input to the specified destination and returns the name to the file
	function Upload($InputName, $DestinationFolder, $DestinationName = '', $TimeStampName = '0', $OverwriteExistingFile = '0') {
      $Return = "";
		if (array_key_exists($InputName, $_FILES)) {
			$FileName = basename($_FILES[$InputName]['name']);
			$FilePieces = explode('.', $FileName);
			$FileExtension = $FilePieces[count($FilePieces)-1];
			if ($FileExtension == 'gz' && $FilePieces[count($FilePieces)-2] == 'tar') {
				$FileExtension = 'tar.gz';
			}
			if ($FileName != '') {
				// Define file properties
				if ($DestinationName == '') $DestinationName = $FileName;
				$TempFileName = $_FILES[$InputName]['tmp_name'];
				$FileType = $_FILES[$InputName]['type'];
				$this->CurrentFileSize = $_FILES[$InputName]['size'];
				
				// Ensure the file is not empty
				if($this->CurrentFileSize == 0) $this->Context->WarningCollector->Add('The file you attempted to upload ('.$FileName.') was empty.');
	
				// Ensure that the file's type is allowed
				if (!array_key_exists($FileType, $this->AllowedFileTypes)) {
					$this->Context->WarningCollector->Add('You are not allowed to upload ('.$FileName.') the requested file type: '.$FileType);
				} else {
					// Now make sure that the file type has the proper extension
					if (!in_array($FileExtension, $this->AllowedFileTypes[$FileType])) {
						$Message = '';
						for ($i = 0; $i < count($this->AllowedFileTypes[$FileType]); $i++) {
							if ($Message != '') $Message .= ', ';
							$Message .= $this->AllowedFileTypes[$FileType][$i];
						}
						$Message = 'The file you attempted to upload ('.$FileName.') was of type "'.$FileType.'", but the file extension "'.$FileExtension.'" did not match the accepted extensions for this type of file: '
							.$Message;
						$this->Context->WarningCollector->Add($Message);
					}
				}
				
				// Ensure that the file is not beyond the maximum allowable size
				if($this->CurrentFileSize > $this->MaximumFileSize) $this->Context->WarningCollector->Add('The file you have attempted to upload ('.$FileName.') is larger than the allowed size: '.FormatFileSize($this->MaximumFileSize));
				
				if ($this->Context->WarningCollector->Count() == 0) {
	
					// Redefine new file to include proper file extension
               $DestinationNameOnly = substr($DestinationName, 0, strpos($DestinationName, '.'.$FileExtension));
					if ($TimeStampName) {
						$DestinationNameOnly .= date('-Y-m-d', mktime());
						$DestinationName = $DestinationNameOnly.'.'.$FileExtension;
					}
					$Return = $DestinationName;
					$NewFilePath = ConcatenatePath($DestinationFolder, $Return);
					if (!$OverwriteExistingFile) {
						$Loop = 2;
						while (file_exists($NewFilePath)) {
							$Return = $DestinationNameOnly.$Loop.'.'.$FileExtension;
							$NewFilePath = ConcatenatePath($DestinationFolder, $Return);
							$Loop++;
						}
					}
					if (!move_uploaded_file(
							$_FILES[$InputName]['tmp_name'],
							$NewFilePath
						)
					) $this->Context->WarningCollector->Add('Failed to upload the file: '.$FileName);
				}
			} else {
				$this->Context->WarningCollector->Add('You must provide a file to be uploaded.');
			}
		} else {
			$this->Context->WarningCollector->Add('The file you attempted to upload could not be found in postback data.');
		}
      return $Return;
   }
}
?>