#!/usr/bin/perl
use strict;
use warnings;
my %site_gene;
my %relative_site_gene;
my $full_file="full_combine_orders.txt";
my $full_part="full.partition";
  open (MATCHIN, $full_file) or die "Can't open the file $full_file: $!";
  while (my $content=<MATCHIN>) { 
	chomp $content;
 	$content=~s/.*,\s+(.*)/$1/gi;
	$content=~s/-/ /;
    my @elements=split(/\s+/,$content);
    my $gene_name=$elements[0];
    my $gene_start=$elements[2];
    my $gene_end=$elements[3];
    my @gene_sites=($gene_start..$gene_end);
    foreach  my $gene_site( @gene_sites) { my $relative_site= $gene_site-$gene_start+1;$site_gene{$gene_site}=$gene_name;$relative_site_gene{$gene_site}=$gene_name."_$relative_site";}		 
  }
  close MATCHIN;

my %site_partition;
my %model;
  open (MATCHIN2, $full_part) or die "Can't open the file $full_part: $!";
   while (my $content2=<MATCHIN2>) { 
	chomp $content2;
	 next unless $content2=~m/(?<mod>.*),\s+(?<par>\w+)\s+=/gi;
	my $model_name=$+{mod};
    my $partition_name=$+{par};
	$content2=~s/,/ /gi;
	$content2=~s/\t/ /gi;
	 my @elements2=split(/\s+/,$content2);
	 foreach my $element2 (@elements2) {
		 next unless $element2=~m/(?<start>\d+)-(?<end>\d+)/gi;
	  my $partition_start=$+{start};
      my $partition_end=$+{end};
      my @partition_sites=($partition_start..$partition_end);
      foreach  my $partition_site( @partition_sites) { $site_partition{$partition_site}=$partition_name;$model{$partition_site}=$model_name;}		 
	 }
    }
  close MATCHIN2;

foreach my $key  (sort {$a <=> $b} keys %site_partition) {
	print "$key\t$site_partition{$key}\t$site_gene{$key}\t$relative_site_gene{$key}\n";
	 my $output= "Full_partitioning_site.list";
    open (OUTPUT,">>", $output) or die "Can't open the file $output: $!";
    print OUTPUT "$key\t$model{$key}\t$site_partition{$key}\t$relative_site_gene{$key}\n";
	close OUTPUT;
}







