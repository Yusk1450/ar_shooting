<?php

function db()
{
    $database_address = "localhost";// データベースアドレス
    $database_port = "8889";
    $database_name = "barng";// データベース名
    $database_username = "root";// データベースユーザ名
    $database_password = "root";// データベースパスワード

    $options = array(
        PDO::MYSQL_ATTR_INIT_COMMAND => 'SET NAMES utf8mb4',
    );

    $pdo = new PDO("mysql:host=" . $database_address . ";port=" . $database_port . ";dbname=" . $database_name, $database_username, $database_password, $options);

    // 静的プレースホルダを指定する
    $pdo->setAttribute(PDO::ATTR_EMULATE_PREPARES, false);
    // エラー発生時に例外を投げる
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    return $pdo;
}