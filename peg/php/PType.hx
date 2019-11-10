package peg.php;

enum PType {
	TInt;
	TFloat;
	TString;
	TArrayOfString;
	TBool;
	TArray;
	TObject;
	TCallable;
	TMixed;
	TResource;
	TClass(name:String);
	TOr(types:ReadOnlyArray<PType>);
}