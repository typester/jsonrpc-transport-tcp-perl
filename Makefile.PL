use inc::Module::Install;
name 'JSONRPC-Transport-TCP';
all_from 'lib/JSONRPC/Transport/TCP.pm';

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
