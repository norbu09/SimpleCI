#!/usr/bin/perl

package SimpleCI;

use strict;
use warnings;
use Config::Any;

sub get_conf {
    my $module = shift;
    my $cfg    = Config::Any->load_files(
        { files => ['etc/projects.ini'], use_ext => 1 } );
    my $conf;
    for (@$cfg) {
        my ( $filename, $config ) = %$_;
        $filename =~ s{^.*/([^\.]+).*$}{$1};
        $conf->{$filename} = $config;
    }
    if ($module) {
        return $conf->{projects}->{$module};
    }
    return $conf;
}

1;
