<?php
	header ('Content-type: text/html; charset=utf-8');
	// Create data base
	$db = new SQLite3("database.db");
	if (!$db) {
		die;
	}

	// add score field by ID (if none)

	$db->query("
		REPLACE INTO `SCORES` (ID)
		SELECT ID
		FROM `USERS`
		WHERE USERNAME = '".$_GET["USERNAME"]."' AND PASSWORD = '".$_GET["PASSWORD"]."'
	");

	// save results

	$db->query("
			UPDATE `SCORES`
			SET BESTSCORE = '".$_GET["BESTSCORE"]."'
			WHERE ID IN (
				SELECT ID
				FROM `USERS`
				WHERE USERNAME = '".$_GET["USERNAME"]."' AND PASSWORD = '".$_GET["PASSWORD"]."'
			)
	");
?>
