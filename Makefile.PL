use inc::Module::Install;
name 'JSONRPC-Transport-TCP';
all_from 'lib/JSONRPC/Transport/TCP.pm';

perl_version '5.008001';

test_requires 'Test::More';
test_requires 'Test::TCP';

requires 'Class::Accessor::Fast';
requires 'IO::Socket::INET';
requires 'Carp';
requires 'JSON';

recommends 'JSON::XS';

use_test_base;
auto_include;
WriteAll;
