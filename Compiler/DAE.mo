/*
 * This file is part of OpenModelica.
 *
 * Copyright (c) 1998-2008, Link�pings University,
 * Department of Computer and Information Science,
 * SE-58183 Link�ping, Sweden.
 *
 * All rights reserved.
 *
 * THIS PROGRAM IS PROVIDED UNDER THE TERMS OF THIS OSMC PUBLIC
 * LICENSE (OSMC-PL). ANY USE, REPRODUCTION OR DISTRIBUTION OF
 * THIS PROGRAM CONSTITUTES RECIPIENT'S ACCEPTANCE OF THE OSMC
 * PUBLIC LICENSE.
 *
 * The OpenModelica software and the Open Source Modelica
 * Consortium (OSMC) Public License (OSMC-PL) are obtained
 * from Link�pings University, either from the above address,
 * from the URL: http://www.ida.liu.se/projects/OpenModelica
 * and in the OpenModelica distribution.
 *
 * This program is distributed  WITHOUT ANY WARRANTY; without
 * even the implied warranty of  MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE, EXCEPT AS EXPRESSLY SET FORTH
 * IN THE BY RECIPIENT SELECTED SUBSIDIARY LICENSE CONDITIONS
 * OF OSMC-PL.
 *
 * See the full OSMC Public License conditions for more details.
 *
 */

package DAE
" file:	 DAE.mo
  package:     DAE
  description: DAE management and output
 
  RCS: $Id$
  
  This module defines data structures for DAE equations and declarations of
  variables and functions. The DAE data structure is the result of flattening,
  containing only flat modelica, i.e. equations, algorithms, variables and
  functions. 
"

public import Absyn;
public import ClassInf;
public import SCode;
public import Values;

public type Ident = String;

public type InstDims = list<Subscript>;

public type StartValue = Option<Exp>;

public constant String UNIQUEIO = "$unique$outer$";
  

public uniontype VarKind
  record VARIABLE end VARIABLE;

  record DISCRETE end DISCRETE;

  record PARAM end PARAM;

  record CONST end CONST;

end VarKind;

public uniontype Flow "The Flow of a variable indicates if it is a Flow variable or not, or if
   it is not a connector variable at all."
  record FLOW end FLOW;
 
  record NON_FLOW end NON_FLOW;

  record NON_CONNECTOR end NON_CONNECTOR;

end Flow;

public uniontype Stream "The Stream of a variable indicates if it is a Stream variable or not, or if
   it is not a connector variable at all."
  record STREAM end STREAM;

  record NON_STREAM end NON_STREAM;

  record NON_STREAM_CONNECTOR end NON_STREAM_CONNECTOR;
    
end Stream;


public uniontype VarDirection
  record INPUT end INPUT;

  record OUTPUT end OUTPUT;

  record BIDIR end BIDIR;

end VarDirection;

public uniontype VarProtection
  record PUBLIC "public variables" end PUBLIC; 
  record PROTECTED "protected variables" end PROTECTED;
end VarProtection;

public uniontype Element
  record VAR 
    ComponentRef componentRef " The variable name";
    VarKind kind "varible kind: variable, constant, parameter, discrete etc." ;
    VarDirection direction "input, output or bidir" ;
    VarProtection protection "if protected or public";
    Type ty "Full type information required";
    Option<Exp> binding "Binding expression e.g. for parameters ; value of start attribute" ; 
    InstDims  dims "dimensions";
    Flow flowPrefix "Flow of connector variable. Needed for unconnected flow variables" ;
    Stream streamPrefix "Stream variables in connectors" ;
    list<Absyn.Path> pathLst " " ;
    Option<VariableAttributes> variableAttributesOption;
    Option<SCode.Comment> absynCommentOption;
    Absyn.InnerOuter innerOuter "inner/outer required to 'change' outer references";
  end VAR;

  record DEFINE "A solved equation"
    ComponentRef componentRef;
    Exp exp;
  end DEFINE;

  record INITIALDEFINE " A solved initial equation"
    ComponentRef componentRef;
    Exp exp;
  end INITIALDEFINE;
  
  record EQUATION "Scalar equation"
    Exp exp;
    Exp scalar ;
  end EQUATION;

  record EQUEQUATION "effort variable equality"
    ComponentRef cr1;
    ComponentRef cr2;
  end EQUEQUATION;

  record ARRAY_EQUATION " an array equation"
    list<Integer> dimension "dimension sizes" ;
    Exp exp;
    Exp array  ;
  end ARRAY_EQUATION;

  record COMPLEX_EQUATION "an equation of complex type, e.g. record = func(..)"
    Exp lhs;
    Exp rhs;
  end COMPLEX_EQUATION;
  
  record INITIAL_COMPLEX_EQUATION "an initial equation of complex type, e.g. record = func(..)"
    Exp lhs;
    Exp rhs;
  end INITIAL_COMPLEX_EQUATION;
  
  
  record WHEN_EQUATION " a when equation"
    Exp condition "Condition" ;
    list<Element> equations "Equations" ;
    Option<Element> elsewhen_ "Elsewhen should be of type WHEN_EQUATION" ;
  end WHEN_EQUATION;

  record IF_EQUATION " an if-equation"
    list<Exp> condition1 "Condition" ;
    list<list<Element>> equations2 "Equations of true branch" ;
    list<Element> equations3 "Equations of false branch" ;
  end IF_EQUATION;

  record INITIAL_IF_EQUATION "An initial if-equation"
    list<Exp> condition1 "Condition" ;
    list<list<Element>> equations2 "Equations of true branch" ;
    list<Element> equations3 "Equations of false branch" ;
  end INITIAL_IF_EQUATION;

  record INITIALEQUATION " An initial equaton"
    Exp exp1;
    Exp exp2;
  end INITIALEQUATION;

  record ALGORITHM " An algorithm section"
    Algorithm algorithm_;
  end ALGORITHM;

  record INITIALALGORITHM " An initial algorithm section"
    Algorithm algorithm_;
  end INITIALALGORITHM;

  record COMP
    Ident ident;
    DAElist dAElist "a component with 
						    subelements, normally 
						    only used at top level." ;
  end COMP;

  record FUNCTION " A Modelica function"
    Absyn.Path path;
    DAElist dAElist;
    Type type_;
    Boolean partialPrefix "MetaModelica extension";
  end FUNCTION;

  record EXTFUNCTION "An external function"
    Absyn.Path path;
    DAElist dAElist;
    Type type_;
    ExternalDecl externalDecl;
  end EXTFUNCTION;
  
  record RECORD_CONSTRUCTOR "A Modelica record constructor. The function can be generated from the Path and Type alone."
    Absyn.Path path;
    Type type_;
  end RECORD_CONSTRUCTOR;

  record EXTOBJECTCLASS "The 'class' of an external object"
    Absyn.Path path "className of external object";
    Element constructor "constructor is an EXTFUNCTION";
    Element destructor "destructor is an EXTFUNCTION";
  end EXTOBJECTCLASS;
  
  record ASSERT " The Modelica builtin assert"
    Exp condition;
    Exp message;
  end ASSERT;

  record TERMINATE " The Modelica builtin terminate(msg)"
    Exp message;
  end TERMINATE;

  record REINIT " reinit operator for reinitialization of states"
    ComponentRef componentRef;
    Exp exp;
  end REINIT;

   record NORETCALL "call with no return value, i.e. no equation. 
	   Typically sideeffect call of external function."  
     Absyn.Path functionName;
     list<Exp> functionArgs;
   end NORETCALL;
end Element;

public 
uniontype VariableAttributes
  record VAR_ATTR_REAL
    Option<Exp> quantity "quantity" ;
    Option<Exp> unit "unit" ;
    Option<Exp> displayUnit "displayUnit" ;
    tuple<Option<Exp>, Option<Exp>> min "min , max" ;
    Option<Exp> initial_ "Initial value" ;
    Option<Exp> fixed "fixed - true: default for parameter/constant, false - default for other variables" ;
    Option<Exp> nominal "nominal" ;
    Option<StateSelect> stateSelectOption;
    Option<Exp> equationBound;
    Option<Boolean> isProtected;
    Option<Boolean> finalPrefix;
  end VAR_ATTR_REAL;

  record VAR_ATTR_INT
    Option<Exp> quantity "quantity" ;
    tuple<Option<Exp>, Option<Exp>> min "min , max" ;
    Option<Exp> initial_ "Initial value" ;
    Option<Exp> fixed "fixed - true: default for parameter/constant, false - default for other variables" ;
    Option<Exp> equationBound;
    Option<Boolean> isProtected; // ,eb,ip
    Option<Boolean> finalPrefix;
  end VAR_ATTR_INT;

  record VAR_ATTR_BOOL
    Option<Exp> quantity "quantity" ;
    Option<Exp> initial_ "Initial value" ;
    Option<Exp> fixed "fixed - true: default for parameter/constant, false - default for other variables" ;
    Option<Exp> equationBound;
    Option<Boolean> isProtected;
    Option<Boolean> finalPrefix;
  end VAR_ATTR_BOOL;

  record VAR_ATTR_STRING
    Option<Exp> quantity "quantity" ;
    Option<Exp> initial_ "Initial value" ;
    Option<Exp> equationBound;
    Option<Boolean> isProtected;
    Option<Boolean> finalPrefix;
  end VAR_ATTR_STRING;

  record VAR_ATTR_ENUMERATION
    Option<Exp> quantity "quantity" ;
    tuple<Option<Exp>, Option<Exp>> min "min , max" ;
    Option<Exp> start "start" ;
    Option<Exp> fixed "fixed - true: default for parameter/constant, false - default for other variables" ;
    Option<Exp> equationBound;
    Option<Boolean> isProtected;
    Option<Boolean> finalPrefix;
  end VAR_ATTR_ENUMERATION;

end VariableAttributes;

public uniontype StateSelect
  record NEVER end NEVER;

  record AVOID end AVOID;

  record DEFAULT end DEFAULT;

  record PREFER end PREFER;

  record ALWAYS end ALWAYS;
end StateSelect;

public uniontype ExtArg
  record EXTARG
    ComponentRef componentRef;
    Attributes attributes;
    Type type_;
  end EXTARG;

  record EXTARGEXP
    Exp exp;
    Type type_;
  end EXTARGEXP;

  record EXTARGSIZE
    ComponentRef componentRef;
    Attributes attributes;
    Type type_;
    Exp exp;
  end EXTARGSIZE;

  record NOEXTARG end NOEXTARG;
end ExtArg;

public uniontype ExternalDecl
  record EXTERNALDECL
    Ident ident;
    list<ExtArg> external_ "external function name" ;
    ExtArg parameters "parameters" ;
    String returnType "return type" ;
    Option<Absyn.Annotation> language "language e.g. Library" ;
  end EXTERNALDECL;
end ExternalDecl;

public uniontype DAElist "A DAElist is a list of Elements. Variables, equations, functions, 
  algorithms, etc. are all found in this list.
"
  record DAE
    list<Element> elementLst;
  end DAE;
end DAElist;

/* -- Algorithm.mo -- */
public 
uniontype Algorithm "The `Algorithm\' type corresponds to a whole algorithm section.
  It is simple a list of algorithm statements."
  record ALGORITHM_STMTS
    list<Statement> statementLst;
  end ALGORITHM_STMTS;

end Algorithm;

public 
uniontype Statement "There are four kinds of statements.  Assignments (`a := b;\'),
    if statements (`if A then B; elseif C; else D;\'), for loops
    (`for i in 1:10 loop ...; end for;\') and when statements
    (`when E do S; end when;\')."
  record STMT_ASSIGN
    ExpType type_;
    Exp exp1;
    Exp exp;
  end STMT_ASSIGN;

  record STMT_TUPLE_ASSIGN
    ExpType type_;
    list<Exp> expExpLst;
    Exp exp;
  end STMT_TUPLE_ASSIGN;

  record STMT_ASSIGN_ARR
    ExpType type_;
    ComponentRef componentRef;
    Exp exp;
  end STMT_ASSIGN_ARR;

  record STMT_IF
    Exp exp;
    list<Statement> statementLst;
    Else else_;
  end STMT_IF;

  record STMT_FOR
    ExpType type_;
    Boolean boolean;
    Ident ident;
    Exp exp;
    list<Statement> statementLst;
  end STMT_FOR;

  record STMT_WHILE
    Exp exp;
    list<Statement> statementLst;
  end STMT_WHILE;

  record STMT_WHEN
    Exp exp;
    list<Statement> statementLst;
    Option<Statement> elseWhen;
    list<Integer> helpVarIndices;
  end STMT_WHEN;

  record STMT_ASSERT "assert(cond,msg)"
    Exp cond;
    Exp msg;
  end STMT_ASSERT;
  
  record STMT_TERMINATE "terminate(msg)"
    Exp msg;
  end STMT_TERMINATE;

  record STMT_REINIT 
    Exp var "Variable"; 
    Exp value "Value "; 
  end STMT_REINIT;
  
  record STMT_NORETCALL "call with no return value, i.e. no equation. 
		   Typically sideeffect call of external function."  
    Exp exp;
  end STMT_NORETCALL;    
  
  record STMT_RETURN
  end STMT_RETURN;
  
  record STMT_BREAK
  end STMT_BREAK;

  // MetaModelica extension. KS
  record STMT_TRY
    list<Statement> tryBody;
  end STMT_TRY;

  record STMT_CATCH
    list<Statement> catchBody;
  end STMT_CATCH;

  record STMT_THROW
  end STMT_THROW;

  record STMT_GOTO
    String labelName;
  end STMT_GOTO;

  record STMT_LABEL
    String labelName;
  end STMT_LABEL;
  
  record STMT_MATCHCASES "matchcontinue helper"
    list<Exp> caseStmt;
  end STMT_MATCHCASES;
  
  //-----

end Statement;

public 
uniontype Else "An if statements can one or more `elseif\' branches and an
    optional `else\' branch."
  record NOELSE end NOELSE;

  record ELSEIF
    Exp exp;
    list<Statement> statementLst;
    Else else_;
  end ELSEIF;

  record ELSE
    list<Statement> statementLst;
  end ELSE;

end Else;
/* -- End Algorithm.mo -- */

/* -- Start Types.mo -- */
public 
uniontype Var "- Variables"
  record TYPES_VAR
    Ident name "name" ;
    Attributes attributes "attributes" ;
    Boolean protected_ "protected" ;
    Type type_ "type" ;
    Binding binding "binding ; equation modification" ;
  end TYPES_VAR;

end Var;

public 
uniontype Attributes "- Attributes"
  record ATTR
    Boolean flowPrefix "flow" ;
    Boolean streamPrefix "stream" ;
    SCode.Accessibility accessibility "accessibility" ;
    SCode.Variability parameter_ "parameter" ;
    Absyn.Direction direction "direction" ;
    Absyn.InnerOuter innerOuter "inner, outer,  inner outer or unspecified";
  end ATTR;

end Attributes;

public 
uniontype Binding "- Binding"
  record UNBOUND end UNBOUND;

  record EQBOUND
    Exp exp "exp" ;
    Option<Values.Value> evaluatedExp "evaluatedExp; evaluated exp" ;
    Const constant_ "constant" ;
  end EQBOUND;

  record VALBOUND
    Values.Value valBound "valBound" ;
  end VALBOUND;

end Binding;

public type Type = tuple<TType, Option<Absyn.Path>> "
     A Type is a tuple of a TType (containing the actual type) and a optional classname
     for the class where the type originates from.

- Type";

public
type EqualityConstraint = Option<tuple<Absyn.Path, Integer>>;
 
public 
uniontype TType "-TType contains the actual type"
  record T_INTEGER
    list<Var> varLstInt "varLstInt" ;
  end T_INTEGER;

  record T_REAL
    list<Var> varLstReal "varLstReal" ;
  end T_REAL;

  record T_STRING
    list<Var> varLstString "varLstString" ;
  end T_STRING;

  record T_BOOL
    list<Var> varLstBool "varLstBool" ;
  end T_BOOL;

//  record T_ENUM end T_ENUM;

  record T_ENUMERATION
    Option<Integer> index "the enumeration value index, SOME for element, NONE for type" ;
    Absyn.Path path "enumeration path" ;
    list<String> names "names" ;
    list<Var> varLst "varLst, empty for elements" ;
  end T_ENUMERATION;

  record T_ARRAY
    ArrayDim arrayDim "arrayDim" ;
    Type arrayType "arrayType" ;
  end T_ARRAY;

  record T_NORETCALL "For functions not returning any values." end T_NORETCALL;

  record T_NOTYPE "Used when type is not yet determined" end T_NOTYPE;

  record T_ANYTYPE
    Option<ClassInf.State> anyClassType "anyClassType - used for generic types. When class state present the type is assumed to be a complex type which has that restriction." ;
  end T_ANYTYPE;
  
  // MetaModelica extensions
  record T_LIST "MetaModelica list type"
    Type listType "listType";
  end T_LIST;

  record T_METATUPLE "MetaModelica tuple type"
    list<Type> types;
  end T_METATUPLE;

  record T_METAOPTION "MetaModelica option type"
    Type optionType;
  end T_METAOPTION;

  record T_UNIONTYPE "MetaModelica Uniontype, added by simbj"
    list <Absyn.Path> records;
  end T_UNIONTYPE;
  
  record T_METARECORD "MetaModelica Record, used by Uniontypes. added by simbj"
    Integer index; //The index in the uniontype
    list<Var> fields;
  end T_METARECORD;
  
  record T_COMPLEX
    ClassInf.State complexClassType "complexClassType ; The type of. a class" ;
    list<Var> complexVarLst "complexVarLst ; The variables of a complex type" ;
    Option<Type> complexTypeOption "complexTypeOption ; A complex type can be a subtype of another (primitive) type (through extends). In that case the varlist is empty" ;
    EqualityConstraint equalityConstraint;
  end T_COMPLEX;

  record T_FUNCTION
    list<FuncArg> funcArg "funcArg" ;
    Type funcResultType "funcResultType ; Only single-result" ;
    Boolean inline;
  end T_FUNCTION;

  record T_TUPLE
    list<Type> tupleType "tupleType ; For functions returning multiple values."  ;
  end T_TUPLE;

  record T_BOXED "Used for MetaModelica generic types"
    Type ty;
  end T_BOXED;
  
  record T_POLYMORPHIC
    String name;
  end T_POLYMORPHIC;
  
  record T_META_ARRAY
    Type ty;
  end T_META_ARRAY;
  
end TType;

public 
uniontype ArrayDim "- Array Dimensions"
  record DIM
    Option<Integer> integerOption;
  end DIM;

end ArrayDim;

public 
type FuncArg = tuple<Ident, Type> "- Function Argument" ;

public 
uniontype Const "The degree of constantness of an expression is determined by the Const 
    datatype. Variables declared as \'constant\' will get C_CONST constantness.
    Variables declared as \'parameter\' will get C_PARAM constantness and
    all other variables are not constant and will get C_VAR constantness.

  - Variable properties"
  record C_CONST end C_CONST;

  record C_PARAM "\'constant\'s, should always be evaluated" end C_PARAM;

  record C_VAR "\'parameter\'s, evaluated if structural not constants, never evaluated" end C_VAR;

end Const;

public 
uniontype TupleConst "A tuple is added to the Types. This is used by functions whom returns multiple arguments.
  Used by split_props
  - Tuple constants"
  record SINGLE_CONST
    Const const;
  end SINGLE_CONST;

  record TUPLE_CONST
    list<TupleConst> tupleConstLst "tupleConstLst" ;
  end TUPLE_CONST;

end TupleConst;

public 
uniontype Properties "P.R 1.1 for multiple return arguments from functions, 
    one constant flag for each return argument. 

  The datatype `Properties\' contain information about an
    expression.  The properties are created by analyzing the
    expressions.
  - Expression properties"
  record PROP 
    Type type_ "type" ;
    Const constFlag "constFlag; if the type is a tuple, each element 
				          have a const flag." ;
  end PROP;

  record PROP_TUPLE
    Type type_;
    TupleConst tupleConst "tupleConst; The elements might be 
							    tuple themselfs." ;
  end PROP_TUPLE;

end Properties;

public 
uniontype EqMod "To generate the correct set of equations, the translator has to
  differentiate between the primitive types `Real\', `Integer\',
  `String\', `Boolean\' and types directly derived from then from
  other, complex types.  For arrays and matrices the type
  `T_ARRAY\' is used, with the first argument being the number of
  dimensions, and the second being the type of the objects in the
  array.  The `Type\' type is used to store
  information about whether a class is derived from a primitive
  type, and whether a variable is of one of these types.
  - Modification datatype, was originally in Mod"
  record TYPED
    Exp modifierAsExp "modifierAsExp ; modifier as expression" ;
    Option<Values.Value> modifierAsValue "modifierAsValue ; modifier as Value option" ;
    Properties properties "properties" ;
  end TYPED;

  record UNTYPED
    Absyn.Exp exp;
  end UNTYPED;

end EqMod;

public 
uniontype SubMod "-Sub Modification"
  record NAMEMOD
    Ident ident;
    Mod mod;
  end NAMEMOD;

  record IDXMOD
    list<Integer> integerLst;
    Mod mod;
  end IDXMOD;

end SubMod;

public 
uniontype Mod "Modification"
  record MOD
    Boolean finalPrefix "final" ;
    Absyn.Each each_;
    list<SubMod> subModLst;
    Option<EqMod> eqModOption;
  end MOD;

  record REDECL
    Boolean finalPrefix "final" ;
    list<tuple<SCode.Element, Mod>> tplSCodeElementModLst;
  end REDECL;

  record NOMOD end NOMOD;

end Mod;

/* -- End Types.mo -- */

/* -- Start Exp.mo -- */
public 
uniontype ExpType "- Basic types
    These types are not used as expression types (see the `Types\'
    module for expression types).  They are used to parameterize
    operators which may work on several simple types and for code generation."
  record ET_INT end ET_INT;

  record ET_REAL end ET_REAL;

  record ET_BOOL end ET_BOOL;

  record ET_STRING end ET_STRING;

 // record ENUM end ENUM;
 
  record ET_ENUMERATION
    Option<Integer> index "the enumeration value index, SOME for element, NONE for type" ;
    Absyn.Path path "enumeration path" ;
    list<String> names "names" ;
    list<ExpVar> varLst "varLst, empty for elements" ;
  end ET_ENUMERATION;

  record ET_COMPLEX "Complex types" 
    String name;
    list<ExpVar> varLst; 
    ClassInf.State complexClassType;
  end ET_COMPLEX;
  
  record ET_OTHER "e.g. complex types, etc." end ET_OTHER;

  record ET_ARRAY
    ExpType ty;
    list<Option<Integer>> arrayDimensions "arrayDimensions" ;
  end ET_ARRAY;

  // MetaModelica extension. KS
  record ET_LIST
    ExpType ty;
  end ET_LIST;

  record ET_METATUPLE
    list<ExpType> ty;
  end ET_METATUPLE;

  record ET_METAOPTION
    ExpType ty;
  end ET_METAOPTION;
  
  record ET_FUNCTION_REFERENCE_VAR "MetaModelica Function Reference that is a variable"
  end ET_FUNCTION_REFERENCE_VAR;
  record ET_FUNCTION_REFERENCE_FUNC "MetaModelica Function Reference that is a direct reference to a function"
  end ET_FUNCTION_REFERENCE_FUNC;
  
  //MetaModelica Uniontype, MetaModelica extension, simbj
  record ET_UNIONTYPE end ET_UNIONTYPE;
  
  record ET_BOXED "Tag for any boxed data type (useful for equality operations)"
    ExpType ty;
  end ET_BOXED;

  record ET_POLYMORPHIC "Used in MetaModelica polymorphic functions" end ET_POLYMORPHIC;

  record ET_META_ARRAY "Array with MetaModelica semantics"
    ExpType ty;
  end ET_META_ARRAY;

  record ET_NORETCALL "For functions not returning any values." end ET_NORETCALL;

end ExpType;

uniontype ExpVar "A variable is used to describe a complex type which contains a list of variables. See also DAE.Var "
  record COMPLEX_VAR
    String name;
    ExpType tp;
  end COMPLEX_VAR;
end ExpVar;

public 
uniontype Exp "Expressions
    The `Exp\' datatype closely corresponds to the `Absyn.Exp\'
    datatype, but is used for statically analyzed expressions.  It
    includes explicit type promotions and typed (non-overloaded)
    operators. It also contains expression indexing with the `ASUB\'
    constructor.  Indexing arbitrary array expressions is currently
    not supported in Modelica, but it is needed here."
  record ICONST
    Integer integer "Integer constants" ;
  end ICONST;

  record RCONST
    Real real "Real constants" ;
  end RCONST;

  record SCONST
    String string "String constants" ;
  end SCONST;

  record BCONST
    Boolean bool "Bool constants" ;
  end BCONST;

  record CREF "component references, e.g. a.b{2}.c{1}"
    ComponentRef componentRef;
    ExpType ty;
  end CREF;

  record BINARY "Binary operations, e.g. a+4" 
    Exp exp1;
    Operator operator;
    Exp exp2; 
  end BINARY;

  record UNARY "Unary operations, -(4x)"
    Operator operator;
    Exp exp; 
  end UNARY;

  record LBINARY "Logical binary operations: and, or"
    Exp exp1;
    Operator operator;
    Exp exp2; 
  end LBINARY;

  record LUNARY "Logical unary operations: not"
    Operator operator;
    Exp exp; 
  end LUNARY;

  record RELATION "Relation, e.g. a <= 0"
    Exp exp1;
    Operator operator;
    Exp exp2; 
  end RELATION;

  record IFEXP "If expressions" 
    Exp expCond;
    Exp expThen;
    Exp expElse;
  end IFEXP;

  record CALL
    Absyn.Path path;
    list<Exp> expLst;
    Boolean tuple_ "tuple" ;
    Boolean builtin "builtin Function call" ;
    ExpType ty "The type of the return value, if several return values this is undefined";
    Boolean inline;
  end CALL;
  
  record PARTEVALFUNCTION
    Absyn.Path path;
    list<Exp> expList;
    ExpType ty;
  end PARTEVALFUNCTION;

  record ARRAY
    ExpType ty;
    Boolean scalar "scalar for codegen" ;
    list<Exp> array "Array constructor, e.g. {1,3,4}" ;
  end ARRAY;

  record MATRIX
    ExpType ty;
    Integer integer;
    list<list<tuple<Exp, Boolean>>> scalar "scalar Matrix constructor. e.g. {1,0;0,1}" ;
  end MATRIX;

  record RANGE
    ExpType ty;
    Exp exp;
    Option<Exp> expOption;
    Exp range "Range constructor, e.g. 1:0.5:10" ;
  end RANGE;

  record TUPLE
    list<Exp> PR "PR. Tuples, used in func calls returning several 
								  arguments" ;
  end TUPLE;

  record CAST "Cast operator"
    ExpType ty;
    Exp exp;
  end CAST;

  record ASUB "Array subscripts"
    Exp exp;
    list<Exp> sub;
  end ASUB;

  record SIZE "The size operator"
    Exp exp;
    Option<Exp> sz;
  end SIZE;

  record CODE "Modelica AST constructor"
    Absyn.CodeNode code;
    ExpType ty;
  end CODE;

  record REDUCTION "e.g. sum(i*i+1) for i in 1:4"
    Absyn.Path path "array, sum,..";
    Exp expr "expr, e.g i*i+1" ;
    Ident ident "e.g. i";
    Exp range "range Reduction expression e.g. 1:4" ;
  end REDUCTION;

  record END "array index to last element, e.g. a{end}:=1;" end END;

	record VALUEBLOCK "Valueblock expression"
	  ExpType ty;
    list<Element> localDecls; // TODO: Do this in a better way
    list<Statement> body;
		Exp result;	
  end VALUEBLOCK;  
  
  /* Part of MetaModelica extension. KS */
  record LIST "MetaModelica list"
    ExpType ty;
    list<Exp> valList;
  end LIST;

  record CONS "MetaModelica list cons"
    ExpType ty;
    Exp car;
    Exp cdr;
  end CONS;

  record META_TUPLE
    list<Exp> listExp;
  end META_TUPLE;

  record META_OPTION
    Option<Exp> exp;
  end META_OPTION;
  
  /*
  	Holds a metarecord call
   	<metarecord>(<args>)
  */
  record METARECORDCALL //Metamodelica extension, simbj
    Absyn.Path path;    
    list<Exp> args;
    list<String> fieldNames;
    // SCode.Path name; //Name of the uniontype - removed 2009-09-18 /sjoelund
    Integer index; //Index in the uniontype
  end METARECORDCALL;
  
  /* --- */

end Exp;

public 
uniontype Operator "Operators which are overloaded in the abstract syntax are here
    made type-specific.  The integer addition operator (`ADD(INT)\')
    and the real addition operator (`ADD(REAL)\') are two distinct
    operators."
  record ADD
    ExpType ty;
  end ADD;

  record SUB
    ExpType ty;
  end SUB;

  record MUL
    ExpType ty;
  end MUL;

  record DIV
    ExpType ty;
  end DIV;

  record POW
    ExpType ty;
  end POW;

  record UMINUS
    ExpType ty;
  end UMINUS;

  record UPLUS
    ExpType ty;
  end UPLUS;

  record UMINUS_ARR
    ExpType ty;
  end UMINUS_ARR;

  record UPLUS_ARR
    ExpType ty;
  end UPLUS_ARR;

  record ADD_ARR
    ExpType ty;
  end ADD_ARR;

  record SUB_ARR
    ExpType ty;
  end SUB_ARR;

  record MUL_ARR
    ExpType ty;
  end MUL_ARR;

  record DIV_ARR
    ExpType ty;
  end DIV_ARR;

  record MUL_SCALAR_ARRAY
    ExpType ty "a  { b, c }" ;
  end MUL_SCALAR_ARRAY;

  record MUL_ARRAY_SCALAR
    ExpType ty "{a, b}  c" ;
  end MUL_ARRAY_SCALAR;

  record ADD_SCALAR_ARRAY
    ExpType ty "a  { b, c }" ;
  end ADD_SCALAR_ARRAY;

  record ADD_ARRAY_SCALAR
    ExpType ty "{a, b}  c" ;
  end ADD_ARRAY_SCALAR;

  record SUB_SCALAR_ARRAY
    ExpType ty "a  { b, c }" ;
  end SUB_SCALAR_ARRAY;

  record SUB_ARRAY_SCALAR
    ExpType ty "{a, b}  c" ;
  end SUB_ARRAY_SCALAR;

  record MUL_SCALAR_PRODUCT
    ExpType ty "{a, b}  {c, d}" ;
  end MUL_SCALAR_PRODUCT;

  record MUL_MATRIX_PRODUCT
    ExpType ty "{{..},..}  {{..},{..}}" ;
  end MUL_MATRIX_PRODUCT;

  record DIV_ARRAY_SCALAR
    ExpType ty "{a, b} / c" ;
  end DIV_ARRAY_SCALAR;

  record DIV_SCALAR_ARRAY
    ExpType ty "a  { b, c }" ;
  end DIV_SCALAR_ARRAY;

  record POW_ARRAY_SCALAR
    ExpType ty "{a, b} / c" ;
  end POW_ARRAY_SCALAR;

  record POW_SCALAR_ARRAY
    ExpType ty "a  { b, c }" ;
  end POW_SCALAR_ARRAY;

  record POW_ARR
    ExpType ty;  /*Power of a matrix*/
  end POW_ARR;

  record POW_ARR2
    ExpType ty;  /*Elementwise power of arrays*/
  end POW_ARR2;

  record AND end AND;

  record OR end OR;

  record NOT end NOT;

  record LESS
    ExpType ty;
  end LESS;

  record LESSEQ
    ExpType ty;
  end LESSEQ;

  record GREATER
    ExpType ty;
  end GREATER;

  record GREATEREQ
    ExpType ty;
  end GREATEREQ;

  record EQUAL
    ExpType ty;
  end EQUAL;

  record NEQUAL
    ExpType ty;
  end NEQUAL;

  record USERDEFINED
    Absyn.Path fqName "The FQ name of the overloaded operator function" ;
  end USERDEFINED;

end Operator;

public 
uniontype ComponentRef "- Component references
    CREF_QUAL(...) is used for qualified component names, e.g. a.b.c
    CREF_IDENT(..) is used for non-qualifed component names, e.g. x 
"
  record CREF_QUAL
    Ident ident;
    ExpType identType;
    list<Subscript> subscriptLst;
    ComponentRef componentRef;
  end CREF_QUAL;

  record CREF_IDENT
    Ident ident;
    ExpType identType;
    list<Subscript> subscriptLst;
  end CREF_IDENT;

  record WILD end WILD;

end ComponentRef;

public 
uniontype Subscript "The `Subscript\' and `ComponentRef\' datatypes are simple
  translations of the corresponding types in the `Absyn\' module."
  record WHOLEDIM "a{:,1}" end WHOLEDIM;

  record SLICE
    Exp exp "a{1:3,1}, a{1:2:10,2}" ;
  end SLICE;

  record INDEX
    Exp exp "a[i+1]" ;
  end INDEX;

end Subscript;
/* -- End Exp.mo -- */

end DAE;

