#!/usr/bin/perl
package TwitBot;
use strict;
use warnings;
use Net::Twitter;
use base qw( Bot::BasicBot );

	#EDITAR ESTA INFORMACION
my $nick='twitica';
my $twitUser='';
my $twitPass='';
my $identiUser='';
my $identiPass='';
my $servidorIRC='';
my $canalesIRC=[ 'canal1','canal2' ];
sub said
{
	my $self=shift;
	my $param=shift;
	my $twit=$self->{twit};
	my $iden=$self->{iden};
	my @cmdwho=split (/\s/,$param->{body});
	if ( $cmdwho[0] eq "twit")
	{
		my $pana=$twit->show_user($cmdwho[1]);
		if ($pana)
		{
			my $twitted=$pana->{'status'}->{'text'};
			if ($twitted)
			{
				return "Twitter->\@$cmdwho[1]: $twitted";
			}
			else
			{
				return "Twitter->\@$cmdwho[1] Esta restringido ...";
			}
		}else
		{
			return "Twitter->\@$cmdwho[1] no existe ";
		}
	
	}elsif($cmdwho[0] eq '!identica')
	{
		my $pana=$iden->show_user($cmdwho[1]);
		if ($pana)
		{
			my $identicado=$pana->{'status'}->{'text'};
			if ($identicado)
			{
				return "Identi.ca->\@$cmdwho[1]: $identicado";
			}
			else
			{
				return "Identi.ca->\@$cmdwho[1] esta restringido ...";
			}
		}else
		{
			return "Identi.ca->\@$cmdwho[1] no esta registrado.";
		}
			
		

	}else
	{
		return undef;
	}
	print "cmd ".$cmdwho[0]." who ".$cmdwho[1]." nick $nick \n";

}
sub new
{
		my $class=shift;
		my $self=$class->SUPER::new(@_);
		
		$self->{twit}= Net::Twitter->new({username=>$twitUser,password=>$twitPass}) if ($twitUser);
		$self->{iden}= Net::Twitter->new({username=>$identiUser,password=>$identiPass,identica=>1}) if ($identiUser);
		$self->{status}="";
		bless ($self,$class);
		return $self;
}
TwitBot->new (server => $servidorIRC,
      channels => $canalesIRC,
      nick => $nick,
#		charset => "utf-8",
    )->run();

