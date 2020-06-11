<?php
session_start();
include("connection.php");
$Customer_name=$_POST['Customer_name'];
//echo $Customer_name;
//echo"<br/>";
$Father_name=$_POST['Father_name'];
//echo $Father_name;
//echo"<br/>";
$Aadhar_card_no=$_POST['Aadhar_card_no'];
//echo $Aadhar_card_no;
//echo"<br/>";
$User_name=$_POST['User_name'];
//echo $User_name;
//echo"<br/>";
$Password=$_POST['Password'];
//echo $Password;
//echo"<br/>";
$Gender=$_POST['a'];
//echo $Gender;
//echo"<br/>";
$Email_id=$_POST['Email_id'];
//echo $Email_id;
//echo"<br/>";
$Mobile_no=$_POST['Mobile_no'];
//echo $Mobile_no;
//echo"<br/>";
$Address=$_POST['Address'];
//echo $Address;
//echo"<br/>";
$City=$_POST['City'];
//echo $City;
//echo"<br/>";
echo "your registration is done successfully.THANKS";

$query="insert into customer(Customer_name,Father_name,Aadhar_card_no,User_name,Password,Gender,Email_id,Mobile_no,Address,City)
values('$Customer_name','$Father_name','$Aadhar_card_no','$User_name','$Password','$Gender','$Email_id','$Mobile_no','$Address','$City')";
mysql_query($query);
?>