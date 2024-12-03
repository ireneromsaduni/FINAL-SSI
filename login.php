<?php
// Conexión a la base de datos
$conn = mysqli_connect('localhost', 'mysqluser', 'ssi2024', 'vulnerable_db');

// Verificar conexión
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Manejar el formulario
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $username = $_POST['username'];
    $password = $_POST['password'];

    // Consulta SQL vulnerable (inyección SQL)
    $query = "SELECT * FROM users WHERE username = '$username' AND password = '$password'";
    $result = $conn->query($query);

    if ($result && $result->num_rows > 0) {
    	echo file_get_contents("upload.html");
    } else {
        echo "Invalid username or password.";
    }
}
?>
