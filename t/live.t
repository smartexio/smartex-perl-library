#!/usr/bin/env perl

use strict;
use warnings;

use Business::Smartex;
use Test::More;

plan skip_all => 'set SMARTEX env variable to API key'
  unless $ENV{SMARTEX};
my $api_key = $ENV{SMARTEX};

my $smartex = new_ok 'Business::Smartex', [$api_key];

my $invoice;
subtest 'create invoice' => sub {
    $invoice = $smartex->create_invoice(
        price    => 10,
        currency => 'USD',
        posData  => rand
    );

    is $invoice->{status}, 'new';
    is $invoice->{price},  10;
};

subtest 'get invoice' => sub {
    my $invoice_getted = $smartex->get_invoice($invoice->{id});

    is $invoice_getted->{posData}, $invoice->{posData};
};

subtest 'wrong invoice data' => sub {
    eval {
        $smartex->create_invoice(
            price    => 10,
            price    => 'a',
            currency => 'money'
        );
    };

    like $@, qr/One or more fields is invalid/;
};

done_testing;
