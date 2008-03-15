#!/usr/bin/perl

use MIME::Parser;
use Switch;
use HTML::Parser;

my $parser = new MIME::Parser;

$parser->output_to_core(1);
$entity = $parser->parse(\*STDIN) or die "parse failed\n";

# create a hash of html tag names that may have links
my %link_attr = (
	'a' => {'href'},
	'applet' => {'archive','codebase','code'},
	'area' => {'href'},
	'blockquote' => {'cite'},
	#'body'    => {'background'},
	'embed'   => {'pluginspage', 'src'},
	'form'    => {'action'},
	'frame'   => {'src', 'longdesc'},
	'iframe'  => {'src', 'longdesc'},
	#'ilayer'  => {'background'},
	#'img' => {'src'},
	'input'   => {'src', 'usemap'},
	'ins'     => {'cite'},
	'isindex' => {'action'},
	'head'    => {'profile'},
	#'layer'   => {'background', 'src'},
	'layer'   => {'src'},
	'link'    => {'href'},
	'object'  => {'classid', 'codebase', 'data', 'archive', 'usemap'},
	'q'       => {'cite'},
	'script'  => {'src', 'for'},
	#'table'   => {'background'},
	#'td'      => {'background'},
	#'th'      => {'background'},
	#'tr'      => {'background'},
	'xmp'     => {'href'},
);

sub find_urls_rec
{
	my($ent) = @_;
	if ($ent->parts > 1) {
		for ($i=0;$i<$ent->parts;$i++) {
			find_urls_rec($ent->parts($i));
		}
	} else {
		#print "type: " . $ent->mime_type . "\n";
		switch ($ent->mime_type) {
			case "text/html" {
				my $parser = HTML::Parser->new(api_version=>3);
				$parser->handler(start => sub {
						my($tagname,$pos,$text) = @_;
						if (my $link_attr = $link_attr{$tagname}) {
							while (4 <= @$pos) {
								my($k_offset, $k_len, $v_offset, $v_len) = splice(@$pos,-4);
								my $attrname = lc(substr($text, $k_offset, $k_len));
								next unless exists($link_attr->{$attrname});
								next unless $v_offset; # 0 v_offset means no value
								my $v = substr($text, $v_offset, $v_len);
								$v =~ s/^([\'\"])(.*)\1$/$2/;
								print "link: $v\n";
							}
						}
					},
					"tagname, tokenpos, text");
				$parser->parse($ent->bodyhandle->as_string);
			}
			case qr/text\/.*/ {
				$ent->head->unfold;
				switch ($ent->head->get('Content-type')) {
					case qr/format=flowed/ {
						my @lines = $ent->bodyhandle->as_lines;
						chomp(@lines);
						if ($ent->head->get('Content-type') =~ /delsp=yes/) {
							#print "delsp=yes!\n";
							$delsp=1;
						} else {
							#print "delsp=no!\n";
							$delsp=0;
						}
						for ($i=0;$i<@lines;$i++) {
							my $col = 0;
							my $quotetext = "";
							while (substr($lines[$i],$col,1) eq ">") {
								$quotetext .= ">";
								$col++;
							}
							if ($col > 0) { print "$quotetext "; }
							while ($lines[$i] =~ / $/ && $lines[$i] =~ /^$quotetext[^>]/ && $lines[$i+1] =~ /^$quotetext[^>]/) {
								if ($delsp) {
									$line = substr($lines[$i],$col,length($lines[$i])-$col-1);
								} else {
									$line = substr($lines[$i],$col);
								}
								$line =~ s/ *(.*)/$1/;
								print $line;
								$i++;
							}
							if ($lines[$i] =~ /^$quotetext[^>]/) {
								$line = substr($lines[$i],$col);
								$line =~ s/ *(.*)/$1/;
								print $line."\n";
							}
						}
					}
					else {
						# urlview should be able to handle unflowed plain text
						$ent->bodyhandle->print(\*STDOUT);
					}
				}
			}
		}
	}
}

&find_urls_rec($entity);
