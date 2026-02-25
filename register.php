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
$password = isset($data->password) ? $data->password : null;

// Validate input
if (!$email || !$password) {
    echo json_encode(["status"=>"error","message"=>"Email and password cannot be empty"]);
    exit;
}

// Connect to DB
$conn = new mysqli("localhost", "root", "", "mysql_auth_backend");
if ($conn->connect_error) {
    echo json_encode(["status"=>"error","message"=>"Database connection failed"]);
    exit;
}

// Check if email already exists
$sql = $conn->prepare("SELECT * FROM users WHERE email=?");
$sql->bind_param("s", $email);
$sql->execute();
$result = $sql->get_result();

if ($result->num_rows > 0) {
    echo json_encode(["status"=>"error","message"=>"Email already registered"]);
    exit;
}

// ✅ Hash password
$hashed_password = password_hash($password, PASSWORD_DEFAULT);

// Insert new user
$insert = $conn->prepare("INSERT INTO users (email,password) VALUES (?,?)");
$insert->bind_param("ss", $email, $hashed_password);

if ($insert->execute()) {
    echo json_encode(["status"=>"success","message"=>"Registration successful"]);
} else {
    echo json_encode(["status"=>"error","message"=>"Registration failed"]);
}

$insert->close();
$conn->close();
?>
