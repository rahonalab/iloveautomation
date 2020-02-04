<?php
/*
 * MySQL Connection Tester
 *  October 8, 2016
 *    Will Bontrager Software LLC
 *       This software is provided "AS IS," without any warranty of any kind, without 
 *          even any implied warranty such as merchantability or fitness for a particular 
 *             purpose. Will Bontrager Software LLC grants you a royalty free license to use 
 *                this software provided this notice appears on all copies. 
 *                */
$Message = '';
if( count($_POST) )
{
	   $MySQL = new mysqli( $_POST['Hname'], $_POST['Uname'], $_POST['pw'], $_POST['Dname'] );
	      if( $MySQL->connect_error ) { $Message .= 'Connection test result: Failed<br>'.$MySQL->connect_error; }
	      else { $Message .= 'Connection test result: PASSED'; }
}
?><!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html;charset=UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Test MySQL Connection</title>
<style type="text/css">
html, body { font-size:100%; font-family: sans-serif; }
p, input { box-sizing:border-box; }
input { font-size:1em; width:100%; max-width:200px; box-sizing:border-box; }
input[type="text"] { border:1px solid #ccc; padding:.25em .5em .25em .5em; border-radius:.25em; }
</style>
</head>
<body>
<div style="display:table; margin:.5in auto; text-align:center;">
<a href="http://www.willmaster.com/">
<img src="http://www.willmaster.com/images/wmlogo_icon.gif" style="border:none; outline:none; width:50px; height:50px;" alt="willmaster.com logo">
</a>

<span style="font-size:2em; position:relative; vertical-align:.5em;">Willmaster.com</span>
<h3>MySQL Connection Tester</h3>

<?php if($Message): ?>
<div style="display:table; margin:1em auto; border:1px solid blue; border-radius:.25em; padding:.5em; text-align:left;">
<?php echo($Message) ?>
</div>
<?php endif; ?>

<div style="display:table; border:2px solid #ccc; padding:1em; border-radius:.5em; text-align:left; margin:0 auto;">
	<form style="display:inline; margin:0;" method="post" action="<?php echo($_SERVER['PHP_SELF']) ?>">
<p style="margin:0;">
Host name.
</p>
<input name="Hname" type="text" value="<?php echo(@$_POST['Hname']) ?>">
<p style="margin-bottom:0; margin-top:.5em;">
Database name.
</p>
<input name="Dname" type="text" value="<?php echo(@$_POST['Dname']) ?>">
<p style="margin-bottom:0; margin-top:.5em;">
Username.
</p>
<input name="Uname" type="text" value="<?php echo(@$_POST['Uname']) ?>">
<p style="margin-bottom:0; margin-top:.5em;">
Password.
</p>
<input name="pw" type="text" value="<?php echo(@$_POST['pw']) ?>">
<p style="margin-bottom:0; margin-top:.5em;">
<input name="name" type="submit" value="Test Connection">
</p>
</form>
</div>

<p style="font-size:.9em;">
Copyright 2016 <a href="http://www.willmaster.com/">Will Bontrager Software LLC</a>
</p>
</div>
</body>
</html>
