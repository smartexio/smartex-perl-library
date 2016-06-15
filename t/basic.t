#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Business::Smartex;
use JSON 'decode_json';

my $api_key = 'someapikey';
my $smartex  = new_ok 'Business::Smartex', [$api_key];
my $data    = {price => 15, currency => 'USD'};

subtest 'POST request' => sub {
    my $request = $smartex->prepare_request('invoice', $data);
    is $request->method, 'POST', 'method';
    is $request->uri, "https://$api_key:\@smartex.io/api/invoice", 'uri';
    is $request->header('content-type'), 'application/json', 'content type';
    is $request->header('X-Smartex-Plugin-Info'),
      'perl' . $Business::Smartex::VERSION, 'plugin info header';
    is_deeply decode_json($request->content), $data, 'data';
};

subtest 'GET request' => sub {
    my $request = $smartex->prepare_request('invoice/id');
    is $request->method, 'GET', 'method';
    is $request->uri, "https://$api_key:\@smartex.io/api/invoice/id", 'uri';
};

done_testing();
