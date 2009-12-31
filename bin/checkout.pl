#!/usr/bin/perl -Ilib

use strict;
use warnings;
use SimpleCI;
use Data::Dumper;

my $conf = SimpleCI::get_conf(shift);
my $repo = $conf->{repository};
my $dir = $conf->{build_path};

if(-d $dir){
    qx{cd $dir && git pull};
} else {
    qx{git clone $repo $dir};
}
