use Moops;

role Dist::Stenciler::Plugin::To::DbicMachina::Tests using Moose {

    method to_dbic_machina_test {
        my $basename = $self->get_basename;
        my $filename = $self->get_filename;

        return if !$self->has_stencils;


        my @parsed = $self->common_header;
        push @parsed => $self->all_head_lines;

        STENCIL:
        foreach my $index (0 .. $self->stencil_count - 1) {
            my $stencil = $self->get_stencil($index);
            next STENCIL if !$stencil->has_lines_input;

            push @parsed => $stencil->all_lines_before_input;
            push @parsed => q{my($mach, $handler, $dir) = setup_environment();};

            push @parsed => map { sprintf q{$handler->handle_command(command_for('%s'));}, $_ } $stencil->all_lines_input;
            push @parsed => $stencil->all_lines_after_input;

            foreach my $line ($stencil->all_lines_output) {
                my $path = join '/' => split /::/ => $line;
                push @parsed => sprintf q{is(slurped(%s), slurped('%s.pm'), 'Test %s on row %s in %s');},
                                        '$mach->package_to_path($line)',
                                        "/compare/@{[ $stencil->name ]}/$path",
                                        $stencil->name,
                                        $stencil->start_line,
                                        $self->get_filename;
            }

            push @parsed => $stencil->all_lines_after_output;

        }

        push @parsed => 'done_testing();';
        push @parsed => $self->all_foot_lines;
        push @parsed => $self->common_footer;

        return join "\n" => @parsed;
    }

    method common_header {
        (my $header = <<"        HEADER") =~ s{^ {8}}{}gm;
        use strict;
        use Test::More;
        use Regexp::Grammars;
        use DBIx::Class::Machina;
        use DBIx::Class::Machina::Syntax;
        use DBIx::Class::Machina::Handler;
        use Safe::Isa;
        use File::Temp;
        use Path::Tiny;
        use Kavorka;

        HEADER

        return $header;
    }

    method common_footer {
        (my $footer = <<'        FOOTER') =~ s{^ {8}}{}gm;
        sub setup_environment {
            my $dir = File::Temp->newdir;
            warn 'Create temp dir ' . $dir->dirname;
            my $basepath = path($dir->dirname)->child('lib/Our/Machina/Test');
            $basepath->mkpath;
            my $mach = DBIx::Class::Machina->new(base_path => Path::Tiny->new($basepath->absolute), namespace => 'Our::Machina::Test::Schema');
            $mach->create_environment_at_basepath;
            my $handler = DBIx::Class::Machina::Handler->new(mach => $mach);

            return($mach, $handler, $dir);
        }

        sub outfile {
            my $path = shift;
            warn path($path)->slurp;
        }

        sub command_for {
            my $regexp = shift;
            my $matches = ($regexp =~ $grammar);
            my $result = $matches ? \%/ : undef;
            return $result->{'FromClient'}->Command;
        }

        sub out {
            my($sample, $grammar);
            print 'x' x 50;
            if($sample =~ $grammar) {
                print '--------------------------' x 20;
                print Dumper \%/;
            }
        }
        FOOTER

        return $footer;
    }

}

1;

__END__

=encoding utf-8

=head1 NAME

Dist::Stenciler::To::DbicMachinaTest - Blah blah blah

=head1 SYNOPSIS

  use Dist::Stenciler::To::DbicMachinaTest;

=head1 DESCRIPTION

Dist::Stenciler::To::DbicMachinaTest is

=head1 AUTHOR

Erik Carlsson E<lt>info@code301.comE<gt>

=head1 COPYRIGHT

Copyright 2014- Erik Carlsson

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
