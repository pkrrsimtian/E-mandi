<?php
session_start();
include("connection.php");
$sel=$_POST['sel'];
//echo $sel;
//echo"<br/>";
$User_name=$_POST['User_name'];
//echo $User_name;
//echo"<br/>";
$Password=$_POST['Password'];
//echo $Password;
include("connection.php");
	if($sel==Farmer)
	{
		 $query="select * from farmer where User_name='$User_name' and Password='$Password'";
		 $res=mysql_query($query);
		 if($row=mysql_fetch_assoc($res))
		 {
			$_SESSION['farmer']=$User_name;
			header("Location:farprof.php");
		 }
		 else
		 {
			 header("Location:login.php?msg=1");
		 }
	}
	else if($sel==Customer)
	{
		 $query="select * from customer where User_name='$User_name' and Password='$Password'";
		 $res=mysql_query($query);
		 if($row=mysql_fetch_assoc($res))
		 {
			 $_SESSION['customer']=$User_name;
			header("Location:custprof.php");
		 }
		 else
		 {
			 header("Location:login.php?msg=1");
		 }
	}
?>