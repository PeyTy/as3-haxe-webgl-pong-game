<?php
	header ('Content-type: text/html; charset=utf-8');
	// Create data base
	$db = new SQLite3("database.db");
	if (!$db) {
		die;
	}

	// send results

	$result = $db->query("
			SELECT * FROM `SCORES`
			WHERE ID IN (
				SELECT ID
				FROM `USERS`
				WHERE USERNAME = '".$_GET["USERNAME"]."'
			)
	");

	echo json_encode($result->fetchArray(SQLITE3_ASSOC));
?>
