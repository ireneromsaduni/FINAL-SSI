<?php
session_start();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_SESSION['loggedin']) && $_SESSION['loggedin'] === true) {
        $uploadDir = 'upload/';
        $uploadFile = $uploadDir . basename($_FILES['file']['name']);

        if (move_uploaded_file($_FILES['file']['tmp_name'], $uploadFile)) {
            echo "File successfully uploaded: <a href='$uploadFile'>$uploadFile</a>";
        } else {
            echo "Error uploading file.";
        }
    } else {
        echo "Access denied. Please log in.";
    }
}
?>
