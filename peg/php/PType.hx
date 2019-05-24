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
	TOr(types:ReadOnlyArray<PType>);
}