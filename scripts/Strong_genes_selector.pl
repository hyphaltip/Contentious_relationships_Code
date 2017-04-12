#!/usr/bin/perl
use strict;
use warnings;
use Statistics::Descriptive; ## make sure you have this module ##
my @infiles=glob "*_genewise_lnL.txt";
foreach my $infile (@infiles) {
 next unless $infile=~m/(?<node>\w+)_genewise_lnL.txt/i;
 my $node_name=$+{node};

 my %dk;
 my %abs_dk;
 open (IN, $infile) or die "Can't open the file $infile: $!";
   while (my $content=<IN>)  {
	chomp $content;
	my @elements=split(/\t+/,$content); 
	$dk{$elements[0]}=$elements[3]-$elements[5];
	$abs_dk{$elements[0]}= abs($elements[3]-$elements[5]);
   }
  close IN;

  my @abs_dks= values %abs_dk;
  my $stat = Statistics::Descriptive::Full->new();
	  $stat->add_data(\@abs_dks);
  my $q0 = $stat->quantile(0);
  my $q1 = $stat->quantile(1);
  my $q3 = $stat->quantile(3);
  my $q4 = $stat->quantile(4);
  my $whisker=($q3-$q1)*1.5;
  my $min = $stat->min();
  my $max  = $stat->max();


  ## biggest gene ##
  my @biggest_genes;
  foreach my $key (sort {$abs_dk{$b} <=> $abs_dk{$a}} keys %abs_dk) {
	  if ($abs_dk{$key}==$max) {push @biggest_genes, $key;}
  }
  my $biggest_genes_no=@biggest_genes;
  my $out="Strongest_genes.table";
  open (OUT,">>", $out) or die "Can't write the file $out: $!";
  print OUT "$node_name\t@biggest_genes\t$biggest_genes_no\n";
  close OUT;

  ## outlier genes##
  my $upper_extreme;
  my $lower_extreme;
  if ($q3+$whisker<$max) {$upper_extreme=$q3+$whisker;
  }else{$upper_extreme=$max;}
  if ($q1-$whisker>$min) {$lower_extreme=$q1-$whisker;
  }else{$lower_extreme=$min;}
  print "$node_name\t$upper_extreme\t$lower_extreme\n";
  my $sum_dk=0;
  my @upper_genes_excluded;
  my @lower_genes_excluded;
  foreach my $key (sort { $abs_dk{$b} <=> $abs_dk{$a}} keys %abs_dk) {
      if ($abs_dk{$key} > $upper_extreme) {push @upper_genes_excluded, $key;}
	  elsif ($abs_dk{$key} < $lower_extreme) {push @lower_genes_excluded, $key;}
	  elsif ($abs_dk{$key} >= $lower_extreme and $abs_dk{$key} <= $upper_extreme) {$sum_dk=$sum_dk+$dk{$key};}
  }
  my $upper_genes_excluded_no=@upper_genes_excluded;
  my $lower_genes_excluded_no=@lower_genes_excluded;
  my $output="Outlier_genes.table";
  open (OUTPUT,">>", $output) or die "Can't write the file $output: $!";
  print OUTPUT "$node_name\t@upper_genes_excluded\t$upper_genes_excluded_no\t@lower_genes_excluded\t$lower_genes_excluded_no\n";
  close OUTPUT;
}
