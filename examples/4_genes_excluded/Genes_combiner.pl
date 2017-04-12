#!/usr/bin/perl
use strict;
use Bio::SeqIO; ## make sure you have this bioperl module ##
use Bio::AlignIO; ## make sure you have this bioperl module ##
my @tables = glob("*.table");
foreach my $table (@tables) {
 next unless $table=~m/(?<id>\w+)_genes.table/gi;
 my $excl_name=$+{id};
 open (IN, $table) or die "Can't open the file $table: $!";
 while (my $content=<IN>)  {
	 chomp $content;
	my @items=split(/\t+/,$content); 
	my $branch_id=$items[0];
    my %genes_excluded;
    foreach my $gene_excluded (split(/\s+/,$items[1])) {$genes_excluded{$gene_excluded}=$gene_excluded;}

	my %seqs;
    my $j=0;
    my @files = glob("*.fasta");
    foreach my $file (@files) {
       next unless $file=~m/(?<gene>\w+).fasta/gi;
	   my $gene_name=$+{gene};
       unless (exists $genes_excluded{$gene_name}) {
          my $alnin = Bio::AlignIO->new(-file => "$file" ,-format => 'fasta');
          while ( my $aln = $alnin->next_aln) {
            my $alnlength=$aln->length;
            my $i=$j+1;
            $j=$j+$alnlength;
            print "${excl_name}\t $gene_name = $i-$j\n";
            my $outputs= "${branch_id}_${excl_name}_excluded_combining_order.txt";
            open (OUTPUT,">>", $outputs) or die "Can't open the file $outputs: $!";
            print OUTPUT "aln, $gene_name = $i-$j\n";
            close OUTPUT;
           }
           my $in = Bio::SeqIO->new(-format => 'fasta', -file => $file);
           while( my $seq = $in->next_seq ) {$seqs{$seq->display_id} .= $seq->seq; }# append the seqdata
	    }
     }

     foreach my $key (keys %seqs) {
       my $outputs= "${branch_id}_${excl_name}_excluded.fas";
       open (OUTPUT,">>", $outputs) or die "Can't write the file $outputs: $!";
       print OUTPUT ">$key\n$seqs{$key}\n";
	   close OUTPUT;
	 }
  
 }
  close IN;
}
