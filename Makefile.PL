use inc::Module::Install;

name        'Iodef-Pb-Simple';
all_from    'lib/Iodef/Pb/Simple.pm';

requires    'Module::Install'           => '1.00';
requires    'Iodef::Pb'                 => '0.00';

WriteAll();
