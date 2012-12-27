#!/usr/local/bin/perl
# Copyright (C)1995-2000 ASH multimedia lab. (http://ash.jp/)
#
# $BJ8;z%3!<%I%A%'%C%/%3%^%s%I(B
#

require "chkstr.pl";

$prog_name = '';
$dbg = 0;

&main(); # $B%a%$%s=hM}(B

# $B;HMQJ}K!$NI=<((B
sub usage() {
    printf("Usage: %s [option] files\n", $prog_name);
    printf("  options: $B%*%W%7%g%s(B\n");
    printf("    -a: ASCII$B%3!<%I$H$7$F%A%'%C%/(B\n");
    printf("    -j: JIS$B%3!<%I$H$7$F%A%'%C%/(B\n");
    printf("    -s: ShiftJIS$B%3!<%I$H$7$F%A%'%C%/(B\n");
    printf("    -e: EUC$B%3!<%I$H$7$F%A%'%C%/(B\n");
    printf("    -d: $B5!<o0MB8J8;z%A%'%C%/(B\n");
    printf("  files: $B%A%'%C%/%U%!%$%kL>(B\n");
    exit(-1);
}

# $B%a%$%s=hM}(B
sub main {
    local $file_open;
    my ($mode, $code, $rtn);
    my ($file, $fp, @opt_data);

    # $B%G%U%)%k%H%Q%i%a!<%?$N@_Dj(B
    $prog_name = $0;
    $mode = 0; # $B5!<o0MB8%A%'%C%/%b!<%I(B
    $code = 3; # EUC

    # $B%*%W%7%g%s$N2r@O(B
    while ($#ARGV >= 0) {
        if ($ARGV[0] eq "-x") { # $B%G%P%C%0>pJsI=<((B
            $dbg = 1;
        } elsif ($ARGV[0] eq '-a') { # ascii code
            $code = 0;
        } elsif ($ARGV[0] eq '-j') { # jis code
            $code = 1;
        } elsif ($ARGV[0] eq '-s') { # sjis code
            $code = 2;
        } elsif ($ARGV[0] eq '-e') { # euc code
            $code = 3;
        } elsif ($ARGV[0] eq '-d') { # depend check mode
            $mode = 1;
        } elsif ($ARGV[0] eq '-x') { # debug mode
            $code = 3;
        } elsif ($ARGV[0] =~ /^-/) { # $B;HMQJ}K!$NI=<((B
            &usage();
        } else {
            last;
        }
        shift(@ARGV);
    }
    @opt_data = @ARGV;

    # $BF~NO%U%!%$%k$N%*!<%W%s(B
    if (@opt_data) {
        foreach $file (@opt_data) {
            if (-d $file) {next;}

            printf ("%s:", $file);
            $file_open = "<$file";
            if (!open(FILE_IN, $file_open)) {
                printf("File open error.\n");
                next;
            }
            printf ("\n");
            &_chkcode($mode, $code, FILE_IN);
            close(FILE_IN);
        }

    } else { # $B;XDj$J$7$N>l9g!"I8=`F~NO(B
        &_chkcode($mode, $code, STDIN);
    }
}

sub _chkcode {
    my ($mode, $code, $fp) = @_;
    my ($buf, $rtn, $len, $line);

    for ($line = 1; $buf = <$fp>; $line++) {
        chomp($buf);
        $len = length($buf);

        if ($code == 0) {
            $rtn = chkasc($buf, $len);
        } elsif ($code == 1) {
            $rtn = chkjis($buf, $len);
        } elsif ($code == 2) {
            $rtn = chksjis($buf, $len);
        } else {
            $rtn = chkeuc($buf, $len);
        }

        if ($rtn < 0) {
            printf("%08d: $BIT@5J8;z(B exists. (%d)\n", $line, $rtn);
            printf("%s\n", $buf);
        } elsif ($mode == 1) { # $B5!<o0MB8%A%'%C%/(B
            if ($rtn & 8) {
                printf("%08d: $B5!<o0MB8J8;z(B exists. (%d)\n", $line, $rtn);
                printf("%s\n", $buf);
            } elsif ($rtn & 4) {
                printf("%08d: NEC$B3HD%30;z(B exists. (%d)\n", $line, $rtn);
                printf("%s\n", $buf);
            }
        }
    }
}
