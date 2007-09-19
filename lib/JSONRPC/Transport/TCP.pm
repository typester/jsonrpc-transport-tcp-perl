package JSONRPC::Transport::TCP;
use strict;
use warnings;
use base qw/Class::Accessor::Fast/;

__PACKAGE__->mk_accessors(qw/result error/);

use IO::Socket::INET;
use JSON::Any;
use Carp;

our $VERSION = '0.01';

=head1 NAME

JSONRPC::Transport::TCP - Module abstract (<= 44 characters) goes here

=head1 SYNOPSIS

use JSONRPC::Transport::TCP;

    my $rpc = JSONRPC::Transport::TCP->new( host => '127.0.0.1', port => 3000 );
    my $res = $rpc->call('echo', 'arg1', 'arg2' );
    
    if ($res->error) {
        warn $res->error;
    }
    else {
        print $res->result;
    }

=head1 DESCRIPTION

Stub documentation for this module was created by ExtUtils::ModuleMaker.
It looks like the author of the extension was negligent enough
to leave the stub unedited.

Blah blah blah.

=head1 METHODS

=head2 new

=cut

sub new {
    my $self = shift->SUPER::new( @_ > 1 ? {@_} : $_[0] );

    $self->{id} = 0;
    $self->{json} ||= JSON::Any->new;
    $self->{delimiter} ||= "\n";

    $self;
}

=head2 connect

=cut

sub connect {
    my $self = shift;
    my $params = @_ > 1 ? {@_} : $_[0];

    $self->disconnect if $self->{socket};

    my $socket;
    eval {
        $socket = IO::Socket::INET->new(
            PeerAddr => $params->{host}  || $self->{host},
            PeerPort => $self->{port}    || $self->{port},
            xxProto  => 'tcp',
            Timeout  => $self->{timeout} || 30,
        )
          or croak
            qq/Unable to connect to "@{[ $params->{host}  || $self->{host} ]}:@{[ $params->{port}  || $self->{port} ]}": $!/;

        $socket->autoflush(1);

        $self->{socket} = $socket;
    };
    if ($@) {
        $self->{error} = $@;
        return;
    }

    1;
}

=head2 disconnect

=cut

sub disconnect {
    my $self = shift;
    delete $self->{socket} if $self->{socket};
}

=head2 call

=cut

sub call {
    my ($self, $method, @params) = @_;

    $self->connect unless $self->{socket};
    return unless $self->{socket};

    my $request = {
        id     => ++$self->{id},
        method => $method,
        params => \@params,
    };

    $self->{socket}->print($self->{json}->Dump($request) . $self->{delimiter});

    my $timeout = $self->{socket}->timeout;
    my $limit   = time + $timeout;

    my $select = IO::Select->new or croak $!;
    $select->add($self->{socket});

    my $buf = '';

    while ($limit >= time) {
        my @ready = $select->can_read( $limit - time )
            or last;

        for my $s (@ready) {
            croak qq/$s isn't $self->{socket}/ unless $s eq $self->{socket};
        }

        unless (my $l = $self->{socket}->sysread( $buf, 512, length($buf) )) {
            my $e = $!;
            $self->disconnect;
            croak qq/Error reading: $e/;
        }

        if (my ($json) = $buf =~ /^(.*)$self->{delimiter}/) {
            my $result;
            eval {
                $result = $self->{json}->Load($json);
            };
            if ($@) {
                $self->{error} = "json parse error: $@";
                return;
            }

            if ($result->{error}) {
                $self->{error} = $result->{error};
                return;
            }
            else {
                $self->{result} = $result->{result};
                return $self;
            }
        }
    }

    croak "request timeout";
}

=head2 DESTROY

=cut

sub DESTROY {
    my $self = shift;
    $self->disconnect;
}

=head1 AUTHOR

Daisuke Murase <typester@cpan.org>

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut

1;
