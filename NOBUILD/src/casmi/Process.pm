#!/usr/bin/perl -w  
#############################################
## Package Process                         ##
#############################################
package Process;

use strict;
use warnings;

sub new { bless {}; } # Konstruktor

#######################################
## $ret = $proc_obj -> start("prg");    Shell Process im Hintergrund starten
## $ret = $proc_obj -> start (\&func);  Funktion im Hintergrund starten
sub start {

  my ($self, $func) = @_;

  $SIG{'CHLD'} = sub {wait} ;  # no zombies
  $self -> {'pid'} = fork ();  # subprocess mit fork erzeugen
  if (!defined $self->{'pid'}) {
    return 0;
  } elsif ($self -> {'pid'} == 0) {
      if (ref($func) eq "CODE") {
	  &$func; exit 0;          # subroutine starten
      } else {
	  exec "$func";            # shell process starten
      }
  } else {                     # parent process OK zurueckgeben
    return 1;
    }
} # end of sub start

###########################################################
# $ret = $proc_obj-> poll();   Prozessstatus abfragen: 
#                              1: laeuft, 0 laeuft nicht
###########################################################
  
sub poll {
  my $self = shift;

  exists $self->{'pid'} &&      # pid initialisiert und
    kill (0, $self->{'pid'});    #  ... Prozess reagiert
}

###########################################################
# $ret = $proc_obj->kill([SIGXXX]); Signal an Prozess schicken,
#                                   Default Parameter: SIGTERM
###########################################################

sub kill {
  my ($self, $sig) = @_;

  $sig = 'SIGTERM' unless defined $sig;     # falls ohne Parameter -> SIGTERM

  return 0 if !exists $self->{'pid'};       # Prozess initalisiert?

  kill ($sig, $self->{'pid'}) or return 0;  # Signal senden

  delete $self->{'pid'};                    # Prozess Variable loeschen

  1;                                        # OK
}    

1;
