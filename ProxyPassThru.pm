package Apache::ProxyPassThru;
use strict;
use LWP::UserAgent ();
use Apache::Constants ':common';

my $VERSION = "0.10";

sub handler {
    my($r) = @_;
    return DECLINED unless $r->proxyreq;
    $r->handler("perl-script"); #ok, let's do it
    $r->push_handlers(PerlHandler => \&proxy_handler);
    return OK;
}

sub proxy_handler {
    my($r) = @_;
    my($key,$val);

    my $request = new HTTP::Request $r->method, $r->uri;

    my(%headers_in) = $r->headers_in;
    while(($key,$val) = each %headers_in) {
	$request->header($key,$val);
    }

    my $res = (new LWP::UserAgent)->request($request);
    $r->content_type($res->header('Content-type'));
    #feed reponse back into our request_rec*
    $r->status($res->code);
    $r->status_line(join " ", $res->code, $res->message);
    $res->scan(sub {
	$r->header_out(@_);
    });

    $r->send_http_header();
    $r->print($res->content);

    $r->notes("DumpHeaders", 1)
      if $r->dir_config("ProxyPassThru_DumpHeaders");

    return OK;
}

1;

__END__

=head1 NAME

Apache::ProxyPassThru - Skeleton for vanilla proxy

=head1 SYNOPSIS

 #httpd.conf or some such
 PerlTransHandler  Apache::ProxyPassThru
 PerlSetVar        ProxyPassThru_DumpHeaders 1

=head1 DESCRIPTION

This module uses libwww-perl as it's web client, feeding the response
back into the Apache API request_rec structure.
`PerlHandler' will only be invoked if the request is a proxy request,
otherwise, your normal server configuration will handle the request.

If used with the Apache::DumpHeaders module it lets you view the
headers from another site you are accessing.

=head1 PARAMETERS

This module is configured with PerlSetVar's.

=head2 ProxyPassThru_DumpHeaders

If this is set to a true value we'll set r->notes("DumpHeaders") to a
true value.

Makes it easy to have Apache::DumpHeaders only dump headers from your
proxied requests.

=head1 SEE ALSO

mod_perl(3), Apache(3), LWP::UserAgent(3)

=head1 AUTHOR

Ask Bjoern Hansen <ask@valueclick.com>. 

Originally by Doug MacEachern.


