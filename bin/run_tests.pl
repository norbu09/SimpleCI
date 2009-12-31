#!/usr/bin/perl -Ilib

use strict;
use warnings;
use Data::Dumper;
use SimpleCI;
use Template::Alloy;
use File::Util;

my ($f) = File::Util->new();

my $conf = SimpleCI::get_conf();
print Dumper($conf);

my $msg;
my $t = Template::Alloy->new( INCLUDE_PATH => ['templates'], );
foreach my $project ( keys %{ $conf->{projects} } ) {
    my $hash;
    $hash->{project} = $project;
    print "... checking out $project\n";
    qx{bin/checkout.pl $project};

    print "... running tests for $project\n";
    qx{bin/generate_report.pl $project};
    my $path = $conf->{projects}->{$project}->{sci_path};
    my @p = split( /\//, $path );
    pop(@p);
    my $sci_path = '/' . join( '/', @p );
    my @_files = $f->list_dir( $sci_path, '--files-only' );
    print Dumper(@_files);
    my @files;
    my @stati;

    foreach my $file (@_files) {
        $file = $sci_path . '/' . $file;
        #next unless $file =~ /^$path/;
        my $created = $f->created($file);
        my $cont    = $f->load_file($file);
        my $out = '';
        $t->process( 'git/checkout.tt', eval $cont, \$out );
        push( @stati, { $created => $out } );
    }
    @stati = sort {$b <=> $a} @stati;
    foreach my $s (@stati){
        my ($key, $val) = each %{$s};
        push(@{$hash->{stati}}, $val);
    }

    push( @{ $msg->{projects} }, $hash );
}

print Dumper($msg);
my $out = '';
$t->process( 'index.tt', $msg, \$out );
open(FH, '>', '/tmp/simpleci/html/index.html');
print FH $out;
close FH;
