<?php
error_reporting(0);
ini_set('display_errors', 0);

// ✅ CORS headers
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header('Content-Type: application/json');

// Handle OPTIONS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { http_response_code(200); exit; }

// Get JSON data
$data = json_decode(file_get_contents('php://input'));
$email = isset($data->email) ? $data->email : null;
$new_password = isset($data->new_password) ? $data->new_password : null;

// Validate input
if (!$email) {
    echo json_encode(["status"=>"error","message"=>"Email cannot be empty"]);
    exit;
}

$conn = new mysqli("localhost", "root", "", "mysql_auth_backend");
if ($conn->connect_error) {
    echo json_encode(["status"=>"error","message"=>"Database connection failed"]);
    exit;
}

// Check if user exists
$sql = $conn->prepare("SELECT * FROM users WHERE email=?");
$sql->bind_param("s", $email);
$sql->execute();
$result = $sql->get_result();

if ($result->num_rows > 0) {
    if ($new_password) {
        // ✅ Hash new password
        $hashed_password = password_hash($new_password, PASSWORD_DEFAULT);
        $update = $conn->prepare("UPDATE users SET password=? WHERE email=?");
        $update->bind_param("ss", $hashed_password, $email);
        if ($update->execute()) {
            echo json_encode(["status"=>"success","message"=>"Password updated successfully"]);
        } else {
            echo json_encode(["status"=>"error","message"=>"Failed to update password"]);
        }
    } else {
        echo json_encode(["status"=>"success","message"=>"User exists. Provide new_password to reset."]);
    }
} else {
    echo json_encode(["status"=>"error","message"=>"Email not registered"]);
}

$conn->close();
?>
