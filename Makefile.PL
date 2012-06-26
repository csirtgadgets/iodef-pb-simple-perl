use inc::Module::Install;

name        'Iodef-Pb-Simple';
all_from    'lib/Iodef/Pb/Simple.pm';

requires    'Module::Install'           => '1.00';
requires    'Iodef::Pb'                 => '0.00';
requires    'DateTime'                  => '0.70';
requires    'DateTime::Format::DateParse'   => '0.05';
requires    'Regexp::Common::net::CIDR'     => '0.02';

WriteAll();
