package Apache::DumpHeaders;
use Apache;

$VERSION = 0.03;

sub handler {
  my ($r) = @_;
  if ($r->dir_config("DumpHeaders_IP")) {
    my $remote_ip = $r->connection->remote_ip;
    return DECLINED unless grep { /\Q$remote_ip\E/ }
      split (/\s+/, $r->dir_config("DumpHeaders_IP"));
  }
  my $filename = $r->dir_config("DumpHeaders_File") or return DECLINED;
  unless (open OUT, ">>$filename") {
    warn "Failed to open $filename: $!";
    return DECLINED;
  }
  print OUT $r->as_string;
  close OUT;
  return OK;
}

1;

__END__

=head1 NAME

Apache::DumpHeaders - Watch HTTP transaction via headers

=head1 SYNOPSIS

 #httpd.conf or some such
 PerlLogHandler Apache::DumpHeaders
 PerlSetVar     DumpHeaders_File -
 PerlSetVar     DumpHeaders_IP "1.2.3.4 1.2.3.5"

=head1 DESCRIPTION

This module is used to watch an HTTP transaction, looking at client and
servers headers.

With Apache::ProxyPassThur configured, you are able to watch your browser
talk to any server besides the one with this module living inside.

=head1 PARAMETERS

This module is configured with PerlSetVar's.

=head2 DumpHeaders_File

Required parameter to specify which file you want to dump the headers
to.

=head2 DumpHeaders_IP

Optional parameter to specify which one or more IP addresses you want
to dump traffic from.

=head1 SEE ALSO

mod_perl(3), Apache(3), Apache::ProxyPassThru(3)

=head1 AUTHOR

Ask Bjoern Hansen <ask@valueclick.com>.

Originally by Doug MacEachern.


