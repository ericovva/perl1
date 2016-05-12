#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use Plack::Builder;
use lib "$FindBin::Bin/../lib";

use Web::App;
use Web::Admin;
#Web::App->to_app;
builder {
	enable 'Session';
    enable 'CSRFBlock';
    mount '/'      => Web::App->to_app;
    mount '/admin' => Web::Admin->to_app;
};
