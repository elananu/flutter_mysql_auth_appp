<?php

$conn = new mysqli("localhost", "root", "", "flutter_auth");

if ($conn->connect_error) {

  die("Connection failed: " . $conn->connect_error);

}

?>
