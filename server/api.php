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
else
{
	$app->setBasePath('/barng');
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
		// ルームID
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

/* ------------------------------------------------------
 * ライフを取得する
------------------------------------------------------ */
$app->get('/life', function($req, $res, $args)
{
	$pdo = db();

	$params = $req->getQueryParams();

	// ルームID
	$room_id = $params['room_id'];

	$sql = 'SELECT * FROM users WHERE room_id = :room_id';
	$stmt = $pdo->prepare($sql);
	$stmt->execute([':room_id' => $room_id]);

	$result = [];
	foreach ($stmt as $row)
	{
		$data = array();

		$data['user_id'] = $row['room_user_id'];
		$data['life'] = $row['life'];

		$result []= $data;
	}

	$res->getBody()->write(json_encode($result));
	return $res;
});

/* ------------------------------------------------------
 * 指定したプレイヤーにダメージを与える
------------------------------------------------------ */
$app->post('/damage', function($req, $res, $args)
{
	$pdo = db();

	$params = $req->getParsedBody();

	// ルームID
	$room_id = $params['room_id'];
	// ユーザ番号（1〜4）
	$my_room_user_id = $params['my_user_id'];
	// ユーザ番号（1〜4）
	$target_room_user_id = $params['target_user_id'];
	// ダメージ
	$damage = 10;

	// 自身のアイテムを確認する
	$sql = 'SELECT item FROM users WHERE room_id = :room_id AND room_user_id = :room_user_id';
	$stmt = $pdo->prepare($sql);
	$stmt->execute([':room_id' => $room_id, ':room_user_id' => $my_room_user_id]);
	$result = $stmt->fetch(PDO::FETCH_ASSOC);

	// アイテムを所持していた場合
	$item = $result['item'];

	// 攻撃力アップ
	if ($item == 0)
	{
		$damage *= 1.2;
	}

	// 相手のアイテムを確認する
	$sql = 'SELECT item FROM users WHERE room_id = :room_id AND room_user_id = :room_user_id';
	$stmt = $pdo->prepare($sql);
	$stmt->execute([':room_id' => $room_id, ':room_user_id' => $target_room_user_id]);
	$result = $stmt->fetch(PDO::FETCH_ASSOC);

	// アイテムを所持していた場合
	$item = $result['item'];

	// 防御力アップ
	if ($item == 1)
	{
		$damage *= 0.8;
	}

	$pdo->beginTransaction();

	$sql = 'UPDATE users SET life = GREATEST(life - :damage, 0) WHERE room_id = :room_id AND room_user_id = :room_user_id';
	$stmt = $pdo->prepare($sql);
	$stmt->execute([':room_id' => $room_id, ':room_user_id' => $target_room_user_id, ':damage' => $damage]);

	try
	{
		$pdo->commit();

		$resBody = $res->getBody();
		$resBody->write('OK');
	}
	catch(PDOException $e)
	{
		$pdo->rollBack();
	}

	return $res;
});

/* ------------------------------------------------------
 * 指定したプレイヤーを回復する
------------------------------------------------------ */
$app->post('/recovery', function($req, $res, $args)
{
	$pdo = db();

	$params = $req->getParsedBody();

	// ルームID
	$room_id = $params['room_id'];
	// ユーザ番号（1〜4）
	$room_user_id = $params['user_id'];
	// 回復
	$amount = 10;

	$pdo->beginTransaction();

	$sql = 'UPDATE users SET life = LEAST(life + :amount, 100) WHERE room_id = :room_id AND room_user_id = :room_user_id';
	$stmt = $pdo->prepare($sql);
	$stmt->execute([':room_id' => $room_id, ':room_user_id' => $room_user_id, ':amount' => $amount]);

	try
	{
		$pdo->commit();

		$resBody = $res->getBody();
		$resBody->write('OK');
	}
	catch(PDOException $e)
	{
		$pdo->rollBack();
	}

	return $res;
});

$app->post('/reset', function($req, $res, $args)
{
	$pdo = db();

	$params = $req->getParsedBody();

	// ルームID
	$room_id = $params['room_id'];

	$pdo->beginTransaction();

	$sql = 'UPDATE users SET life = 100 WHERE room_id = :room_id';
	$stmt = $pdo->prepare($sql);
	$stmt->execute([':room_id' => $room_id]);

	try
	{
		$pdo->commit();

		$resBody = $res->getBody();
		$resBody->write('OK');
	}
	catch(PDOException $e)
	{
		$pdo->rollBack();
	}

	return $res;

});

$app->post('/item', function($req, $res, $args)
{
	$params = $req->getParsedBody();

	// ルームID
	$room_id = $params['room_id'];
	// ユーザ番号（1〜4）
	$room_user_id = $params['user_id'];
	// アイテムID
	$item_id = $params['item_id'];

	$pdo = db();

	$pdo->beginTransaction();

	$sql = 'UPDATE users SET item = :item WHERE room_id = :room_id AND room_user_id = :room_user_id';
	$stmt = $pdo->prepare($sql);
	$stmt->execute([':room_id' => $room_id, ':room_user_id' => $room_user_id, ':item' => $item_id]);

	try
	{
		$pdo->commit();

		$resBody = $res->getBody();
		$resBody->write('OK');
	}
	catch(PDOException $e)
	{
		$pdo->rollBack();
	}

	return $res;
});



$app->run();

