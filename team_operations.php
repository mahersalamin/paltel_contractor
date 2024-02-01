<?php /** @noinspection ALL */

// Include the database connection file
include('db_connection.php');

// Function to add a new team
function addTeam() {
    global $conn;

    if (isset($_POST['name'], $_POST['type'])) {
        $name = mysqli_real_escape_string($conn, $_POST['name']);
        $type = mysqli_real_escape_string($conn, $_POST['type']);

        $sql = "INSERT INTO teams (name, type) VALUES ('$name', '$type')";

        if ($conn->query($sql) === TRUE) {
            echo json_encode(array('status' => 'success', 'message' => 'Team added successfully'));
        } else {
            echo json_encode(array('status' => 'error', 'message' => 'Error adding team: ' . $conn->error));
        }
    } else {
        echo json_encode(array('status' => 'error', 'message' => 'Incomplete parameters'));
    }
}

// Function to view all teams
function viewTeams() {
    global $conn;

    $sql = "SELECT * FROM teams";
    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        $teams = array();
        while ($row = $result->fetch_assoc()) {
            $teams[] = $row;
        }

        echo json_encode(array('status' => 'success', 'message' => 'Teams retrieved successfully', 'data' => $teams));
    } else {
        echo json_encode(array('status' => 'error', 'message' => 'No teams found'));
    }
}

// Function to edit a team
function editTeam() {
    global $conn;

    if (isset($_POST['id'], $_POST['name'], $_POST['type'])) {
        $id = (int)$_POST['id'];
        $name = mysqli_real_escape_string($conn, $_POST['name']);
        $type = mysqli_real_escape_string($conn, $_POST['type']);

        $sql = "UPDATE teams SET name = '$name', type = '$type' WHERE id = $id";

        if ($conn->query($sql) === TRUE) {
            echo json_encode(array('status' => 'success', 'message' => 'Team updated successfully'));
        } else {
            echo json_encode(array('status' => 'error', 'message' => 'Error updating team: ' . $conn->error));
        }
    } else {
        echo json_encode(array('status' => 'error', 'message' => 'Incomplete parameters'));
    }
}

// Determine the action based on the 'action' parameter
if (isset($_POST['action'])) {
    $action = $_POST['action'];

    switch ($action) {
        case 'add':
            addTeam();
            break;
        case 'view':
            viewTeams();
            break;
        case 'edit':
            editTeam();
            break;
        default:
            echo json_encode(array('status' => 'error', 'message' => 'Invalid action'));
            break;
    }
} else {
    echo json_encode(array('status' => 'error', 'message' => 'Action not specified'));
}

// Close the connection (optional if you want to close it explicitly)
$conn->close();
?>
