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

sub on {
	my $self = shift;

	my $body = '{"on": true}';
	my $response = $ua->put("$endpoint/$key/lights/".$self->{id}."/state",Content => $body);
	if ($response->is_success) {
		print $response->decoded_content;
	}
	else {
		die $response->status_line;
	}
}

sub reachable {
	my $self = shift;
	if ($self->{_state}->{reachable} =~ /true/) {
		return 1;
	}
	return 0;
}

sub off {
	my $self = shift;

	my $body = '{"on": false}';
	my $response = $ua->put("$endpoint/$key/lights/".$self->{id}."/state",Content => $body);
	if ($response->is_success) {
		print $response->decoded_content;
	}
	else {
		die $response->status_line;
	}
}