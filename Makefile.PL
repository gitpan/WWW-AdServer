use ExtUtils::MakeMaker;
WriteMakefile(
	      NAME          => 'WWW::AdServer',
	      AUTHOR        => 'Nigel Wetters <nwetters@cpan.org>',
	      VERSION_FROM  => 'lib/WWW/AdServer.pm',
	      ABSTRACT_FROM => "lib/WWW/AdServer.pm",
	      PREREQ_PM     => {
		  'Test::More'       => 0
	      }
	      );
