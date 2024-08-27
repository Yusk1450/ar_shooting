<?php

ini_set( 'display_errors', 1 );

use Slim\Factory\AppFactory;

require_once(dirname(__FILE__)."/vendor/autoload.php");
require_once(dirname(__FILE__)."/dao/common_dao.php");
require_once(dirname(__FILE__)."/dao/members_dao.php");
require_once(dirname(__FILE__)."/dao/objects_dao.php");
require_once(dirname(__FILE__)."/dao/reserves_dao.php");
require_once('session.php');
require_once('send_mail.php');

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Origin, X-Requested-With, Content-Type, Accept');

$app = AppFactory::create();

$env = file_get_contents('.env');
$env = json_decode($env, true);

if ($env['mode'] == 'debug')
{
	$app->setBasePath('/WORKS/Carcle/casagarage_admin/src');
}

$app->get('/gamestart', function($req, $res, $args)
{
	$params = $req->getQueryParams();

	$player_num = $params['player_num'];
	$max_life = $params['max_life'];


	// $res->getBody()->write($json);
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

