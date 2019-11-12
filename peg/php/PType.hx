package peg.php;

enum PType {
	TInt;
	TFloat;
	TString;
	TBool;
	TArray(type:PType);
	TObject;
	TCallable;
	TMixed;
	TResource;
	TVoid;
	TClass(name:String);
	TOr(types:ReadOnlyArray<PType>);
}