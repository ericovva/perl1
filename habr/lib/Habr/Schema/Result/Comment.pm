use utf8;
package Habr::Schema::Result::Comment;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Habr::Schema::Result::Comment

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<Comment>

=cut

__PACKAGE__->table("Comment");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 author

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 post

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "author",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "post",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 author

Type: belongs_to

Related object: L<Habr::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "author",
  "Habr::Schema::Result::User",
  { id => "author" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);

=head2 post

Type: belongs_to

Related object: L<Habr::Schema::Result::Post>

=cut

__PACKAGE__->belongs_to(
  "post",
  "Habr::Schema::Result::Post",
  { id => "post" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07045 @ 2016-05-15 17:42:39
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:CCLtAL3qD+pzBkemxKa7YA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
