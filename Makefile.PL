use ExtUtils::MakeMaker;
WriteMakefile(
    'NAME'      => 'Config::Pit::Gtk',
    'VERSION_FROM' => 'lib/Config/Pit/Gtk.pm', # finds $VERSION
    'PREREQ_PM' => {
		Config::Pit => 0.04,
		Gtk2 => 1.223,
    },
);
