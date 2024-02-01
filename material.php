<?php /** @noinspection ALL */

include('db_connection.php');

// Function to add a new material
function addMaterial() {
    global $conn;

    if (isset($_POST['name'], $_POST['name_en'], $_POST['p_id'], $_POST['quantity'], $_POST['type'])) {
        $name = mysqli_real_escape_string($conn, $_POST['name']);
        $name_en = mysqli_real_escape_string($conn, $_POST['name_en']);
        $p_id = $_POST['p_id'];
        $quantity = (int)$_POST['quantity'];
        $type = mysqli_real_escape_string($conn, $_POST['type']);

        $sql = "INSERT INTO materials (name, name_en, p_id, quantity, type) VALUES ('$name', '$name_en', '$p_id', $quantity, '$type')";
        
        if ($conn->query($sql) === TRUE) {
            echo json_encode(array('status' => 'success', 'message' => 'Material added successfully'));
        } else {
            echo json_encode(array('status' => 'error', 'message' => 'Error adding material: ' . $conn->error));
        }
    } else {
        echo json_encode(array('status' => 'error', 'message' => 'Incomplete parameters'));
    }
}

// Function to update a material
function updateMaterial() {
    global $conn;

    if (
            isset($_POST['id'], $_POST['quantity'], 
            $_POST['name'], $_POST['name_en'], 
            $_POST['p_id'], $_POST['type'])
        ) {
        $id = (int)$_POST['id'];
        $name = $_POST['name'];
        $quantity = $_POST['quantity'];
        $name_en = $_POST['name_en'];
        $p_id = $_POST['p_id'];
        $type = $_POST['type'];

        $sql = "UPDATE materials SET 
                name ='$name',
                quantity = $quantity, 
                name_en = '$name_en',
                p_id = '$p_id',
                type= '$type'
              WHERE id = $id";

        if ($conn->query($sql) === TRUE) {
            echo json_encode(array('status' => 'success', 'message' => 'Material updated successfully'));
        } else {
            echo json_encode(array('status' => 'error', 'message' => 'Error updating material: ' . $conn->error));
        }
    } else {
        echo json_encode(array('status' => 'error', 'message' => 'Incomplete parameters'));
    }
}

// Function to view all materials
function viewMaterials() {
    global $conn;

    $sql = "SELECT * FROM materials";
    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        $materials = array();
        while ($row = $result->fetch_assoc()) {
            $materials[] = $row;
        }

        echo json_encode(array('status' => 'success', 'message' => 'Materials retrieved successfully', 'data' => $materials));
    } else {
        echo json_encode(array('status' => 'error', 'message' => 'No materials found'));
    }
}



// Determine the action based on the 'action' parameter
if (isset($_POST['action'])) {
    $action = $_POST['action'];

    switch ($action) {
        case 'add':
            addMaterial();
            break;
        case 'update':
            updateMaterial();
            break;
        case 'view':
            viewMaterials();
            break;
        default:
            echo json_encode(array('status' => 'error', 'message' => 'Invalid action'));
            break;
    }
} else {
    echo "Action not specified";
}

// Close the connection (optional if you want to close it explicitly)
$conn->close();
?>
