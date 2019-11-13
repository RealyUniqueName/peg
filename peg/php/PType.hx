package peg.php;

enum PType {
	TInt;
	TFloat;
	TString;
	TBool;
	TArray(type:PType);
	TObject(indexType:PType, valueType:PType);
	TCallable;
	TMixed;
	TResource;
	TVoid;
	TClass(name:String);
	TOr(types:ReadOnlyArray<PType>);
}