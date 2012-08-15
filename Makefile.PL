use inc::Module::Install;

name        'Iodef-Pb-Simple';
all_from    'lib/Iodef/Pb/Simple.pm';
no_index    'examples';

requires    'Module::Install'               => '1.00';
requires    'Class::Accessor'               => '0.34';
requires    'Google::ProtocolBuffers'       => '0.08';
requires    'DateTime'                      => '0.61';
requires    'DateTime::Format::DateParse'   => '0.05';
requires    'Regexp::Common::net::CIDR'     => '0.02';
requires    'Encode'                        => '2.35';
requires    'Snort::Rule'                   => '1.07';
requires    'Parse::Range'                  => '0.96';

WriteAll();
