package Resmon::Module::MDSTAT;
use strict;
use Resmon::ExtComm qw/cache_command/;
use vars qw/@ISA/;
@ISA = qw/Resmon::Module/;

my $statfile = '/proc/mdstat';

sub handler {
    my $arg = shift;
    open FH, "<$statfile";
    my $getnext = 0;
    my $status = "OK";
    my @message = ();
    my $array = "";
    while (<FH>) {
        chomp;
        if (/^(md[0-9]+)\s*:\s+/) {
            $array = $1;
            my $messageline = "$array ";
            my @baddevs = ();
            foreach my $part (split(/ /,"$'")) {
                if ($part eq "active") {
                    $messageline .= "active ";
                } elsif ($part eq "inactive") {
                    $status = "BAD";
                    $messageline .= "inactive ";
                } elsif ($part =~ /^([a-z0-9]+)\[(\d+)\](?:\((\S+)\))?$/) {
                    if ($3 eq "F") {
                        $status = "BAD";
                        push @baddevs, $1;
                    }
                }
            }
            chop $messageline;
            if (@baddevs) {
                $messageline = "$messageline - " . join(', ', @baddevs) .
                    " faulted";
            }
            push @message, $messageline;
        } elsif (/\[([U_]+)\]/) {
            my $devices = $1;
            my $count = ($devices =~ tr/_//);
            if ($count > 0) {
                $status = "BAD";
                # Plural if required
                my $s = '';
                if ($count > 1) {
                    $s = 's';
                }
                push @message, "$array - $count device$s down";
            }
        }
    }
    return $status, join('; ', @message);
};
1;
