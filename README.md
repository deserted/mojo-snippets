Mojo::Snippets
=============

This repo contains some little snippets or modules I find useful when building a Mojolicious site

## Authentication
Modules and functions for performing authentication against different backends

### Active Directory
Small module to authenticate against active directory with Net::LDAP, usually used against the Mojolicious::Plugin::Authentication module (http://search.cpan.org/~madcat/Mojolicious-Plugin-Authentication/lib/Mojolicious/Plugin/Authentication.pm)
includes a check function for use in an route bridge, along with authLDAP for use in the validate_user sub and a checkUser function for use in the load_user subroutine.

It also contains an authDetails function that when used with Mojolicious::Plugin::Authentication  and Mojolicious::Plugin::Authorization (https://metacpan.org/pod/Mojolicious::Plugin::Authorization) can be used as a route destination to return a JSON string with the current username and the users role.

You can use the following configuration variables to configure your LDAP server

```Perl
{
  ldap_host		=> 'ldap.example.com',
	ldap_user		=> 'ladpusername',
	ldap_pass		=> 'ldappassword',
	ldap_userdn	=> 'OU string to your users - ie OU=Users,DC=ldap,DC=example,DC=com',
}
```
