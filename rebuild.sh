make realclean
rm MANIFEST
rm *.tar.gz
perl generate_bindings.pl
perl Makefile.PL
make manifest
make dist
