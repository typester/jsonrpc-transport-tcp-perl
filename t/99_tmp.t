use Test::Base;

plan 'no_plan';

use_ok('JSONRPC::Transport::TCP');

my $jsonrpc = JSONRPC::Transport::TCP->new(
    host => '127.0.0.1',
    port => 3000,
);

ok( my $res = $jsonrpc->call('echo', 'foo', 'bar') );
ok( $res->result );

is_deeply( $res->result, [qw/foo bar/] );

