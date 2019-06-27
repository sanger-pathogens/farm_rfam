params.query = "/home/vagrant/dev/uli/test_sample.fasta"
params.chunk_size = '8000'
params.chunk_overlap = '50'
params.blastdb = "/data/rfam/11/Rfam.fasta" 
params.cm = "/data/rfam/11/Rfam.cm"
params.output = "/home/vagrant/dev/uli/results"

Channel
    .fromPath(params.query)
    .set { query }

process split_fasta {
    memory { 1.GB }
    time { 10.min }
    errorStrategy {'terminate'} 

    input:
      file 'query.fa' from query
    output:
      file 'query.fa.*' into rfam_query_chunks mode flatten

    """
    split_fa.pl -r $params.chunk_size -e -o $params.chunk_overlap -n . query.fa
    """
}



process rfam_scan {

    memory { 3.GB * task.attempt }
    time { 15.min * task.attempt }
    errorStrategy { 'retry' }
    maxRetries 3


    input:
       file query from rfam_query_chunks

    output:
       file 'output' into rfam_scan_outputs
    

    """
    rfam_scan.pl -v -blastdb $params.blastdb -o output $params.cm ${query} 
    """
}

process merge_rfam_result {

   label 'always_local'

   input:
      file rfam_annotations_unclean_unsorted_chunked from rfam_scan_outputs.collectFile(name: 'rfam_annotations_unclean_unsorted_chunked.txt')

   output:
      file 'rfam_annotations_clean_sorted_chunked.txt' into rfam_merged_outputs

   """
   grep -v "^#" $rfam_annotations_unclean_unsorted_chunked | sort > rfam_annotations_clean_sorted_chunked.txt
   """
}

process dechunk_rfam_result {
   publishDir "$params.output", mode: 'copy', overwrite: false
   label 'always_local'

   input:
      file 'rfam_annotations_clean_sorted_chunked.txt' from rfam_merged_outputs
   output:
      file 'rfam_annotations.txt' into rfam_annotations

   '''
   #!/usr/bin/env perl

   #Beware, this perl code is not exactly Perl, but a groovy string containing perl code
   #Thus each slash was replaced by a double slash, ie tab is \\t

   use strict;
   use warnings;

   my $infile = 'rfam_annotations_clean_sorted_chunked.txt';
   my $outfile = 'rfam_annotations.txt';
   open(IN, "$infile");
   open(OUT, ">$outfile");
   while(<IN>)
   {
       my @fields = split(/\\t/, $_);
       my @names = split(/\\_/, $fields[0]);
       my $coords = $names[$#names];
       my @xy = split(/\\-/, $coords);
       my $add = $xy[0] - 1;
       $fields[0] =~ s/_$coords$//;
       $fields[3] += $add;
       $fields[4] += $add;
       for my $x(0..$#fields)
       {
          print OUT "$fields[$x]";
          if($x < $#fields)
          {
              print OUT "\\t";
          }
       }
   }
   close(IN);
   close(OUT);
   '''
}
