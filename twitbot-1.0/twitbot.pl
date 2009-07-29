#!/usr/bin/perl
package TwitBot;
use strict;
use warnings;
use Net::Twitter;
use base qw( Bot::BasicBot::Pluggable );
use Data::Dump;
	#EDITAR ESTA INFORMACION
my $nick='apt';
my $twitUser='debian_ve';
my $twitPass='';
my $identiUser='debianvebot';
my $identiPass='';
my $servidorIRC='irc.debian.org';
#my $servidorIRC='irc.unplug.org.ve';
my $canalesIRC=[ '#debian-ve' ];
sub traducir
{
	my $comando=shift;
	my $estado=0;
	my $salida;
	foreach my $palabra (split (/\s/,$comando))
	{
		$estado=1 if ($palabra eq "is");
		if ($palabra eq "es" and $estado==0)
		{
			$palabra="is"; 
			$estado=1;
		}
		$salida.=$palabra." ";
	}
	return $salida;
}
sub topic
{
	my $self=shift;
	my $param=shift;
	if ($self->{topic} ne '' && $self->{topic} ne $param->{topic})
	{
		$self->{iden}->update('Topic !debianve:'.$param->{topic});
		$self->{twit}->update('Topic cambiado:'.$param->{topic});
		$self->say(body=>'Topic twitteado ', channel=>$param->{channel});
	}
	$self->{topic}=$param->{topic};	
		
}
sub said
{
	my $class=shift;
	my $twit=$class->{twit};
	my $iden=$class->{iden};
	my $param=$_[0];
	my $who=$param->{who};
	$param->{body}=traducir($param->{body});
	my @cmdwho=split(/\s/,$param->{body});
	if ($param->{body} =~ /\sis\s/)
	{ #FACTOID
		return "Sólo los usuarios autorizados pueden agregar un factoid" if (not $class->module("Auth")->authed($who)); 
	}
	my $response;
	my $destino="msg";
	if ( $cmdwho[0] eq "twitter")
	{
		my $pana=$twit->show_user($cmdwho[1]);
		if ($pana)
		{
			my $twitted=$pana->{'status'}->{'text'};
			if ($twitted)
			{
				$response="Twitter->\@$cmdwho[1]: $twitted";
			}
			else
			{
				$response="Twitter->\@$cmdwho[1] Esta restringido ...";
			}
		}else
		{
			$response="Twitter->\@$cmdwho[1] no existe ";
		}
	
	}elsif($cmdwho[0] eq 'identica')
	{
		my $pana=$iden->show_user($cmdwho[1]);
		if ($pana)
		{
			my $identicado=$pana->{'status'}->{'text'};
			if ($identicado)
			{
				$response="Identi.ca->\@$cmdwho[1]: $identicado";
			}
			else
			{
				$response="Identi.ca->\@$cmdwho[1] esta restringido ...";
			}
		}else
		{
			$response="Identi.ca->\@$cmdwho[1] no esta registrado.";
		}
	}	if (defined $response)
	{
		$who=$cmdwho[2] if (defined $cmdwho[2]);
		$class->say ('who'=>$who,channel=>'msg', body=>$who.$response);
	}else
	{
		my $self=$class->SUPER::said(@_);
	}
	return undef;

}
sub new
{
		my $class=shift;
		my $self=$class->SUPER::new(@_);
		
		$self->{twit}= Net::Twitter->new({username=>$twitUser,password=>$twitPass}) if ($twitUser);
		$self->{iden}= Net::Twitter->new({username=>$identiUser,password=>$identiPass,identica=>1}) if ($identiUser);
		$self->{topic}="";
		bless ($self,$class);
		return $self;
}
my $twitbot=TwitBot->new (server => $servidorIRC,
      channels => $canalesIRC,
      nick => $nick,
#		charset => "utf-8",
    );
	$twitbot->load('Infobot');
	$twitbot->load('Seen');
	$twitbot->load('Auth');
	$twitbot->module('Infobot')->set('user_require_question',0);
	$twitbot->module('Infobot')->set('user_passive_answer',1);
	$twitbot->module('Infobot')->set('user_unknown_responses','Uhh?|No tienes nada mejor que hacer?|No sé|No me importa|Deja de Molestar');
	$twitbot->run();

