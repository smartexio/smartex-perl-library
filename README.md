# Using the Smartex Perl Client Library
## Prerequisites
You must have a Smartex merchant account to use this library.  It's free to [sign-up for a Smartex merchant account](https://smartex.io/dashboard/signup).

Once you have a Smartex merchant account, you will need [a working Smartex Access Token](/api) – this can be done either [via the library](#pairing) or manually in [the Smartex Dashboard](https://smartex.io/tokens).

## Quick Start
```perl
use Business::Smartex;
my $smartex = Business::Smartex->new($api_key);

# create new invoice
$invoice = $smartex->create_invoice(price => 10, currency => 'USD');

# get invoice data
$invoice = $smartex->get_invoice($invoice->{id});
```

### New Object Creation
```perl
my $smartex = Business::Smartex->new($api_key);
```
Construct Business::Smartex object.

### Creating an Invoice
```perl
my $invoice = $smartex->create_invoice(price => 10, currency => 'USD');
```
Creates new invoice. This method will croak in case of error. Full list of
fields and their description can be found in C<Creating an Invoice> section of
Smartex API documentation.

Returns hashref representing of the invoice object. Description can be found in
C<Smartex Server Response> section of the Smartex API documentation.

### Retrieving an Invoice
```perl
my $invoice = $smartex->get_invoice($invoice_id);
```
Returns invoice hashref or croak if error occurred. Returned invoice object has
exactly the same format as that which is returned when creating an invoice.