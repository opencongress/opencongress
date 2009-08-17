<?php
include('../../appg/settings.php');
include('../../conf/settings.php');
include('../../appg/init_vanilla.php');
$PostBackAction = ForceIncomingString('PostBackAction','');
$Type = ForceIncomingString('Type', '');
$ElementID = ForceIncomingInt('ElementID', 0);
$Value = ForceIncomingInt('Value',0);
if ($PostBackAction == 'ChangeNotify')
{
    if ($Type != 'OWN')
        ChangeNotify(&$Context,$Type,$ElementID,$Value);
    else
        SwitchOwnNotify(&$Context,$Value,$Context->Session->UserID);
    echo 'Complete';
}
$Context->Unload();
?>