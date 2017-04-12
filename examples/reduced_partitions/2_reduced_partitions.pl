#!/usr/bin/perl
use strict;
use warnings;
use List::MoreUtils qw(uniq); ## make sure you have this module##
use Set::IntSpan; ## make sure you have this module##
my @infiles=glob("*.reduced");
foreach my $infile (@infiles) {  print "$infile\n";
  next unless $infile=~m/(?<id>.*)_combine_orders.reduced/gi;
  my $name=$+{id};
  print "$name\n";

  my %site_partition;
  my %model;
  my $filename="Full_partitioning_site.list";
  open (MATCHIN, $filename) or die "Can't open the file $filename: $!";
  while (my $content=<MATCHIN>) { 
	chomp $content;
    my @elements=split(/\t+/,$content);
    my $partition_name=$elements[2];
    my $gene_site=$elements[3];
	$site_partition{$gene_site}=$partition_name;
	$model{$partition_name}=$elements[1];
    }
 close MATCHIN;



  my %site_assigned;
  open (IN, $infile) or die "Can't open the file $infile: $!";
   while (my $content=<IN>) { 
	chomp $content;
 	$content=~s/.*,\s+(.*)/$1/gi;
	$content=~s/-/ /;
	print "$content\n";
    my @elements=split(/\s+/,$content);
    my $gene_name=$elements[0];
    my $gene_start=$elements[2];
    my $gene_end=$elements[3];
    my @gene_sites=($gene_start..$gene_end);
    foreach  my $gene_site( @gene_sites) { 
		my $relative_site= $gene_site-$gene_start+1;
		my $gene_site_rela=$gene_name."_$relative_site";
		my $partition_info=$site_partition{$gene_site_rela};
	    if (exists $site_assigned{$partition_info}) {
			print "$name\t$gene_site_rela\t$partition_info\n";
			$site_assigned{$partition_info}=$site_assigned{$partition_info}.",$gene_site";
	    }else {$site_assigned{$partition_info}=$gene_site;}
      }
   }
  close IN;

  foreach my $key  (sort {$a cmp $b} keys %site_assigned) {
	  my  $set= Set::IntSpan->new($site_assigned{$key});
	 my $output= "${name}_reduced.partition";
    open (OUTPUT,">>", $output) or die "Can't open the file $output: $!";
    print OUTPUT "$model{$key}, $key = $set\n";
	close OUTPUT;
 }
}







