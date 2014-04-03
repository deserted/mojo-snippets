################################################################################
## 		Copyright 2014 Tim Allingham																						##
##																																						##
##    This program is free software: you can redistribute it and/or modify		##
##    it under the terms of the GNU General Public License as published by		##
##    the Free Software Foundation, either version 3 of the License, or 			##
##    (at your option) any later version.																			##
##																																						##
##    This program is distributed in the hope that it will be useful,					##
##    but WITHOUT ANY WARRANTY; without even the implied warranty of					##
##    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the						##
##   GNU General Public License for more details.															##
##																																						##
##    You should have received a copy of the GNU General Public License				##
##    along with this program.  If not, see <http://www.gnu.org/licenses/>.		##
################################################################################


## Name your package below and uncomment the package line
## package ::Authenticate;
use strict;
use warnings;
use Mojo::Base 'Mojolicious::Controller';
use Net::LDAP;

sub authConnect {
    my $class = shift;
    my $self = bless {}, $class;
    return $self;
}


=begin nd
Function: check

Check if user has a current session
=cut
sub check {
	my $self = shift;
	$self->redirect_to('login.html') and return 0 unless ($self->is_user_authenticated);
	return 1;
}


=begin nd
Function: authLDAP
Process authentication via Active directory, return success or fail

=cut
sub authLDAP {
	my $self = shift;
	my ($user, $pass, $ldapHost, $ldapUser, $ldapPass, $baseDN) = @_;
	my $ldap = Net::LDAP->new($ldapHost, inet4 => 1, verify=>'none') or die "$@";
	$ldap->bind ($ldapUser, password=>"$ldapPass");
	my $userSearch = $ldap->search(base => "$baseDN", filter => "(&(objectClass=user)(sAMAccountName=$user))", attrs => ['dn', 'givenName', 'sn']);
	my $userEntry = $userSearch->shift_entry or return;
	my $userDN = $userEntry->dn;
	my $firstname = $userEntry->get_value("givenName");
	my $surname = $userEntry->get_value("sn");
	$ldap->unbind;
	my $userLdap = Net::LDAP->new($ldapHost, inet4 => 1, verify=>'none') or die "$@";

	my $mesg = $userLdap->bind($userDN, password => "$pass");

	if ($mesg->code) {
			# Bad Bind
			return;
	}

	$userLdap->unbind;
	return ($user, $firstname, $surname);

}

sub checkUser {
	my $self = shift;
	my ($user, $ldapHost, $ldapUser, $ldapPass, $baseDN) = @_;
	my $ldap = Net::LDAP->new($ldapHost, inet4 => 1, verify=>'none') or die "$@";
	$ldap->bind ($ldapUser, password=>"$ldapPass");
	my $userSearch = $ldap->search(base => "$baseDN", filter => "(&(objectClass=user)(sAMAccountName=$user))");
	my $userEntry = $userSearch->shift_entry or return;
	my $userDN = $userEntry->dn;
	$ldap->unbind;
	return $user;
}

=begin nd
Function: authDetails
Return users username and role in a json object

=cut

sub authDetails {
	my $self = shift;
	$self->render(json => {username => $self->current_user, role => $self->role});
	return 1;
}
1;
