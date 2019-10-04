<?php
	header ('Content-type: text/html; charset=utf-8');
	$db = new SQLite3("database.db");
	if (!$db) {
		echo "false";
		die;
	}

	// check user existence

	$result = $db->query("
			SELECT ID, USERNAME, PASSWORD
			FROM USERS
			WHERE USERNAME = '".$_GET["USERNAME"]."'
	");

	if($result->fetchArray()) {
		echo "false";
		die;
	}

	// append

	$db->query("
			INSERT INTO USERS
			(USERNAME, PASSWORD) VALUES
			('".$_GET["USERNAME"]."', '".$_GET["PASSWORD"]."');
	");

	echo "true"; // added
?>
