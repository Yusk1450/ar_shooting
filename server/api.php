<?php

ini_set( 'display_errors', 1 );

use Slim\Factory\AppFactory;

require_once("vendor/autoload.php");
require_once('db.php');

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Origin, X-Requested-With, Content-Type, Accept');

$app = AppFactory::create();

$env = file_get_contents('.env');
$env = json_decode($env, true);

if ($env['mode'] == 'debug')
{
	$app->setBasePath('/WORKS/NBU/ar_shooting/server');
}

/* ------------------------------------------------------
 * 部屋を作る
------------------------------------------------------ */
$app->get('/create_room', function($req, $res, $args)
{
	$pdo = db();

	// TODO: 1日以上経過したルームを削除する

	$code = rand(0, 99999);
	$code = sprintf('%05d', $code);

	$params = $req->getQueryParams();

	$pdo->beginTransaction();

	$sql = 'INSERT INTO rooms (code) VALUE(:code)';
	$stmt = $pdo->prepare($sql);
	$stmt->execute([':code' => $code]);

	$room_id = $pdo->lastInsertId();

	$sql = 'UPDATE users SET room_id = :room_id, life = :life WHERE id = :id';
	$stmt = $pdo->prepare($sql);
	$stmt->execute([':room_id' => $room_id, ':life' => $params['life'], ':id' => $params['user_id']]);

	try
	{
		$pdo->commit();

		$resBody = $res->getBody();
		$resBody->write(json_encode(['room_id' => $room_id]));
	}
	catch(PDOException $e)
	{
		$pdo->rollBack();
	}

	return $res;
});

/* ------------------------------------------------------
 * ユーザを作る
------------------------------------------------------ */
$app->get('/create_user', function($req, $res, $args)
{
	$pdo = db();

	$pdo->beginTransaction();

	$sql = 'INSERT INTO users () VALUE()';
	$stmt = $pdo->prepare($sql);
	$stmt->execute();

	$user_id = $pdo->lastInsertId();

	try
	{
		$pdo->commit();

		$resBody = $res->getBody();
		$resBody->write(json_encode(['user_id' => $user_id]));
	}
	catch(PDOException $e)
	{
		$pdo->rollBack();
	}

	return $res;
});

/* ------------------------------------------------------
 * ルームに入る
------------------------------------------------------ */
$app->get('/enter_room', function($req, $res, $args)
{
	$pdo = db();

	$params = $req->getQueryParams();

	$sql = 'SELECT * FROM rooms WHERE code = :code';
	$stmt = $pdo->prepare($sql);
	$stmt->execute([':code' => $params['code']]);

	$rowCount = $stmt->rowCount();

	$resBody = $res->getBody();

	if ($rowCount == 0)
	{
		$resBody->write('error');
	}
	else
	{
		$room_id = -1;
		foreach ($stmt as $row)
		{
			$room_id = $row['id'];
		}

		$pdo->beginTransaction();

		$sql = 'UPDATE users SET room_id = :room_id, life = :life WHERE id = :id';
		$stmt = $pdo->prepare($sql);
		$stmt->execute([':room_id' => $room_id, ':life' => $params['life'], 'id' => $params['user_id']]);

		try
		{
			$pdo->commit();
	
			$resBody->write(json_encode(['room_id' => $room_id]));
		}
		catch(PDOException $e)
		{
			$pdo->rollBack();
		}
	}

	return $res;
});


$app->get('/life', function($req, $res, $args)
{
	$params = $req->getQueryParams();



	// $res->getBody()->write($json);
	return $res;
});


$app->get('/recovery', function($req, $res, $args)
{
	$params = $req->getQueryParams();



	// $res->getBody()->write($json);
	return $res;
});


$app->get('/damage', function($req, $res, $args)
{
	$params = $req->getQueryParams();



	// $res->getBody()->write($json);
	return $res;
});


$app->run();

