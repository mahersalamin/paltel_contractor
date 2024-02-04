<?php /** @noinspection ALL */

include('db_connection.php');

// Function to add a new material
function addTeamMaterialsAndUpdateStock()
{
    $materialData = stripslashes($_POST['material_data']);

// Decode the JSON string to an array
    $materialData = json_decode($materialData, true);


    global $conn;
    if (isset($_POST['team_id'], $_POST['date_taken'], $_POST['transaction_type'])) {

        // Execute queries in a transaction to ensure atomicity
        $conn->begin_transaction();

        try {
            foreach ($materialData as $material) {
                $team_id = $_POST['team_id'];
                $material_id = $material['material_id'];
                $quantity_taken = $material['quantity_taken'];
                $date_taken = $_POST['date_taken'];
                $transaction_type = $_POST['transaction_type'];


                $sql_team_materials = "INSERT INTO team_materials (team_id, material_id, quantity, date_taken, transaction_type, remaining_quantity) 
                                    VALUES ($team_id, $material_id, $quantity_taken, '$date_taken', '$transaction_type',$quantity_taken)";


                // Update stock
                $sql_stock = "UPDATE materials
                          SET quantity = quantity - $quantity_taken
                          WHERE id = $material_id";

                // Execute queries
                $conn->query($sql_team_materials);
                $conn->query($sql_stock);
            }

            // Commit the transaction
            $conn->commit();

            echo json_encode(array(
                'status' => 'success', 'message' => 'Registered successfully'
            ));
        } catch (Exception $e) {
            // Rollback the transaction in case of an error
            $conn->rollback();

            echo json_encode(array(
                'status' => 'error',
                'message' => "Error adding records or updating stock: " . $e->getMessage()
            ));

        }
    } else {
        echo json_encode(
            array(
                'status' => 'error',
                'message' => "Error in fields"
            )
        );
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
            echo json_encode(array(
                'status' => 'success',
                'message' => 'Material updated successfully'
            ));
        } else {
            echo json_encode(array(
                'status' => 'error',
                'message' => 'Error updating material: ' . $conn->error
            ));
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
        SELECT tm.id, tm.material_id, tm.date_taken, tm.quantity,
        tm. transaction_type, m.name AS material_name, m.quantity AS stock_quantity
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
            addTeamMaterialsAndUpdateStock();
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
