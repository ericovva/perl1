use utf8;
package Habr::Schema::Result::Post;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Habr::Schema::Result::Post

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<Post>

=cut

__PACKAGE__->table("Post");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 theme

  data_type: 'varchar'
  is_nullable: 0
  size: 1000

=head2 author

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 shows

  data_type: 'integer'
  is_nullable: 1

=head2 rating

  data_type: 'double precision'
  is_nullable: 1

=head2 stars

  data_type: 'integer'
  is_nullable: 1

=head2 post_id

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "theme",
  { data_type => "varchar", is_nullable => 0, size => 1000 },
  "author",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "shows",
  { data_type => "integer", is_nullable => 1 },
  "rating",
  { data_type => "double precision", is_nullable => 1 },
  "stars",
  { data_type => "integer", is_nullable => 1 },
  "post_id",
  { data_type => "integer", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=item * L</theme>

=back

=cut

__PACKAGE__->set_primary_key("id", "theme");

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

=head2 comments

Type: has_many

Related object: L<Habr::Schema::Result::Comment>

=cut

__PACKAGE__->has_many(
  "comments",
  "Habr::Schema::Result::Comment",
  { "foreign.post" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07045 @ 2016-05-15 17:42:39
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:I0SBV99P0zN1KEHzC89THw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
