#!/usr/bin/perl
use strict;
use warnings;
use Bio::SeqIO; ## make sure you have this bioperl module ##
my @filenames = glob("*_site.table");
foreach my $filename (@filenames) {
	next unless $filename=~m/(?<id>\w+)_(?<excl>strongest|top1pct)_site.table/gi;
	my $name=$+{id};
	my $excl_name=$+{excl};
    open (IN,$filename) or die "can't open the file $filename: $!";
	 while (my $content=<IN>) {
		 chomp $content;
		 my @items=split(/\t+/,$content);
		 my $gene_id=$items[0];
		 my @sites_excluded=split(/\s+/,$items[1]);

		 my %seqs;
		 my $in = Bio::SeqIO->new(-file => "$gene_id.fasta" ,-format => 'fasta');
		 while( my $seq = $in->next_seq ) {
				my $id=$seq->display_id;
				my $string=$seq->seq;
				my $string_len=length $string;
				for (my $site=1; $site <= $string_len; $site+=1) {
					my $rela_site=$site-1;
					print "${name}\t$rela_site\n";
					unless (@sites_excluded~~/\b$site\b/) {
                      $seqs{$id} .= substr ($string, $rela_site, 1); # append the seqdata
					}
			    }
          }

	   foreach my $key (keys %seqs) {
		   if ($seqs{$key}=~m/[SFTNKYEVQMCAWPHDXRILG]/i) {
           my $outputs= "${name}_Gene_${gene_id}_${excl_name}_excluded.fas";
           open (OUTPUT,">>", $outputs) or die "Can't write the file $outputs: $!";
           print OUTPUT ">$key\n$seqs{$key}\n";
		   close OUTPUT;
		   }
	   }
     }
     close IN;
}	