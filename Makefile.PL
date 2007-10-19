use inc::Module::Install;
name 'JSONRPC-Transport-TCP';
all_from 'lib/JSONRPC/Transport/TCP.pm';

build_requires 'Test::More';

requires 'Class::Accessor::Fast';
requires 'IO::Socket::INET';
requires 'Carp';
requires 'JSON::Any';

use_test_base;
auto_include;
WriteAll;
