package Business::Smartex;

use strict;
use warnings;

use 5.008_001;
our $VERSION = '0.05';
eval $VERSION;

use HTTP::Request;
use URI;
use JSON qw(encode_json decode_json);
use LWP::UserAgent;
require Carp;

sub new {
    my ($class, $api_key, @args) = @_ or Carp::croak("api key missed");

    bless {
        key     => $api_key,
        gateway => 'https://smartex.io/api/',
        ua      => LWP::UserAgent->new,
        @args
    }, $class;
}

sub prepare_request {
    my ($self, $api, $data) = @_;

    my $uri = URI->new($self->{gateway});
    $uri->userinfo($self->{key} . ':');
    $uri->path($uri->path . $api);

    my $method = 'GET';
    my @fields;
    if ($data) {
        $method = 'POST';
        $data   = encode_json $data;
        push @fields, 'Content-Type' => 'application/json';
    }

    my $request = HTTP::Request->new(
        $method => $uri, [
            'User-Agent'   => 'Smartex Perl Client',
            'X-Smartex-Plugin-Info' => 'perl' . $VERSION,
            @fields,
        ],
        $data
    );
    $request;
}

sub request {
    my $self = shift;

    my $http_response = $self->{ua}->request($self->prepare_request(@_));
    Carp::croak($http_response->status_line)
      unless $http_response->is_success;

    my $response = decode_json($http_response->decoded_content);

    if (my $error = $response->{error}) {
        my $messages = $error->{messages};
        Carp::croak("$error->{message}: ",
            join(', ', map {"$_ ($messages->{$_})"} keys %$messages));
    }

    $response;
}


sub create_invoice {
    my ($self, %args) = @_;

    Carp::croak('price missed')    unless exists $args{price};
    Carp::croak('currency missed') unless exists $args{currency};

    $self->request('invoice', \%args);
}

sub get_invoice {
    my ($self, $id) = @_;

    $self->request("invoice/$id");
}

1;
__END__

=head1 NAME

Business::Smartex - Smartex API

=head1 SYNOPSIS

    use Business::Smartex;
    my $smartex = Business::Smartex->new($api_key);

    # create new invoice
    $invoice = $smartex->create_invoice(price => 10, currency => 'USD');

    # get invoice data
    $invoice = $smartex->get_invoice($invoice->{id});

=head1 DESCRIPTION
    
Smartex API documentation contents full description of API methods.

=head2 C<new>

    my $smartex = Business::Smartex->new($api_key);

Construct Business::Smartex object.

=head2 C<create_invoice>

    my $invoice = $smartex->create_invoice(price => 10, currency => 'USD');

Creates new invoice. This method will croak in case of error. Full list of
fields and their description can be found in C<Creating an Invoice> section of
Smartex API documentation.

Returns hashref representing of the invoice object. Description can be found in
C<Smartex Server Response> section of the Smartex API documentation.

=head2 C<get_invoice>

    my $invoice = $smartex->get_invoice($invoice_id);

Returns invoice hashref or croak if error occurred. Returned invoice object has
exactly the same format as that which is returned when creating an invoice.

=cut
