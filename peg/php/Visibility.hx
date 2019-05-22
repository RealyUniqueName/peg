package peg.php;

enum abstract Visibility(String) to String {
	var VPublic = 'public';
	var VPrivate = 'private';
	var VProtected = 'protected';
}