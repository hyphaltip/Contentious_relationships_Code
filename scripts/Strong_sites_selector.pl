#!/usr/bin/perl
use strict;
use warnings;
use Statistics::Descriptive; ## make sure you have this module ##
use Array::Utils qw(:all); ## make sure you have this module ##
my $top_pct="1"; ## set percentage of top sites for each gene you want to exlcude ##
my @infiles=glob("*_sitelk_table.txt");
foreach my $infile (@infiles) {
  next unless $infile=~m/(?<branch>\w+)_Gene_(?<id>\w+)_sitelk_table.txt/gi;
  my $gene_name=$+{id};
  my $branch_name=$+{branch};

  print "$branch_name\t$gene_name\n";
  my %dk;
  my %abs_dk;
  my $total_dks=0;
  open (IN, $infile) or die "Can't open the file $infile: $!";
   while (my $content=<IN>)  {
	 chomp $content;
	 my @elements=split(/\t+/,$content); 
	 unless ($elements[2] eq "gene") {
	   $dk{$elements[2]}=$elements[5]-$elements[6];
	   $total_dks=$total_dks+($elements[5]-$elements[6]);
	   $abs_dk{$elements[2]}=abs ($elements[5]-$elements[6]);
	 }
  }
 close IN;

  ## biggest site ##
  my @abs_dks= values %abs_dk;
  my $stat = Statistics::Descriptive::Full->new();
    $stat->add_data(\@abs_dks);
  my $abs_dk_max=$stat->max();
  my @biggest_sites;
  foreach my $key (sort {$abs_dk{$b} <=> $abs_dk{$a}} keys %abs_dk) {
	  if ($abs_dk{$key}==$abs_dk_max) { push @biggest_sites,$key;}
  }
  my $biggest_sites_no=@biggest_sites;
  my $out="${branch_name}_strongest_site.table";
  open (OUT,">>", $out) or die "Can't write the file $out: $!";
  print OUT "$gene_name\t@biggest_sites\t$biggest_sites_no\n";
  close OUT;

  ## top sites ##
  my $site_no= keys %abs_dk;
  for (my $most_pct=1;$most_pct<=$top_pct;$most_pct+=1) {
	my $remain=$site_no*(100- $most_pct)/100+0.5;
    my $no_remain=int($remain);
	my $sum_dk=0;
	my $count=0;
	my @sites_inlcded;
    foreach my $key (sort { $abs_dk{$a} <=> $abs_dk{$b}} keys %abs_dk) {
		$count++;
		last if $count > $no_remain;
		$sum_dk=$sum_dk+$dk{$key};
		push @sites_inlcded, $key;
     }
	 my @all_sites=sort {$a cmp $b} keys %abs_dk;
	 my @sites_excluded = array_diff(@all_sites, @sites_inlcded);
	 my $sites_excluded_no=@sites_excluded;
     my $output= "${branch_name}_top${top_pct}pct_site.table";
     open (OUTPUT,">>", $output) or die "Can't write the file $output: $!";
	 print OUTPUT "$gene_name\t@sites_excluded\t$sites_excluded_no\n";
	 close OUTPUT;
   }


}
