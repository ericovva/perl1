package Local::JSONParser;
use Data::Printer;
use strict;
use warnings;
use base qw(Exporter);
our @EXPORT_OK = qw( parse_json );
our @EXPORT = qw( parse_json );
no warnings 'experimental';
sub parse_json {
    my $source = shift;
    
    use JSON::XS; use utf8;
    use Encode qw(encode decode);
    #return JSON::XS->new->utf8->decode($source);
    my @ref_arr;
    my @state;
    my @keys;
    my $balance = 0;
    $_ = $source;
    
    while (/(\s*)/gc) {
        if (/\G(\[)/gc){
            $balance++;
            ##print "$1\n";
            my @new_arr;
            push (@ref_arr,\@new_arr);
            push(@state,"ar");
            
        }
        if (/\G(\{)/gc){
            $balance++;
            ##print "$1\n";
            my %new_hash;
            push (@ref_arr,\%new_hash);
            push(@state,"hash");
        }
        
        if (/\G("[^"]+"\s*:)/gc) {
            my $ys = $1;
            $ys =~ s{\s}{}g;
            $ys =~ s{[":]}{}g;
            ##print "$ys 1\n";
            push (@keys,$ys);
        }
        elsif (/\G(true)/gc || /\G(null)/gc || /\G(false)/gc){
            my $tmp = $1;
            if ($state[$#state] eq "hash"){
                ${$ref_arr[$#ref_arr]}{$keys[$#keys]} = $tmp;
                pop (@keys);
            }
            elsif ($state[$#state] eq "ar"){
                push(@{$ref_arr[$#ref_arr]},$tmp);
            }
        }
        elsif (m{\G("(?:\\"|[^"])*")}gc){
            ##print "$1 2\n";
            my $tmp = $1;
            chop($tmp);
            $tmp = reverse($tmp);
            chop($tmp);
            $tmp = reverse($tmp);
            $tmp =~ s{\\"}{"}g;
            $tmp =~ s{\\t}{\t}g;
            #$tmp =~ s{\\u(\d+)}{$1}g;
            $tmp =~ s{\\u(\d+)}{  chr(hex($1)) }ge;
            if ($state[$#state] eq "hash"){
                ${$ref_arr[$#ref_arr]}{$keys[$#keys]} = $tmp;
                pop (@keys);
            }
            elsif ($state[$#state] eq "ar"){
                push(@{$ref_arr[$#ref_arr]},$tmp);
            }    
        }
        elsif (m{\G(["])([^\1]*)\1\]}gc){
            ##print "$2 3\n";
            my $tmp = $2;
            $tmp =~ s{\\"}{"}g;
            $tmp =~ s{\\t}{\t}g;
            if ($state[$#state] eq "ar"){
                push(@{$ref_arr[$#ref_arr]},$tmp);
            }
            if ($state[$#state] ne "ar") { die "ne ok"; }
            pop (@state);
            $balance--;
            if ($#ref_arr>0){#p @ref_arr;
                if ($state[$#state] eq "hash"){
                    ${$ref_arr[$#ref_arr - 1]}{$keys[$#keys]} = $ref_arr[$#ref_arr];
                    pop (@keys);
                }
                elsif ($state[$#state] eq "ar"){
                    push(@{$ref_arr[$#ref_arr - 1]},$ref_arr[$#ref_arr]);
                }
                pop (@ref_arr);
            }
        }
        elsif (m{\G(["])([^\1]*)\1\s}gc){
            ##print "$2 4\n";
            my $tmp = $2;
            $tmp =~ s{\\"}{"}g;
            $tmp =~ s{\\t}{\t}g;
            if ($state[$#state] eq "hash"){
                ${$ref_arr[$#ref_arr]}{$keys[$#keys]} = $tmp;
                pop (@keys);
            }
            elsif ($state[$#state] eq "ar"){
                push(@{$ref_arr[$#ref_arr]},$tmp);
            }
        }
        if (/\G(-?\d+.?\d*)/gc){
            ##print "$1\n";
            if ($state[$#state] eq "hash"){
                ${$ref_arr[$#ref_arr]}{$keys[$#keys]} = $1 + 0;
                pop (@keys);
            }
            elsif ($state[$#state] eq "ar"){
                push(@{$ref_arr[$#ref_arr]},$1 + 0);
            }
        }
        if (/\G(\])/gc){
            $balance--;
            if ($state[$#state] ne "ar") { die "ne ok"; }
                pop(@state);
                if ($#ref_arr>0){#p @ref_arr;
                    if ($state[$#state] eq "hash"){
                        ${$ref_arr[$#ref_arr - 1]}{$keys[$#keys]} = $ref_arr[$#ref_arr];
                        pop (@keys);
                    }
                    elsif ($state[$#state] eq "ar"){
                        push(@{$ref_arr[$#ref_arr - 1]},$ref_arr[$#ref_arr]);
                    }
                    pop (@ref_arr);
                }
                #print "$1\n";                    
        }
        if (/\G(\})/gc){
            $balance--;
            if ($state[$#state] ne "hash") { die "ne ok"; }
            pop(@state);
            if ($#ref_arr>0){
                #p @ref_arr;
                if ($state[$#state] eq "hash"){
                    ${$ref_arr[$#ref_arr - 1]}{$keys[$#keys]} = $ref_arr[$#ref_arr];
                    pop (@keys);
                }
                elsif ($state[$#state] eq "ar"){
                    push(@{$ref_arr[$#ref_arr - 1]},$ref_arr[$#ref_arr]);
                }
                pop (@ref_arr);
            } 
            #print "$1\n";            
        }  
    }
    #print "$source\n";
    if (!$balance) {return $ref_arr[0];}
    else {die "No balance"};
}
            
1;
