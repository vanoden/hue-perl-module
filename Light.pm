package Hue::Light;

# Load Modules
use strict;
use LWP;
use JSON;
use Data::Dumper;

my $ua = LWP::UserAgent->new();
my $endpoint;
my $key;

my $json = JSON->new();

sub new {
	my $package = shift;
	$endpoint = shift;
	$key = shift;

	my $self = { };
	bless $self, $package;

	$self->{id} = shift;

	return $self;
}

sub load {
	my $self = shift;
	my $response = $ua->get("$endpoint/$key/lights/".$self->{id});
	if ($response->is_success) {
		my $object = $json->decode($response->decoded_content);
		if ($object->{error} =~ /^HASH/) {
			$self->{_error} = "Error: ".$object->[0]->{error}->{description};
			return undef;
		}
		$self->{_name} = $object->{name};
		$self->{_swupdate} = $object->{swupdate};
		$self->{_uniqueid} = $object->{uniqueid};
		$self->{_state} = $object->{state};
		$self->{_modelid} = $object->{modelid};
		$self->{_swconfigid} = $object->{swconfigid};
		$self->{_manufacturername} = $object->{manufacturername};
		$self->{_type} = $object->{type};
		$self->{_productid} = $object->{productid};
		$self->{_swversion} = $object->{swversion};
	}
	else {
		$self->{_error} = "Error loading info: ". $response->status_line."\n";
	}
}

sub hash {
	my $self = shift;
	my %hash = (
		name		=> $self->{_name},
		uniqueid	=> $self->{_uniqueid},
		reachable	=> $self->reachable,
		brightness	=> $self->{_state}->{bri},
		saturation	=> $self->{_state}->{sat},
		colormode	=> $self->{_state}->{colormode}
	);
	if ($self->{_state}->{on} =~ /true/) {
		$hash{on} = 1;
	}
	else {
		$hash{on} = 0;
	}
	return %hash;
}

sub swupdate {
	my $self = shift;
	return $self->{_swupdate};
}

sub uniqueid {
	my $self = shift;
	return $self->{_uniqueid};
}

sub name {
	my $self = shift;
	return $self->{_name};
}

sub state {
	my $self = shift;
	print Dumper $self->{_state};
	return $self->{_state};
}

sub switch {
	my $self = shift;
	my $state = shift;

	my $body;
	if ($state =~ /^on$/i) {
		$body = '{"on": true}';
	}
	elsif ($state =~ /^off$/i) {
		$body = '{"on": false}';
	}
	else {
		$self->{_error} = "Invalid state";
		return 0;
	}
	my $response = $ua->put("$endpoint/$key/lights/".$self->{id}."/state",Content => $body);
	if ($response->is_success) {
		return 1;
	}
	else {
		$self->{_error} = $response->status_line;
		return 0;
	}
}

sub color {
	my $self = shift;
	my $color = shift;

	my $body;
	$body = '{"xy":[0.675,0.322]}';
	my $response = $ua->put("$endpoint/$key/lights/".$self->{id}."/state",Content => $body);
	if ($response->is_success) {
		return 1;
	}
	else {
		$self->{_error} = $response->status_line;
		return 0;
	}
}

sub on {
	my $self = shift;
	if ($self->{_state}->{on} =~ /true/) {
		return 1;
	}
	else {
		return 0;
	}
}

sub reachable {
	my $self = shift;
	if ($self->{_state}->{reachable} =~ /true/) {
		return 1;
	}
	return 0;
}

sub error {
	my $self = shift;
	return $self->{_error};
}
