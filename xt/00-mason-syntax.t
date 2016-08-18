use strict;
use warnings;

use lib 'xt/lib';
use RT::Extension::SideBySideView::Test nodb => 1;

use File::Find;
find( {
    no_chdir => 1,
    wanted   => sub {
        return if /(?:\.(?:jpe?g|png|gif|rej)|\~)$/i;
        return if m{/\.[^/]+\.sw[op]$}; # vim swap files
        return unless -f $_;
        local ($@);
        ok( eval { compile_file($_) }, "Compiled $File::Find::name ok: $@");
    },
}, RT::Test::get_relocatable_dir('../html'));

use HTML::Mason;
use HTML::Mason::Compiler;
use HTML::Mason::Compiler::ToObject;
BEGIN { require RT::Test; }

sub compile_file {
    my $file = shift;

    my $text = Encode::decode("UTF-8", RT::Test->file_content($file));

    my $compiler = HTML::Mason::Compiler::ToObject->new;
    $compiler->compile(
        comp_source => $text,
        name => 'my',
        comp_path => 'my',
    );
    return 1;
}
