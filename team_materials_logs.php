<?php /** @noinspection ALL */

include('db_connection.php');

// Function to add a new material
function addLog(){
    global $conn;

    if (isset($_POST['data'])) {
        $data = json_decode($_POST['data'], true);
        $teamId = $_POST['team_id'];

        foreach ($data as $log) {
            $teamMaterialId = $log['id'];
            $materialName = $log['material_name'];
            $usedQuantity = $log['used_quantity'];
            $dateTaken = $log['date_taken'];
            $dateUsed = $log['used_date'];

            // Check if used_quantity is greater than 0
            if ($usedQuantity > 0) {
                // Check if used_quantity is less than or equal to remaining_quantity
                $selectRemainingQuery = "SELECT remaining_quantity FROM team_materials 
                                         WHERE id = '$teamMaterialId' AND date_taken = '$dateTaken'";
                $result = mysqli_query($conn, $selectRemainingQuery);

                if ($result) {
                    $row = mysqli_fetch_assoc($result);
                    $remainingQuantity = $row['remaining_quantity'];

                    if ($usedQuantity <= $remainingQuantity) {
                        // Insert a record into material_usage_logs
                        $insertLogQuery = "INSERT INTO material_usage_logs (team_material_id, team_id, used_quantity, date_used, date_taken) 
                                           VALUES ('$teamMaterialId', $teamId, '$usedQuantity', '$dateUsed', '$dateTaken')";

                        $updateRemainingQuantityQuery = "UPDATE team_materials 
                                                         SET remaining_quantity = remaining_quantity - '$usedQuantity' 
                                                         WHERE id = '$teamMaterialId' AND date_taken = '$dateTaken'";

                        mysqli_query($conn, $insertLogQuery);
                        mysqli_query($conn, $updateRemainingQuantityQuery);
                    } else {
                        // Return an error message if used_quantity is greater than remaining_quantity
                        echo json_encode(array('status' => 'error', 'message' => 'الكمية المستخدمة أكبر من المستلمة: ' . $materialName));
                        continue; // Skip to the next element in the loop
                    }
                } else {
                    // Handle query error
                    echo json_encode(array('status' => 'error', 'message' => 'Error querying remaining quantity'));
                    return;
                }
            } else {
                // If used_quantity is 0, skip to the next element
                continue;
            }
        }

        echo json_encode(array('status' => 'success', 'message' => 'Log added successfully'));
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
    $id = $_POST['team_id'];

    $sql = "
        SELECT 
            m.id,
            m.name AS material_name,
            m.quantity AS stock_quantity,
            tm.quantity AS team_material_quantity,
            mul.used_quantity,
            tm.remaining_quantity,
            tm.date_taken,
            mul.date_used
            
        FROM team_materials tm
        INNER JOIN materials m ON tm.material_id = m.id
        LEFT JOIN material_usage_logs mul ON tm.id = mul.team_material_id
        WHERE tm.team_id = $id
    ";

    $result = $conn->query($sql);
//    var_dump($result);die();die
    if ($result->num_rows > 0) {
        $materials = array();
        while ($row = $result->fetch_assoc()) {
            $materialName = $row['material_name'];
            unset($row['material_name']); // Remove redundant material_name from the row
            $materials[$materialName][] = $row;
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
