use ExtUtils::MakeMaker;
WriteMakefile(
	      'NAME'		=> 'Apache::Emulator::Constants',
	      'AUTHOR'          => 'Nigel Wetters <nwetters@cpan.org>',
	      'VERSION_FROM'	=> 'Constants.pm',
	      'PREREQ_PM'       => {
		  'Exporter' => undef
		  }
	      );
