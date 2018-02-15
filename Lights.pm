package Hue::Lights;

# Load Modules
use strict;
use LWP;
use JSON;
use Data::Dumper;
use Hue::Light;

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

	return $self;
}

sub find {
	my $self = shift;
	my $parameters = shift;
	my $response = $ua->get("$endpoint/$key/lights");
	if ($response->is_success) {
		my $object = $json->decode($response->decoded_content);
		my @lights;
		foreach my $id (sort keys %{$object}) {
			my $light = Hue::Light->new($endpoint,$key,$id);
			$light->load();
			if ($parameters->{name} && $parameters->{name} ne $light->name) {
				next;
			}
			if ($parameters->{uniqueid} && $parameters->{uniqueid} ne $light->uniqueid) {
				next;
			}
			push(@lights,$light);
		}
		return @lights;
	}
	else {
		$self->{_error} = "Error loading info: ". $response->status_line."\n";
	}
}

sub error {
	my $self = shift;
	return $self->{_error};
}
