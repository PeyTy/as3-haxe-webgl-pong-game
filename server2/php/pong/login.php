<?php
	header ('Content-type: text/html; charset=utf-8');
	$db = new SQLite3("database.db");
	if (!$db) {
		echo "false";
		die;
	}

	$result = $db->query("
			SELECT ID, USERNAME, PASSWORD
			FROM USERS
			WHERE USERNAME = '".$_GET["USERNAME"]."' AND PASSWORD = '".$_GET["PASSWORD"]."'
	");

	if($result->fetchArray()) {
		echo "true";
		die;
	}

	echo "false";
	die;
?>