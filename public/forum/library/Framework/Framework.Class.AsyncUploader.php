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
* Description: Class that renders and handles asynchronous uploads.
*/
class AsyncUploader extends PostBackControl {
   
   var $Name = '';
   var $ContainerID = '';
   var $Context = false;
   var $PostBackAction = '';
   var $UploadDirectory = '';
   var $CurrentFileSize = '';
	
	function AsyncUploader(&$Context) {
      $this->Name = 'AsyncUploader';
      $this->Constructor($Context);
		$this->Clear();
	}
   
   function Clear() {
      $this->ContainerID = '';
      $this->PostBackAction = '';
      $this->UploadDirectory = '';
      $this->CurrentFileSize = '';
   }
	
	function DefineUploader($PostBackAction, $ContainerID, $UploadDirectory) {
      $this->ContainerID = $ContainerID;
      $this->PostBackAction = $PostBackAction;
      $this->UploadDirectory = $UploadDirectory;
   }
   
   // Returns the uploaded filename or false if it wasn't uploaded or there were errors.
   // This method should be called immediately after the class is instantiated
   function GetUploadedFileName($MaximumFileSize, $AcceptableFileTypes, $DestinationFileName = '', $TimeStampName = '0', $OverwriteExistingFile = '0') {
      $sReturn = 0;
      // Now check to see if the page has been posted back the the appropriate postbackaction
      if (ForceIncomingString('PostBackAction', '') == $this->PostBackAction) {
         $Uploader = $this->Context->ObjectFactory->NewContextObject($this->Context, "Uploader");
     		$Uploader->MaximumFileSize = $MaximumFileSize;
         $Uploader->AllowedFileTypes = $AcceptableFileTypes;
         $sReturn = $Uploader->Upload('UploaderFile'.$this->ContainerID,
            $this->UploadDirectory,
            $DestinationFileName,
            $TimeStampName,
            $OverwriteExistingFile);
         $this->CurrentFileSize = $Uploader->CurrentFileSize;
      }
      return $sReturn;      
	}
   
   function EncodeErrorMessage($Message) {
      $sReturn = str_replace("\r", "", $Message);
      $sReturn = str_replace("\n", "", $sReturn);
      $sReturn = str_replace("'", "\'", $sReturn);
      return $sReturn;
   }
   
   // This method should be called after the GetUploadedFileName has returned the resultant
   // filename and the parent object has performed any necessary action on the filename.
   // This method will kill the processing of the page (if necessary).
   function CompleteUpload($Message = '', $ResultPage = '') {
      if (ForceIncomingString('PostBackAction', '') == $this->PostBackAction) {
         if ($this->Context->WarningCollector->Count() > 0) {
            // Change the contents of the container element to the specified message
            echo "<html>
               <head>
                  <script type=\"text/javascript\">
                     var Parent = window.parent.document;
                     if (Parent) {
                        var Container = Parent.getElementById('".$this->ContainerID."_Errors');
                        if (Container) {
                           Container.innerHTML = '".$this->EncodeErrorMessage($this->Context->WarningCollector->GetMessages())."';
                        }
                     }
                  </script>
               </head>
            </html>";            
         } elseif ($ResultPage == '') {
            // Change the contents of the container element to the specified message
            echo "<html>
               <head>
                  <script type=\"text/javascript\">
                     var Parent = window.parent.document;
                     if (Parent) {
                        var Container = Parent.getElementById('".$this->ContainerID."');
                        var ResultContainer = Parent.getElementById('".$this->ContainerID."_Result');
                        if (Container && ResultContainer) {
                           Container.style.display = 'none';
                           ResultContainer.innerHTML = '".$Message."';
                           ResultContainer.style.display = 'block';
                        }
                     }
                  </script>
               </head>
            </html>";
         } else {
            // Refresh the parent document
            echo "<html>
               <head>
                  <script type=\"text/javascript\">
                     var Parent = window.parent.document;
                     if (Parent) {
                        Parent.location = '".$ResultPage."';
                     }
                  </script>
               </head>
            </html>";
         }
         
         $this->Context->Unload();
         die();
      }
   }
	
	function Get() {
      if (is_dir($this->UploadDirectory)) {
         $this->PostBackParams->Set('PostBackAction', $this->PostBackAction);
         return '<div id="'.$this->ContainerID.'">'
            .$this->Get_PostBackForm('frmAsyncUpload'.$this->ContainerID, 'post', '', 'multipart/form-data', 'AsyncIframe'.$this->ContainerID)
            .'<div id="'.$this->ContainerID.'_Errors"></div>
            <input name="UploaderFile'.$this->ContainerID.'" id="UploaderFile'.$this->ContainerID.'" type="file" class="FileUploadInput" />
            <input name="btnSubmit" type="submit" value="Upload" class="Button" />
            <iframe name="AsyncIframe'.$this->ContainerID.'" id="AsyncIframe'.$this->ContainerID.'" src="javascript:false;" style="height: 1px; width: 1px; display: none;"></iframe>
            </form>
         </div>
         <div id="'.$this->ContainerID.'_Result" style="display: none;"></div>';
      } else {
         $this->Context->WarningCollector->Write('The uploader will not work because the specified upload directory does not appear to exist: '.$this->UploadDirectory);
         return '<div id="'.$this->ContainerID.'">'
            .$this->Context->WarningCollector->GetMessages()
         .'</div>';
      }
	}
	
	function Render() {
		echo $this->Get();
	}	
}
?>