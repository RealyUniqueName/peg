package peg.php;

enum PType {
	TInt;
	TFloat;
	TString;
	TBool;
	TArray;
	TCallable;
	TMixed;
	TClass(name:String);
}