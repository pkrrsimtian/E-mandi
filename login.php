<?php
error_reporting(0);
$msg=$_REQUEST['msg'];
//echo $msg;
if($msg==1)
{
 echo "yeah!!!!!invalid username or password!!!!";
}
if($msg==2)
{
 echo "logout sucessfully!!!!";
}
if($msg==3)
{
 echo "first login!!!!";
}
?>
<html>
<head>
<style>
#outer
{
	height:570px;
	width:1220px;
}
#profile
{
	height:400px;
	width:450px;
	margin:auto;
}
.menu
{
	height:400px;
	width:450px;
	float:left;
	margin-top:150px;
}
</style>
</head>
<body>
<form action="logincode.php" method="POST">
<center><div id="profile"><div id="menu">
<h1>LOGIN PAGE!!</H1>
who you are?
<select name="sel">
<option>Farmer</option>
<option>Customer</option>
</select><BR><BR>
User_name<input type="text" name="User_name"><BR><BR>
Password<input type="password" name="Password"><BR><BR>
<INPUT TYPE="SUBMIT">
</div></div></center>
</body>
</html>