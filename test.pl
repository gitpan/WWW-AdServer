use Test::More tests => 18;

BEGIN
{
    use_ok( 'WWW::AdServer' );
    use_ok( 'WWW::AdServer::Advert' );
    use_ok( 'WWW::AdServer::Displayer' );
    use_ok( 'WWW::AdServer::Displayer::IFrame' );
    use_ok( 'WWW::AdServer::Displayer::JScript' );
    use_ok( 'WWW::AdServer::Displayer::NonSSI' );
    use_ok( 'WWW::AdServer::Logger' );
    use_ok( 'WWW::AdServer::Logger::DevNull' );
    use_ok( 'WWW::AdServer::Logger::Text' );
}

require_ok( 'WWW::AdServer' );
require_ok( 'WWW::AdServer::Advert' );
require_ok( 'WWW::AdServer::Displayer' );
require_ok( 'WWW::AdServer::Displayer::IFrame' );
require_ok( 'WWW::AdServer::Displayer::JScript' );
require_ok( 'WWW::AdServer::Displayer::NonSSI' );
require_ok( 'WWW::AdServer::Logger' );
require_ok( 'WWW::AdServer::Logger::DevNull' );
require_ok( 'WWW::AdServer::Logger::Text' );

