<?php
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $uploadDir = 'upload/';
    $uploadFile = $uploadDir . basename($_FILES['file']['name']);
    if (move_uploaded_file($_FILES['file']['tmp_name'], $uploadFile)) {
        echo "File successfully uploaded: <a href='$uploadFile'>$uploadFile</a>";
    } else {
        echo "Error uploading file.";
    }
}
?>
