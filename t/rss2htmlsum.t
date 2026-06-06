use strict;
use warnings;
use Test::More tests => 10;
use File::Temp qw(tempfile);

# Create an empty test RSS XML just to allow require to pass without parsing errors if it tries to open files from ARGV
my $empty_rss = <<'RSS';
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
  <channel>
    <title>Empty Feed</title>
    <link>http://example.com/</link>
    <description>An empty feed</description>
  </channel>
</rss>
RSS

my ($fh1, $file1) = tempfile();
print $fh1 $empty_rss;
close($fh1);

my ($fh2, $file2) = tempfile();
close($fh2);

# Mock @ARGV so that the script doesn't die when required
@ARGV = ($file1, $file2);

# Trap warnings to check if there are undef warnings
my @warnings;
$SIG{__WARN__} = sub { push @warnings, join(" ", @_) };

# Need to redirect STDOUT so print statements don't clutter test output
my $stdout_save;
open($stdout_save, '>&', STDOUT) or die "Can't dup STDOUT: $!";
open(STDOUT, '>', '/dev/null') or die "Can't redirect STDOUT: $!";

require_ok('./bin/rss2htmlsum.pl');

# Restore STDOUT
open(STDOUT, '>&', $stdout_save) or die "Can't restore STDOUT: $!";

# Redirect STDOUT for functions again
sub run_quietly {
    my $code = shift;
    open(my $saved_out, '>&', STDOUT) or die "Can't dup STDOUT: $!";
    open(STDOUT, '>', '/dev/null') or die "Can't redirect STDOUT: $!";
    my $res = eval { $code->() };
    my $err = $@;
    open(STDOUT, '>&', $saved_out) or die "Can't restore STDOUT: $!";
    die $err if $err;
    return $res;
}

# Test 1: Empty items array
my $rss_empty = { items => [] };
my ($outfh_empty, $outfile_empty) = tempfile();
@warnings = ();
eval { run_quietly(sub { print_html($rss_empty, $outfile_empty) }) };
is($@, '', 'print_html with empty items array did not throw an error');
is(scalar(@warnings), 0, 'print_html with empty items array did not produce warnings')
    or diag("Warnings: \n" . join("\n", @warnings));

# Test 2: Items array with a single item
my $rss_single = {
    items => [
        {
            title => 'Single Item',
            link => 'http://example.com/single',
            description => 'A single item',
            pubDate => 'Wed, 03 Sep 2008 06:58:00 +0000'
        }
    ]
};
my ($outfh_single, $outfile_single) = tempfile();
@warnings = ();
eval { run_quietly(sub { print_html($rss_single, $outfile_single) }) };
is($@, '', 'print_html with a single item did not throw an error');
is(scalar(@warnings), 0, 'print_html with a single item did not produce warnings')
    or diag("Warnings: \n" . join("\n", @warnings));

# Test 3: Output content check
open(my $in, '<', $outfile_single) or die "Can't open $outfile_single: $!";
my $content = do { local $/; <$in> };
close($in);

like($content, qr/A single item/i, 'Output contains the item description') or diag("Content: $content");

# Test 4: Items with undefined values
my $rss_undef_item = {
    items => [ undef, undef ]
};
my ($outfh_undef, $outfile_undef) = tempfile();
@warnings = ();
eval { run_quietly(sub { print_html($rss_undef_item, $outfile_undef) }) };
is($@, '', 'print_html with undef items array did not throw an error');
is(scalar(@warnings), 0, 'print_html with undef items did not produce warnings')
    or diag("Warnings: \n" . join("\n", @warnings));

# Test 5: Missing items key
my $rss_missing_items = {};
my ($outfh_missing, $outfile_missing) = tempfile();
@warnings = ();
eval { run_quietly(sub { print_html($rss_missing_items, $outfile_missing) }) };
is($@, '', 'print_html with missing items key did not throw an error');
is(scalar(@warnings), 0, 'print_html with missing items key did not produce warnings')
    or diag("Warnings: \n" . join("\n", @warnings));
