<?php /** @noinspection ALL */

include('db_connection.php');

// Function to add a new material
function addLog()
{

    global $conn;
    if (isset($_POST['team_material_id'], $_POST['used_quantity'], $_POST['used_date'])) {

        $teamMaterialId = $_POST['team_material_id'];
        $usedQuantity = $_POST['used_quantity'];
// Insert a record into material_usage_logs
        $dateUsed = date("dd-mm-yyyy");
        $insertLogQuery = "INSERT INTO material_usage_logs (team_material_id, used_quantity, date_used) 
                  VALUES ('$teamMaterialId', '$usedQuantity', '$dateUsed')";

        // Update the remaining quantity in team_materials
        $updateRemainingQuantityQuery = "UPDATE team_materials 
                                 SET remaining_quantity = remaining_quantity - '$usedQuantity' 
                                 WHERE id = '$teamMaterialId'";
        mysqli_query($conn, $updateRemainingQuantityQuery);


        if ($conn->query($insertLogQuery) === TRUE && $conn->query($updateRemainingQuantityQuery) === TRUE) {
            echo json_encode(array('status' => 'success', 'message' => 'Log added successfully'));
        } else {
            echo json_encode(array('status' => 'error', 'message' => 'Error adding Log: ' . $conn->error));
        }
    } else {
        echo json_encode(array('status' => 'error', 'message' => 'Incomplete parameters'));
    }

}

// Function to update a material
function updateMaterial()
{
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
function viewMaterials()
{
    global $conn;
    $id=$_POST['team_id'];
    $sql = "SELECT tm.material_id, tm.date_taken, tm.quantity, tm. transaction_type, m.name AS material_name, m.quantity AS stock_quantity
        FROM team_materials tm
        INNER JOIN materials m ON tm.material_id = m.id
        WHERE tm.team_id = $id";
    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        $materials = array();
        while ($row = $result->fetch_assoc()) {
            $materials[] = $row;
        }

        echo json_encode(array('status' => 'success', 'message' => 'Team Materials retrieved successfully', 'data' => $materials));
    } else {
        echo json_encode(array('status' => 'error', 'message' => 'No materials found'));
    }
}


// Determine the action based on the 'action' parameter
if (isset($_POST['action'])) {
    $action = $_POST['action'];

    switch ($action) {
        case 'add':
            addLog();
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
