#!/usr/bin/perl -Ilib
use TAP::Harness;
use TAP::Formatter::HTML;
use SimpleCI;
use Data::Dumper;
use Template::Alloy;

my $conf = SimpleCI::get_conf(shift);

my @libs = @INC;
push( @libs, $conf->{build_path} . '/lib' );

my @tests   = glob( $conf->{build_path} . '/t/*.t' );
my $fmt     = TAP::Formatter::HTML->new;
my $harness = TAP::Harness->new(
    {
        formatter => $fmt,
        merge     => 1,

        #        test_args => [ 'CATALYST_SERVER=http://10.211.55.12/' ],
        lib => \@libs,
    }
);
my $file_name = $conf->{html_path} . time . '.html';
$fmt->output_file($file_name);
my $tests = $harness->runtests(@tests);

my $dir    = $conf->{build_path};
my @status = qx{cd $dir && git log -n1 --stat};
my $state  = 0;
my $msg;
$msg->{report} = $file_name;
$msg->{status} = ( $tests->has_errors ? 'error' : 'success' );
foreach my $line (@status) {
    chomp($line);
    $state = 1 if ( $line =~ /^$/ );
    if ($state) {
        $msg->{content} .= $line . "\n";
    }
    else {
        my ( $key, $val ) = split( / /, $line, 2 );
        $key =~ s/://g;
        $val =~ s/^\s*//;
        $msg->{ lc($key) } = $val;
    }
}

#print STDERR Dumper($msg);
open( MSG, '>', $conf->{sci_path} . time . '.sci' );
$Data::Dumper::Purity = 1;
$Data::Dumper::Terse  = 1;
print MSG Dumper($msg);
close MSG;
