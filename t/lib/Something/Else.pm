#!/usr/bin/perl

package Something::Else;

use 5.012;
use strict;
use warnings;

use Moo;
use namespace::clean;

extends 'Something::Mutable';
with 'MooX::Role::CloneSet::BuildArgs';

1;
