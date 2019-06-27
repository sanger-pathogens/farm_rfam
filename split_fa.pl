#!/usr/bin/env perl

use strict;
use Getopt::Long;
use Bio::SeqIO;
use IO::File;

my( $num_seqs, 
    $num_res,
    $exact,
    $output,
    $overlap );

&GetOptions( "s=s" => \$num_seqs,
	     "r=s" => \$num_res,
	     "e"   => \$exact,
	     "o=s" => \$overlap,
	     "n=s"   => \$output );

my $fafile = shift;
my $fh = IO::File->new;
if( $fafile =~ /(\S+)\.gz$/ ) {
    $fh->open( "gunzip -c $fafile |" );
    $fafile = $1;
}
else {
    $fh->open( $fafile );
}

my $in  = Bio::SeqIO -> new( -fh => $fh, '-format' => 'Fasta' );

if( $fafile =~ /^.*\/(\S+)$/ ) {
    $fafile = $1;
}

if( not $fafile or ( not $output and (
    ( $num_seqs and $num_res ) or 
    ( not $num_seqs and not $num_res ) or
    ( $exact and not $num_res )))) {
    print STDERR<<EOF;
split_fa.pl: splits a fasta files into smaller fasta files
Usage: split_fa.pl -[s|r] <n> <fasta file>
          -s <n>   number of sequences per file
          -r <n>   number of residues per file (to nearest sequence)
	  -n       Give files sensible names
EOF
    exit(1);
}

$overlap = "0.0" unless $overlap;
my $filecount = 0;
my $out;
my $count = 999999999999999999999;
my $newfile;

while( my $seq = $in -> next_seq() ) {
    next unless $seq;
    my $filename;
    if( $exact ) {
	my $end   = $overlap;
#	$end = $seq->length if( $end > $seq->length );
	my $start = 1;
	while( $end < $seq->length() ) {
	    $filecount++;
	    $filename = "$output/$fafile".".".$filecount;
	    print "file name is $filename \n";
	    $out = Bio::SeqIO -> new( -file => ">$filename", '-format' => 'Fasta' );
	    $end += $num_res;
	    $end = $seq->length() if( $end > $seq->length() );
	    my $subseq = $seq->subseq( $start, $end );
	    my $newseq = new Bio::Seq;
	    $newseq -> display_id( $seq->id()."_$start-$end" );
	    $newseq -> seq( $subseq );
	    $out -> write_seq( $newseq );
	    $start += $num_res;
	}
    }	
    else {
	if( ($num_seqs and $count >= $num_seqs) or
	    ($num_res and $count >= $num_res) ) {
	    $filecount++;
	    $filename = "$output/$fafile".".".$filecount;
	    $out = Bio::SeqIO -> new( -file => ">$filename", '-format' => 'Fasta' );
	    $count = 0;
	}
	$out -> write_seq( $seq );
	$count ++                if $num_seqs;
	$count += $seq->length() if $num_res;
    }
}
