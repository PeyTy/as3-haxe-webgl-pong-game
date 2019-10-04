<?php
	header ('Content-type: text/html; charset=utf-8');
	echo "<br>Database creation";
	// Create data base
	$db = new SQLite3("database.db");
	if (!$db) exit("<br>Failed to create a DB!");
	if ($db) echo "<br>Successfully created a DB!";

	// user-password

	$db->query("
		CREATE TABLE IF NOT EXISTS `USERS` (
			`ID` integer PRIMARY KEY AUTOINCREMENT,
			`USERNAME` varchar(255) NOT NULL default '',
			`PASSWORD` varchar(255) NOT NULL default ''
		)
	");

	// user-score

	$db->query("
		CREATE TABLE IF NOT EXISTS `SCORES` (
			`ID` integer PRIMARY KEY,
			`BESTSCORE` integer default 0
		)
	");

	echo "<br>Tables Created";
?>
