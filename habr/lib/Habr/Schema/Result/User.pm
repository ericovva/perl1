use utf8;
package Habr::Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Habr::Schema::Result::User

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<User>

=cut

__PACKAGE__->table("User");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 username

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 karma

  data_type: 'double precision'
  is_nullable: 1

=head2 rating

  data_type: 'double precision'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "username",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "karma",
  { data_type => "double precision", is_nullable => 1 },
  "rating",
  { data_type => "double precision", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=item * L</username>

=back

=cut

__PACKAGE__->set_primary_key("id", "username");

=head1 RELATIONS

=head2 comments

Type: has_many

Related object: L<Habr::Schema::Result::Comment>

=cut

__PACKAGE__->has_many(
  "comments",
  "Habr::Schema::Result::Comment",
  { "foreign.author" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 posts

Type: has_many

Related object: L<Habr::Schema::Result::Post>

=cut

__PACKAGE__->has_many(
  "posts",
  "Habr::Schema::Result::Post",
  { "foreign.author" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07045 @ 2016-05-15 17:42:39
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:TurXUDfiUcz7GxZwhKuU7A


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
