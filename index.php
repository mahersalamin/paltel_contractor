<?php
if (isset($_POST["value"])) {
    $servername = "localhost";
    $user = "root";
    $pw = "";
    $db = "atta";

    // Connect to the server
    $con = new mysqli($servername, $user, $pw, $db) or die(mysqli_errno());

    // Check connection
    if ($con->connect_error) {
        die("Connection failed: " . $con->connect_error);
    }

    $value = htmlspecialchars(stripslashes(trim($_POST["value"])));

    // Use query instead of prepare for a simple SELECT statement
    $sql = "SELECT * FROM materials";
    $result = $con->query($sql);

    // Check if the query was successful
    if ($result) {
        // Fetch the data
        while ($row = $result->fetch_assoc()) {
            // Do something with $row, which contains the data for each row
            print($row);
        }

    } else {
        echo "Failed: " . $con->error;
    }

    // Close the connection
    $con->close();
} else {
    echo "Not found";
}

?>
