use ExtUtils::MakeMaker;
WriteMakefile(
	      'NAME'		=> 'Apache::Emulator',
	      'AUTHOR'          => 'Nigel Wetters <nwetters@cpan.org>',
	      'VERSION_FROM'	=> 'Emulator.pm',
	      'PREREQ_PM'       => {
		  'HTTP::Status' => undef
		  }
	      );
