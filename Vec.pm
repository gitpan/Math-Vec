package Math::Vec;
our $VERSION   = '0.01';

=pod

=head1 NAME

Math::Vec - Object-Oriented Vector Math Methods in Perl

=head1 SYNOPSIS

  use Math::Vec;
  $v = Math::Vec->new(0,1,2);

  or

  use Math::Vec qw(NewVec);
  $v = NewVec(0,1,2);

=head1 NOTICE

This module is still somewhat incomplete.  If a function does nothing,
there is likely a really good reason.  Please have a look at the code
if you are trying to use this in a production environment.

=head1 AUTHOR

Eric Wilhelm <ewilhelm at sbcglobal dot net>

=head1 DESCRIPTION

This module was adapted from Math::Vector, written by Wayne M. Syvinski.

It uses most of the same algorithms, and currently preserves the same
names as the original functions, though some aliases have been added to
make the interface more natural (at least to the way I think.)

The "object" for the object oriented calling style is a blessed array
reference which contains a vector of the form [x,y,z].  Methods will
typically return a list.

=head1 COPYRIGHT NOTICE

Copyright (C) 2003 Eric Wilhelm

portions Copyright 2003 Wayne M. Syvinski

=head1 NO WARRANTY

Absolutely, positively NO WARRANTY, neither express or implied, is
offered with this software.  You use this software at your own risk.
In case of loss, neither Wayne M. Syvinski, Eric Wilhelm, nor anyone
else, owes you anything whatseover.  You have been warned.

Note that this includes NO GUARANTEE of MATHEMATICAL CORRECTNESS.  If
you are going to use this code in a production environment, it is YOUR
RESPONSIBILITY to verify that the methods return the correct values. 

=head1 LICENSE

You may use this software under one of the following licenses:

  (1) GNU General Public License 
    (found at http://www.gnu.org/copyleft/gpl.html) 
  (2) Artistic License 
    (found at http://www.perl.com/pub/language/misc/Artistic.html)

=head1 Dependencies

  Math::Complex;

=head1 INSTALLATION

To install this module, type the following.

  perl Makefile.PL
  make
  make test
  make install

Note that the tests currently do very little.  If you would like to
write some tests, I would be happy to include them in the distribution.

=head1 SEE ALSO

  Math::Vector

=cut

########################################################################


require Exporter;
@ISA='Exporter';
@EXPORT_OK = qw (
	NewVec
	);

use strict;
use Carp;
use Math::Complex;

########################################################################

=head1 Constructor

=cut
########################################################################

=head2 new

Returns a blessed array reference to cartesian point ($x, $y, $z),
where $z is optional.  Note the feed-me-list, get-back-reference syntax
here.  This is the opposite of the rest of the methods for a good
reason (it allows nesting of function calls.)

Implied zeros are a strong theme in this module, so it may not do well
under the warnings pragma.  I see this as part of the adventure.

  $vec = Math::Vec->new($x, $y, $z);

=cut
sub new {
	my $caller = shift;
	my $class = ref($caller) || $caller;
	my $self = [map({defined($_) ? $_ : 0} @_)];
	bless($self, $class);
	return($self);
} # end subroutine new definition
########################################################################

=head2 NewVec

This is simply a shortcut to Math::Vec->new($x, $y, $z) for those of
you who don't want to type so much so often.  This also makes it easier
to nest / chain your function calls.  Note that methods will typically
output lists (e.g. the answer to your question.)  While you can simply
[bracket] the answer to make an array reference, you need that to be
blessed in order to use the $object->method(@args) syntax.  This
function does that blessing.

This function is exported as an option.  To use it, simply use
Math::Vec qw(NewVec); at the start of your code.

  use Math::Vec qw(NewVec);
  $vec = NewVec($x, $y, $z);
  $diff = NewVec($vec->Minus([$ovec->ScalarMult(0.5)]));

=cut
sub NewVec {
	return(Math::Vec->new(@_));
} # end subroutine NewVec definition
########################################################################

=head1 Methods

The typical theme is that methods require array references and return
lists.  This means that you can choose whether to create an anonymous
array ref for use in feeding back into another function call, or you
can simply use the list as-is.  Methods which return a scalar or list
of scalars (in the mathematical sense, not the Perl SV sense) are
exempt from this theme, but methods which return what could become one
vector will return it as a list.

If you want to chain calls together, either use the NewVec constructor,
or enclose the call in square brackets to make an anonymous array out
of the result.

  my $vec = NewVec(@pt);
  my $doubled = NewVec($vec->ScalarMult(0.5));
  my $other = NewVec($vec->Plus([0,2,1], [4,2,3]));
  my @result = $other->Minus($doubled);
  $unit = NewVec(NewVec(@result)->UnitVector());

The vector objects are simply blessed array references.  This makes for
a fairly limited amount of manipulation, but vector math is not
complicated stuff.  Hopefully, you can save at least two lines of code
per calculation using this module.

=cut
########################################################################

=head2 Dot

Alias to DotProduct()

  $vec->Dot($othervec);

=cut
sub Dot {
	my $self = shift;
	return($self->DotProduct(@_));
} # end subroutine Dot definition
########################################################################

=head2 DotProduct

Returns the dot product of $vec 'dot' $othervec.

  $vec->DotProduct($othervec);

=cut
sub DotProduct {
	my Math::Vec $self = shift;
	my ($operand) = @_;
	my @r = map( {$self->[$_] * $operand->[$_]} 0,1,2);
	return( $r[0] + $r[1] + $r[1]);
} # end subroutine DotProduct definition
########################################################################

=head2 Cross

Returns $vec x $other_vec

  $vec->Cross($other_vec);

=cut
sub Cross {
	my $a = shift;
	my $b = shift;
	my $x = (($a->[1] * $b->[2]) - ($a->[2] * $b->[1]));
	my $y = (($a->[2] * $b->[0]) - ($a->[0] * $b->[2]));
	my $z = (($a->[0] * $b->[1]) - ($a->[1] * $b->[0]));
	return($x, $y, $z);
} # end subroutine Cross definition
########################################################################

=head2 CrossProduct

  $vec->CrossProduct();

=cut
sub CrossProduct {
	my $self = shift;
	return($self->Cross(@_));
} # end subroutine CrossProduct definition
########################################################################

=head2 Length

Returns the length of $vec

  $length = $vec->Length();

=cut
sub Length {
	my Math::Vec $self = shift;
	my $sum;
	map( {$sum+=$_} map({$_** 2} @$self) );
	return(sqrt($sum));
} # end subroutine Length definition
########################################################################

=head2 Magnitude

  $vec->Magnitude();

=cut
sub Magnitude {
	my Math::Vec $self = shift;
	return($self->Length());
} # end subroutine Magnitude definition
########################################################################

=head2 UnitVector

  $vec->UnitVector();

=cut
sub UnitVector {
	my Math::Vec $self = shift;
	my $mag = $self->Length();
	$mag || croak("zero-length vector (@$self) has no unit vector");
	return(map({$_ / $mag} @$self) );
} # end subroutine UnitVector definition
########################################################################

=head2 ScalarMult

Factors each element of $vec by $factor.

  @new = $vec->ScalarMult($factor);

=cut
sub ScalarMult {
	my Math::Vec $self = shift;
	my($factor) = @_;
	return(map( {$_ * $factor} @{$self}));
} # end subroutine ScalarMult definition
########################################################################

=head2 Minus

Subtracts an arbitrary number of vectors.

  @result = $vec->Minus($other_vec, $another_vec?);

This would be equivelant to:

  @result = $vec->Minus([$other_vec->Plus(@list_of_vectors)]);

=cut
sub Minus {
	my Math::Vec $self = shift;
	my @list = @_;
	my @result = @$self;
	foreach my $vec (@list) {
		@result = map( {$result[$_] - $vec->[$_]} 0,1,2);
		}
	return(@result);
} # end subroutine Minus definition
########################################################################

=head2 VecSub

Alias to Minus()

  $vec->VecSub();

=cut
sub VecSub {
	my Math::Vec $self = shift;
	return($self->Minus(@_));
} # end subroutine VecSub definition
########################################################################

=head2 InnerAngle

Returns the acute angle (in radians) in the plane defined by the two
vectors.

  $vec->InnerAngle($other_vec);

=cut
sub InnerAngle {
	my $A = shift;
	my $B = shift;
	my $dot_prod = $A->Dot($B);
	my $m_A = $A->Length();
	my $m_B = $B->Length();
	return(acos($dot_prod / ($m_A * $m_B)) );
} # end subroutine InnerAngle definition
########################################################################

=head2 DirAngles

  $vec->DirAngles();

=cut
sub DirAngles {
	my Math::Vec $self = shift;
	my @unit = $self->UnitVector();
	return( map( {acos($_)} @unit) );
} # end subroutine DirAngles definition
########################################################################

=head2 Plus

Adds an arbitrary number of vectors.

  @result = $vec->Plus($other_vec, $another_vec);

=cut
sub Plus {
	my Math::Vec $self = shift;
	my @list = @_;
	my @result = @$self;
	foreach my $vec (@list) {
		@result = map( {$result[$_] + $vec->[$_]} 0,1,2);
		}
	return(@result);
} # end subroutine Plus definition
########################################################################

=head2 PlanarAngles

If called in list context, returns the angle of the vector in each of
the primary planes.  If called in scalar context, returns only the
angle in the xy plane.  Angles are returned in radians
counter-clockwise from the primary axis (the one listed first in the
pairs below.)

  ($xy_ang, $xz_ang, $yz_ang) = $vec->PlanarAngles();

=cut
sub PlanarAngles {
	my $self = shift;
	my $xy = atan2($self->[1], $self->[0]);
	wantarray || return($xy);
	my $xz = atan2($self->[2], $self->[0]);
	my $yz = atan2($self->[2], $self->[1]);
	return($xy, $xz, $yz);
} # end subroutine PlanarAngles definition
########################################################################

=head2 Ang

A simpler alias to PlanarAngles() which eliminates the concerns about
context and simply returns the angle in the xy plane.

  $xy_ang = $vec->Ang();

=cut
sub Ang {
	my $self = shift;
	my ($xy) = $self->PlanarAngles();
	return($xy);
} # end subroutine Ang definition
########################################################################

=head2 VecAdd

  $vec->VecAdd();

=cut
sub VecAdd {
	my Math::Vec $self = shift;
	return($self->Plus(@_));
} # end subroutine VecAdd definition
########################################################################

=head2 UnitVectorPoints

Returns a unit vector which points from $A to $B.

  $A->UnitVectorPoints($B);

=cut
sub UnitVectorPoints {
	my $A = shift;
	my $B = shift;
	$B = NewVec(@$B); # because we cannot guarantee that it was blessed
	return(NewVec($B->Minus($A))->UnitVector());
} # end subroutine UnitVectorPoints definition
########################################################################

=head2 InnerAnglePoints

Returns the InnerAngle() between the three points.  $Vert is the vertex
of the points.

  $Vert->InnerAnglePoints($endA, $endB);

=cut
sub InnerAnglePoints {
	my $v = shift;
	my ($A, $B) = @_;
	my $lead = NewVec($v->UnitVectorPoints($A));
	my $tail = NewVec($v->UnitVectorPoints($B));
	return($lead->InnerAngle($tail));
} # end subroutine InnerAnglePoints definition
########################################################################

=head2 PlaneUnitNormal

Returns a unit vector normal to the plane described by the three
points.  The sense of this vector is according to the right-hand rule
and the order of the given points.  The $Vert vector is taken as the
vertex of the three points.  e.g. if $Vert is the origin of a
coordinate system where the x-axis is $A and the y-axis is $B, then the
return value would be a unit vector along the positive z-axis.

  $Vert->PlaneUnitNormal($A, $B);

=cut
sub PlaneUnitNormal {
	my $v = shift;
	my ($A, $B) = @_;
	$A = NewVec(@$A);
	$B = NewVec(@$B);
	my $lead = NewVec($A->Minus($v));
	my $tail = NewVec($B->Minus($v));
	return(NewVec($lead->Cross($tail))->UnitVector);
} # end subroutine PlaneUnitNormal definition
########################################################################

=head2 TriAreaPoints

Returns the angle of the triangle formed by the three points.

  $A->TriAreaPoints($B, $C);

=cut
sub TriAreaPoints {
	my $A = shift;
	my ($B, $C) = @_;
	$B = NewVec(@$B);
	$C = NewVec(@$C);
	my $lead = NewVec($A->Minus($B));
	my $tail = NewVec($A->Minus($C));
	return(NewVec($lead->Cross($tail))->Length() / 2);
} # end subroutine TriAreaPoints definition
########################################################################

=head1 Incomplete Methods

The following have yet to be translated into this interface.  They are
shown here simply because I intended to fully preserve the function
names from the original Math::Vector module written by Wayne M.
Syvinski.

=cut
########################################################################

=head2 TripleProduct

  $vec->TripleProduct();

=cut
sub TripleProduct {

} # end subroutine TripleProduct definition
########################################################################

=head2 IJK

  $vec->IJK();

=cut
sub IJK {

} # end subroutine IJK definition
########################################################################

=head2 OrdTrip

  $vec->OrdTrip();

=cut
sub OrdTrip {

} # end subroutine OrdTrip definition
########################################################################

=head2 STV

  $vec->STV();

=cut
sub STV {

} # end subroutine STV definition
########################################################################

=head2 Equil

  $vec->Equil();

=cut
sub Equil {

} # end subroutine Equil definition
########################################################################

1;
