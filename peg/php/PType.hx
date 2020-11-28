package peg.php;

enum PType {
	TNull;
	TInt;
	TFloat;
	TString;
	TBool;
	TCallable;
	TIterable;
	TObject;
	TMixed;
	TVoid;
	TArray(index:PType, item:PType);
	TClass(name:String);
	TOr(types:ReadOnlyArray<PType>);
}