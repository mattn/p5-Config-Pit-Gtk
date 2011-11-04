package Config::Pit::Gtk;

use strict;
use Config::Pit qw();

use YAML::Syck;
use Path::Class;

our $VERSION = '0.01';

unless (grep /^Gtk2/, keys %INC) {
	require 'Gtk2.pm';
	Gtk2->init;
}

my $orig = Config::Pit->can('set');
*Config::Pit::set = sub {
	my ($name, %opts) = @_;
	my $result = {};
	local $YAML::Syck::ImplicitTyping = 1;
	local $YAML::Syck::SingleQuote    = 1;

	if ($opts{data}) {
		$result = $opts{data};
	} else {
		my $setting = $opts{config} || Config::Pit::get($name);

		my $dialog = Gtk2::Dialog->new(
			$name,
			undef,
			[qw/modal destroy-with-parent/],
			'gtk-ok'     => 'accept',
			'gtk-cancel' => 'reject',
		);
		my $tooltips = Gtk2::Tooltips->new;
		my $sgroup = Gtk2::SizeGroup->new('horizontal');
		for my $label_name (keys %{$setting}) {
			if (ref(\$setting->{$label_name}) eq 'SCALAR') {
				my $hbox = Gtk2::HBox->new;
				my $label = Gtk2::Label->new($label_name);
				$label->set_alignment(1.0, 0.5);
				$hbox->add($label);
				$sgroup->add_widget($label);
				my $input = Gtk2::Entry->new;
				if ($label_name =~ /passwd|password/) {
					$input->set_visibility(0);
				}
				$input->signal_connect('focus-out-event', sub {
					$setting->{$label_name} = $input->get_text();
					return 0;
				});
				$tooltips->set_tip($input, $setting->{$label_name});
				$hbox->add($input);
				$dialog->vbox->add($hbox);
			}
		}
		$tooltips->enable;
		$dialog->set_default_response('cancel');
		$dialog->show_all;
		my $response = $dialog->run;
		$dialog->destroy;

		if ($response ne 'accept') {
			$result = Config::Pit::get($name);
		} else {
			$result = $orig->($name, data => $setting);
		}
	}
	my $profile = Config::Pit::_load();
	$profile->{$name} = $result;
	YAML::Syck::DumpFile($Config::Pit::profile_file, $profile);
	return $result;
};

1
__END__

=head1 NAME

Config::Pit::Gtk - Gtk user interface for Config::Pit

=head1 SYNOPSIS

  use Config::Pit;
  use Config::Pit::Gtk;

  my $config = pit_get("example.com", require => {
    "username" => "your username on example",
    "password" => "your password on example"
  });

=head1 DESCRIPTION

Config::Pit is account setting management library. In normally, pit_get uses
$EDITOR to editing account information. This library provide GUI instead.

=head1 FUNCTIONS

=head1 AUTHOR

mattn E<lt>mattn.jp@gmail.com<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Config::Pit>

=cut
