<?php
if (isset($_GET['page'])) {
    $page = $_GET['page'];

    // LFI Vulnerability: No hay validación en la entrada del usuario
    include($page);
} else {
    echo "No page specified.";
}
?>

