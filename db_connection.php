<?php
// db_connection.php

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "atta";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Optionally, you can set character set if needed
$conn->set_charset("utf8mb4");
?>
