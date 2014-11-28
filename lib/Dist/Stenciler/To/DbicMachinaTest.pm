use Moops;

class Dist::Stenciler::To::DbicMachinaTest using Moose {

    use Moose::Role;

    method to_dbic_machina_test {
        my $basename = $self->_get_basename;
        my $filename = $self->_get_filename;

        return if !$self->has_stencils;

        my @parsed = $self->all_head_lines_pretty;

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
                push @parsed => sprintf q{is(slurped('%s'), slurped('%s'), 'Test %s on row %s in %s');},
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

        return join ("\n" => @parsed) . "\n";
    }

}

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
