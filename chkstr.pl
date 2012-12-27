#!/usr/local/bin/perl
# Copyright (C)1995-2000 ASH multimedia lab. (http://ash.jp/)
#
# $BJ8;z%3!<%IH=Dj=hM}(B
#

sub chk1st {
    my ($buf, $len) = @_;

# $BJ8;z<oH=Dj=hM}(B
#   buf: $B%A%'%C%/%G!<%?3JG<%P%C%U%!(B
#   len: $B%A%'%C%/%G!<%?%5%$%:(B
# $BJV5QCM(B
#    0: ASCII
#    1: JIS
#    2: SJIS
#    3: EUC
#    4: Unknown(EUC/SJIS)
#   -1: Binary

    my $esc = 0; # $B:G=*%P%$%H$N>uBV(B
    my $rtn = 0; # $BJV5QCM(B
    my ($c, $i);

    for ($i = 0; $i < $len; $i++) {
        $c = ord(substr($buf, $i, 1));

        if ($esc == 0) { # ESC$B0J30(B
            if (($c >= 0x20) && ($c <= 0x7E)) {
                # ASCII
            } elsif (($c <= 0x06) || ($c == 0x7f) || ($c == 0xff)) {
                $rtn = -1; # Binary
                last;
            } elsif ($c == 0x1B) {
                $esc = 1; # ESC (1B)
                $rtn = 4; # Not ASCII
                next;
            } elsif (($c >= 0x07) && ($c <= 0x0d)) {
                # ctrl
            } elsif (($c >= 0x0e) && ($c <= 0x1F)) {
                $rtn = -1; # Binary
                last;
            } elsif ((($c >= 0x80) && ($c <= 0x8D))
                    || (($c >= 0x90) && ($c <= 0xA0))) {
                $rtn = 2; # SJIS
                last;
            } elsif ($c == 0xFE) {
                $rtn = 3; # EUC
                last;
            } else {
                $rtn = 4; # Not ASCII
            }

        } elsif ($esc == 1) { # ESC (1B)
            if ($c == 0x24) {
                $esc = 2; # ESC (1B 24)
            } elsif ($c == 0x28) {
                $esc = 3; # ESC (1B 28)
            } else {
                $esc = 0;
            }

        } elsif ($esc == 2) { # ESC (1B 24)
            $esc = 0;
            if (($c == 0x40) || ($c == 0x42)) {
                $rtn = 1; # JIS
                last;
            }

        } else { # ESC (1B 28)
            $esc = 0;
            if (($c == 0x42) || ($c == 0x49) || ($c == 0x4A)) {
                $rtn = 1; # JIS
                last;
            }
        }
    }

    if ($dbg) {printf("chk1st(buf, %d) rtn = %d\n", $len, $rtn);}

    return($rtn);
}


sub chkasc {
    my ($buf, $len) = @_;

# ASCII$B%3!<%IH=Dj=hM}(B
#   $buf: $B%A%'%C%/%G!<%?3JG<%P%C%U%!(B
#   $len: $B%A%'%C%/%G!<%?%5%$%:(B
# $BJV5QCM(B
#    0: OK
#   -1: NG

    my $rtn; # $BJV5QCM(B
    my ($c, $i);

    $rtn = 0;

    for ($i = 0; $i < $len; $i++) {
        $c = ord(substr($buf, $i, 1));

        if (($c >= 0x07) && ($c <= 0x0d)) {
            # ctrl
        } elsif (($c >= 0x20) && ($c <= 0x7E)) {
            # ASCII
        } else {
            $rtn = -1;
            last;
        }
    }

    if ($dbg) {printf("chkasc(buf, %d) rtn = %d\n", $len, $rtn);}

    return($rtn);
}


sub chkjis {
    my ($buf, $len) = @_;

# JIS$B%3!<%IH=Dj=hM}(B
#   $buf: $B%A%'%C%/%G!<%?3JG<%P%C%U%!(B
#   $len: $B%A%'%C%/%G!<%?%5%$%:(B
# $BJV5QCM(B
#   0000: ASCII
#   0001: JIS$B4A;z(B
#   0010: JIS$B%+%J(B
#   0100: JIS$B4A;z(B(NEC$B3HD%30;z(B)
#   1000: JIS$B4A;z(B($B5!<o0MB8(B)
#     -1: NG

    my $esc; # ESC$B$N>uBV(B
    my $stat; # $B:G=*%P%$%H$N>uBV(B
    my $kind; # $BJ8;z%3!<%I$N>uBV(B
    my $rtn; # $BJV5QCM(B
    my ($c, $i);

    $rtn = 0; # ASCII
    $esc = 0;
    $stat = 0;
    $kind = 0;

    for ($i = 0; $i < $len; $i++) {
        $c = ord(substr($buf, $i, 1));

        if ($esc == 0) { # ESC$B0J30(B
            if ($c == 0x1B) {
                $esc = 1; # ESC (1B)
                next;
            }

            if ($kind == 0) { # ASCII
                if (($c >= 0x07) && ($c <= 0x0d)) {
                    # ctrl
                } elsif (($c >= 0x20) && ($c <= 0x7E)) {
                    # ASCII
                } else {
                    $rtn = -1; # Not JIS
                    last;
                }
            } elsif ($kind == 1) { # JIS$B%+%J(B
                if (($c >= 0x21) && ($c <= 0x5F)) {
                    # JIS$B%+%J(B
                } else {
                    $rtn = -1; # Not JIS
                    last;
                }
            } else { # JIS$B4A;z(B
                if ($stat == 0) { # 1$B%P%$%HL\(B
                    $stat = 1;
                    if (($c >= 0x21) && ($c <= 0x7E)) {
                        if (($c == 0x2D) || (($c >= 0x79) && ($c <= 0x7C))) {
                            $rtn = $rtn | 4; # JIS$B4A;z(B(NEC$B3HD%30;z(B)
                        } elsif ((($c >= 0x29) && ($c <= 0x2F)) ||
                                   (($c >= 0x75) && ($c <= 0x7E))) {
                            $rtn = $rtn | 8; # JIS$B4A;z(B($B5!<o0MB8(B)
                        }
                    } else {
                        $rtn = -1; # Not JIS
                        last;
                    }
                } else { # 2$B%P%$%HL\(B
                    $stat = 0;
                    if (($c >= 0x21) && ($c <= 0x7E)) {
                        # JIS$B4A;z(B
                    } else {
                        $rtn = -1; # Not JIS
                        last;
                    }
                }
            }

        } elsif ($esc == 1) { # ESC (1B)
            if ($c == 0x24) {
                $esc = 2; # ESC (1B 24)
            } elsif ($c == 0x28) {
                $esc = 3; # ESC (1B 28)
            } else {
                $rtn = -1; # Not JIS
                last;
            }

        } elsif ($esc == 2) { # ESC (1B 24)
            $esc = 0;
            if (($c == 0x40) || ($c == 0x42)) {
                $kind = 2; # JIS$B4A;z(B
                $rtn = $rtn | 1; # JIS$B4A;z(B
            } else {
                $rtn = -1; # Not JIS
                last;
            }

        } else { # ESC (1B 28)
            $esc = 0;
            if (($c == 0x42) || ($c == 0x4A)) {
                $kind = 0; # JIS$B%m!<%^;z(B
            } elsif ($c == 0x49) {
                $kind = 1; # JIS$B%+%J(B
                $rtn = $rtn | 2; # JIS$B%+%J(B
            } else {
                $rtn = -1; # Not JIS
                last;
            }
        }
    }

    if ($dbg) {printf("chkjis(buf, %d) rtn = %02x\n", $len, $rtn);}

    return($rtn);
}


sub chksjis {
    my ($buf, $len) = @_;

# SJIS$B%3!<%IH=Dj=hM}(B
#   $buf: $B%A%'%C%/%G!<%?3JG<%P%C%U%!(B
#   $len: $B%A%'%C%/%G!<%?%5%$%:(B
# $BJV5QCM(B
#   0000: ASCII
#   0001: JIS$B4A;z(B
#   0010: JIS$B%+%J(B
#   0100: JIS$B4A;z(B(NEC$B3HD%30;z(B)
#   1000: JIS$B4A;z(B($B5!<o0MB8(B)
#     -1: NG

    my $stat; # $B:G=*%P%$%H$N>uBV(B
    my $rtn; # $BJV5QCM(B
    my ($c, $c1, $i);

    $rtn = 0; # ASCII
    $stat = 0;

    for ($i = 0; $i < $len; $i++) {
        $c = ord(substr($buf, $i, 1));

        if ($stat == 0) { # $BJ8;z$N(B1$B%P%$%HL\(B
            if (($c >= 0x07) && ($c <= 0x0d)) {
                # ctrl
            } elsif (($c >= 0x20) && ($c <= 0x7E)) {
                # ASCII
            } elsif (($c >= 0xA1) && ($c <= 0xDF)) {
                $rtn = $rtn | 2; # JIS$B%+%J(B
            } elsif (($c >= 0x81) && ($c <= 0x9F)) {
                $stat = 1; # JIS$B4A;z(B(81-9F)
                $c1 = $c;
                $rtn = $rtn | 1;
            } elsif (($c >= 0xE0) && ($c <= 0xEF)) {
                $stat = 2; # JIS$B4A;z(B(E0-EF)
                $c1 = $c;
                $rtn = $rtn | 1;
            } else {
                $rtn = -1; # Not SJIS
                last;
            }

        } elsif ($stat == 1) { # JIS$B4A;z(B(81-9F)$B$N(B2$B%P%$%HL\(B
            if ((($c >= 0x40) && ($c <= 0x7E)) ||
                (($c >= 0x80) && ($c <= 0xFC))) {
                $stat = 0;
                if (($c1 == 0x87) && ($c < 0x9E)) {
                    $rtn = $rtn | 4; # JIS$B4A;z(B(NEC$B3HD%30;z(B)
                } elsif (($c1 >= 0x85) && ($c1 <= 0x87)) {
                    $rtn = $rtn | 8; # JIS$B4A;z(B($B5!<o0MB8(B)
                } elsif (($c1 == 0x88) && ($c < 0x9E)) {
                    $rtn = $rtn | 8; # JIS$B4A;z(B($B5!<o0MB8(B)
                }
            } else {
                $rtn = -1; # Not SJIS
                last;
            }

        } else { # JIS$B4A;z(B(E0-EF)$B$N(B2$B%P%$%HL\(B
            if ((($c >= 0x40) && ($c <= 0x7E)) ||
                (($c >= 0x80) && ($c <= 0xFC))) {
                $stat = 0;
                if (($c1 >= 0xED) && ($c1 <= 0xEE)) {
                    $rtn = $rtn | 4; # JIS$B4A;z(B(NEC$B3HD%30;z(B)
                } elsif (($c1 >= 0xEB) && ($c1 <= 0xEF)) {
                    $rtn = $rtn | 8; # JIS$B4A;z(B($B5!<o0MB8(B)
                }
            } else {
                $rtn = -1; # Not SJIS
                last;
            }
        }
    }

    if ($dbg) {printf("chksjis(buf, %d) rtn = %02x\n", $len, $rtn);}

    return($rtn);
}


sub chkeuc {
    my ($buf, $len, $stat) = @_;

# EUC$B%3!<%IH=Dj=hM}(B
#   $buf:  $B%A%'%C%/%G!<%?3JG<%P%C%U%!(B
#   $len:  $B%A%'%C%/%G!<%?%5%$%:(B
#   $stat: $B:G=*%P%$%H$N>uBV(B
#     0: $BJ8;z$N:G8e(B
#     1: JIS$B%+%J$N(B1$B%P%$%HL\(B
#     2: JIS$B4A;z$N(B1$B%P%$%HL\(B
# $BJV5QCM(B
#   0000: ASCII
#   0001: JIS$B4A;z(B
#   0010: JIS$B%+%J(B
#   0100: JIS$B4A;z(B(NEC$B3HD%30;z(B)
#   1000: JIS$B4A;z(B($B5!<o0MB8(B)
#     -1: NG

    my $rtn; # $BJV5QCM(B
    my ($c, $i);

    $rtn = 0; # ASCII
    $stat = 0;

    for ($i = 0; $i < $len; $i++) {
        $c = ord(substr($buf, $i, 1));

        if ($stat == 0) { # $BJ8;z$N(B1$B%P%$%HL\(B
            if (($c >= 0x07) && ($c <= 0x0d)) {
                # ctrl
            } elsif (($c >= 0x20) && ($c <= 0x7E)) {
                # ASCII
            } elsif ($c == 0x8E) {
                $stat = 1; # JIS$B%+%J(B
                $rtn = $rtn | 2; # JIS$B%+%J(B
            } elsif (($c >= 0xA1) && ($c <= 0xFE)) {
                $stat = 2; # JIS$B4A;z(B
                $rtn = $rtn | 1; # JIS$B4A;z(B
                if (($c == 0xAD) || (($c >= 0xF9) && ($c <= 0xFC))) {
                    $rtn = $rtn | 4; # JIS$B4A;z(B(NEC$B3HD%30;z(B)
                } elsif ((($c >= 0xA9) && ($c <= 0xAF)) ||
                           (($c >= 0xF5) && ($c <= 0xFE))) {
                    $rtn = $rtn | 8; # JIS$B4A;z(B($B5!<o0MB8(B)
                }
            } else {
                $rtn = -1;
                last;
            }

        } elsif ($stat == 1) { # JIS$B%+%J$N(B2$B%P%$%HL\(B
            if (($c >= 0xA1) && ($c <= 0xFE)) {
                $stat = 0;
            } else {
                $rtn = -1;
                last;
            }

        } else { # JIS$B4A;z$N(B2$B%P%$%HL\(B
            if (($c >= 0xA1) && ($c <= 0xFE)) {
                $stat = 0;
            } else {
                $rtn = -1;
                last;
            }
        }
    }

    if ($dbg) {printf("chkeuc(buf, %d) rtn = %02x\n", $len, $rtn);}

    return($rtn);
}


sub getcode {
    my ($buf, $len) = @_;

# $BJ8;z%3!<%IH=Dj=hM}(B
#   $buf: $B%A%'%C%/%G!<%?3JG<%P%C%U%!(B
#   $len: $B%A%'%C%/%G!<%?%5%$%:(B
# $BJV5QCM(B
#    0: ASCII
#    1: JIS
#    2: SJIS
#    3: EUC
#    4: Unknown (SJIS/EUC)
#   -1: Binary

    my $rtn; # $BJV5QCM(B
    my ($rtn_sjis, $rtn_euc);
    my $c;

    $rtn = chk1st($buf, $len);
    if ($rtn != 4) {goto end;}

    $rtn_sjis = chksjis($buf, $len);
    $rtn_euc  = chkeuc($buf, $len);

    if ($rtn_sjis >= 0) {
        if ($rtn_euc >= 0) {
            $rtn = 4; # Unknown (SJIS/EUC)
            if (!($rtn_sjis & 1)) { # $B4A;z$J$7$N>l9g(B
                $rtn = 3; # EUC
            }
        } else {
            $rtn = 2; # SJIS
        }
    } else {
        if ($rtn_euc >= 0) {
            $rtn = 3; # EUC
        } else {
            $rtn = -1; # Binary
        }
    }
end:

    if ($dbg) {printf("getcode(buf, %d) rtn = %d\n", $len, $rtn);}

    return($rtn);
} 

1;
