#!/usr/bin/perl
use strict;
#use warnings;

my $tempfile = "/tmp/policy.$$";
my $reportfile = "/tmp/report.csv";
my $to_address = "jgopal\@ip-soft.net";

system ("bppllist -allpolicies -U > $tempfile" );
open my $POLICY,'<',"$tempfile" or die "cannot open file for reading";

my $debug =0 ;
my $reading_schedule=0;
my $reading_hw_os_cl;
my ($last_policy,$policy);
my $schedule_start = 0;
my $include_start = 0;
my $info_for;

print "Reading policy...\n";

foreach my $line (<$POLICY>) {

    if ( $reading_hw_os_cl) {
        if ( $line =~ m/^\s+(\S+)\s+(\S+)\s+(\S+)/) {
            my $hw_os_cl = join q{__},($1,$2,$3);
            push @{ $info_for->{$policy}->{'hw_os_cl'} },$hw_os_cl;
        }elsif ( $line =~ m/^(?:\s+)?$/ ) {
            $reading_hw_os_cl = 0;
        }
        next;
    }

    if ( $reading_schedule) {
        my $count = scalar @{ $info_for->{$policy}->{'schedule'} };
        $count--;
        if ($line =~ m/\s+Frequency:\s+(.+)$/ ) {
            $info_for->{$policy}->{'schedule'}->[$count]->{'frequency'} = $1;
        } elsif ( $line =~ m/^\s+\S+day\s+/ ) {
            $line =~ s/^\s+//;
            my ($startday,$starttime,$discard,$endday,$endtime) = split /\s+/,$line;
            my $sched = join q{__},($startday,$starttime,$endday,$endtime);
            push @{ $info_for->{$policy}->{'schedule'}->[$count]->{'days'} } ,$sched;
        } elsif ( $line =~ m/^\s+Retention Level:\s+(.+)$/ ) {
            $info_for->{$policy}->{'schedule'}->[$count]->{'retention'} = $1;
        } elsif ( $line =~ m/^(\s+)?$/ ) {
            $reading_schedule = 0;
            $schedule_start = 0;
        }
        next;
    }

    if ( $include_start) {
        if ( $line =~ m/^\s+(\S+.+)$/) {
            push @{ $info_for->{$policy}->{'include'} },$1;
        }elsif ( $line =~ m/^(\s+)?$/ ) {
            $include_start = 0;
        }

        next;
    }

    if ( $line =~ m/^---------*$/) {
        $schedule_start = 0;
    }

    if ( $line =~ m/^Policy\s+Name:\s+(.+)$/ ) {
        $policy = $1;
    }elsif ( $line =~ m/^\s+Policy\s+Type:\s+(.+)$/ ) {
        $info_for->{$policy}->{'type'} = $1;
    }elsif ( $line =~ m/^\s+Active:\s+(\S+)/ ) {
        $info_for->{$policy}->{'active'} = $1;
    }elsif ( $line =~ m/^\s+Residence:\s+(.+)$/ ) {
        next if $schedule_start;
        $info_for->{$policy}->{'residence'} = $1;
    }elsif ( $line =~ m/^\s+HW\/OS\/Client:\s+(.+)$/ ) {
        my ($hw,$os,$cl) = split /\s+/,$1,3;
        my $hw_os_cl = join q{__},($hw,$os,$cl);
        push @{ $info_for->{$policy}->{'hw_os_cl'} },$hw_os_cl;
        $reading_hw_os_cl = 1;
        next;
    }elsif ( $line =~ m/^\s+Include:\s+(.+)$/ ) {
        push @{ $info_for->{$policy}->{'include'} },$1;
        $include_start = 1;
    }elsif ( $line =~ m/^\s+Schedule:\s+(\S+)$/ ) {
        $schedule_start = 1;
        #unless ($1 eq 'Default-Application-Backup') {
            push @{ $info_for->{$policy}->{'schedule'} },{'name' => $1 };
            $reading_schedule=1;
            next;
        #}
    }


}

if ($debug) {
    use Data::Dumper;
    print Dumper (\$info_for);
}

open my $REPORT, '>',"$reportfile" or die "cannot open report.csv for writing";
my $sn = 1;
print {$REPORT} "SN,Name,Type,Active,Residence,HW,OS,CL,Include,Schedule\n";
print {$REPORT} ",,,,,,,,,Name,Freq,Retention,Startday,Starttime,Endday,Endtime,Window (Hr)\n";

foreach my $policy (sort keys %{$info_for}) {
    my @lines;
    print "$sn\t$policy\n";

    my $word = "$sn,$policy," ;
    # current Comma count: 2

    foreach my $counter (qw/type active residence/) {
        $word .= $info_for->{$policy}->{$counter} . " ," ;
    }
    # current Comma count: 5

    my $commas_req = 5;
    push @lines, "$word";
    my $counter = 0;


if ( defined $info_for->{$policy}->{'hw_os_cl'} ) {
    while (@{$info_for->{$policy}->{'hw_os_cl'}}) {
        my $hw_os_cl = shift @{$info_for->{$policy}->{'hw_os_cl'}} ;
        my $word  = (defined $lines[$counter]) ? $lines[$counter] : '';
        my $count = (defined $lines[$counter]) ? count_commas($word) : 0;
        while ( $count < $commas_req ) {
            $word .= ' ,';
            $count++;
        }

        $word .= join ( q{,},split ( q{__},$hw_os_cl )) ;

        $lines[$counter] = $word . " ,";
        $counter++;
    }
}

    $counter = 0;
    $commas_req = 8;
    while (@{ $info_for->{$policy}->{'include'} }) {
        my $include = shift @{ $info_for->{$policy}->{'include'} };
        my $word  = (defined $lines[$counter]) ? $lines[$counter] : '';
        my $count = (defined $lines[$counter]) ? count_commas($word) : 0;
        while ( $count < $commas_req ) {
            $word .= ' ,';
            $count++;
        }
        $word .= $include;
        $lines[$counter] = $word . " ,";
        $counter++;
    }

    # Print remaining schedules
    $counter = 0;
    $commas_req = 9;
if ( defined  $info_for->{$policy}->{'schedule'} ) {
    while (@{ $info_for->{$policy}->{'schedule'} }) {
        my $schedule = shift @{ $info_for->{$policy}->{'schedule'} };
        my $word  = (defined $lines[$counter]) ? $lines[$counter] : '';
        my $count = (defined $lines[$counter]) ? count_commas($word) : 0;
        while ( $count < $commas_req ) {
            $word .= ' ,';
            $count++;
        }
        $word .= $schedule->{'name'} . " ," . $schedule->{'frequency'} . " ," . $schedule->{'retention'} . " ,";
        $lines[$counter] = $word;

        my $days_commas_req = $commas_req+3;
    if ( defined $schedule->{'days'} ) {
        while ( @{$schedule->{'days'}} ) {
            my $day = shift @{$schedule->{'days'}};
            my ($sd,$st,$ed,$et) = split q{__},$day;
            my $window = get_time_diff($sd,$st,$ed,$et);

            my $word  = (defined $lines[$counter]) ? $lines[$counter] : '';
            my $count = (defined $lines[$counter]) ? count_commas($word) : 0;
            while ( $count < $days_commas_req ) {
                $word .= ' ,';
                $count++;
            }
            $word .= join q{,},($sd,$st,$ed,$et,$window);
            $lines[$counter] = $word . ' ,';
            $counter++;
        }
     }
}

    }
    foreach my $line (@lines) {
        print {$REPORT} "$line\n";
    }
    $sn++;
}

print "Total Policy count: $sn\n";
print "Report File Name: $reportfile\n";
#system ("uuencode $reportfile $reportfile | mailx -s 'All Policy Report' jgopal\@ip-soft.net");
unlink $tempfile;

sub count_commas {
    my $word = $_[0];
    return scalar split q{,},$word;
}

sub get_time_diff {
    my ($sd,$st,$ed,$et) = @_;
    my @days = qw/sunday monday tuesday wednesday thursday friday saturday/ ;
    my $pos = 0;
    foreach my $day (@days) {
        last if $day =~ m/$sd/i;
        $pos++;
    }
    my $start_index = $pos;
    $pos = 0;

    foreach my $day (@days) {
        last if $day =~ m/$ed/i;
        $pos++;
    }
    my $end_index = $pos;

    if ($end_index < $start_index) {
        $end_index += 7;
    }

    my ($shr,$smin,$ssec) = split /:/,$st;
    my ($ehr,$emin,$esec) = split /:/,$et;

    my $day_diff = $end_index - $start_index;

    $ehr = $ehr + ( $day_diff * 24 );

    my $time_diff = ( $ehr - $shr ) + ($emin - $smin )/60;
    return sprintf("%d",$time_diff);
}
#system('gzip -f "/tmp/report.csv"');
#my $ID="kchauras\@ipsoft.com";
#`/bin/mailx -a  /tmp/report.csv.gz  -s All $ID`
