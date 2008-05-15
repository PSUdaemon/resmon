package Resmon::Module::NETSTAT;
use Resmon::ExtComm qw/cache_command/;
use vars qw/@ISA/;
@ISA = qw/Resmon::Module/;

sub handler {
  my $arg = shift;
  my $os = $arg->fresh_status();
  return $os if $os;
  my $output = cache_command("netstat -an", 30);
  my @lines = split(/\n/, $output);
  @lines = grep(/\s$arg->{state}\s*$/, @lines) if($arg->{state});
  @lines = grep(/^$arg->{localip}/, @lines) if($arg->{localip});
  @lines = grep(/^\s*[\w\d\*\.]+.*[\.\:]+$arg->{localport}/, @lines) if($arg->{localport});
  @lines = grep(/[\d\*\.]+\d+\s+$arg->{remoteip}/, @lines)
	if($arg->{remoteip});
  @lines = grep(/[\d\*\.]+\s+[\d\*\.]+[\.\:]+$arg->{remoteport}\s+/, @lines)
	if($arg->{remoteport});
  my $count = scalar(@lines);
  return $arg->set_status("BAD($count)")
	if($arg->{limit} && ($count > $arg->{limit}));
  return $arg->set_status("BAD($count)")
	if($arg->{atleast} && ($count < $arg->{atleast}));
  return $arg->set_status("OK($count)");
}
1;
