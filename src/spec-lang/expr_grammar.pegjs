// Top-level rules

Annotation =
    StartingWhiteSpace
    natspecPrefix: ('@custom:scribble' PrimitiveWhiteSpace*)?
    prefix: '#'
    annotation: (
        Invariant
        / If_Succeeds
        / If_Updated
        / If_Assigned
        / UserFunctionDefinition
        / Assert
        / Try
        / Require
        / LetAnnotation
        / Macro
    )
    .* {
        // Dummy statements to shut up unused variable warnings in tsc
        error;
        expected;
        return annotation;
    }

Expression = LetExpression

// Non-top-level rules

MDExpression =
    HexLiteral
    / Identifier
    / Number
    / BooleanLiteral
    / StringLiteral

MDIdentifier = chars:([a-zA-Z_][a-zA-Z0-9_]*) { return text(); }

MDExpressionList =
    head: (
        ":" key: MDIdentifier __ expr: MDExpression {
            return [key, expr]
        }
    )
    tail: (
        __ "," __ ":" key: MDIdentifier __ expr: MDExpression {
            return [key, expr];
        }
    )* {
        const base: {[keys: string]: SNode } = {};
        base[head[0]] = head[1];

        return tail.reduce(
            (acc: any, el: any) => {
                acc[el[0]] = el[1]
                return acc;
            },
            base
        );
    }


AnnotationMD
    = "{" __  exprs: MDExpressionList? __ "}" { return exprs === null ? undefined : exprs; }
    / msg: StringLiteral { return { msg } }

Invariant =
    type: INVARIANT __ md: AnnotationMD? __ expr: Expression __ ";" {
        return new SProperty(
            type as AnnotationType,
            expr,
            md === null ? undefined : md,
            makeRange(location(), options as ParseOptions)
        );
    }

Range =
    start: Expression __ "..."  __ end: Expression { return [start, end]; }
    / expression: Expression { return expression; }


For_All =
    type: FORALL __ "(" __ itr_type: Type __ iterator: Identifier __ IN __ range: Range __ ")" __ expr: Expression {
        if (Array.isArray(range)) {
            const [start, end] = range;

            return new SForAll(itr_type, iterator, expr, start, end, undefined, makeRange(location(), options as ParseOptions));
        }

        return new SForAll(itr_type, iterator, expr, undefined, undefined, range, makeRange(location(), options as ParseOptions));
    }

If_Succeeds =
    type: IF_SUCCEEDS __ md: AnnotationMD? __ expr: Expression __ ";" {
        return new SProperty(
            type as AnnotationType,
            expr,
            md === null ? undefined : md,
            makeRange(location(), options as ParseOptions)
        );
    }

Assert =
    type: ASSERT __ md: AnnotationMD? __ expr: Expression __ ";" {
        return new SProperty (
            type as AnnotationType,
            expr,
            md === null ? undefined : md,
            makeRange(location(), options as ParseOptions)
        );
    }

LetAnnotation =
    type: LET __ md: AnnotationMD? __ name: Identifier __ ":=" __ expr: Expression __ ";" {
        return new SLetAnnotation(
            type as AnnotationType,
            name,
            expr,
            md === null ? undefined : md,
            makeRange(location(), options as ParseOptions)
        );
    }

Try =
    type: TRY __ md: AnnotationMD? __ expr: Expression __ ";" {
        return new SProperty (
            type as AnnotationType,
            expr,
            md === null ? undefined : md,
            makeRange(location(), options as ParseOptions)
        );
    }

Require =
    type: REQUIRE __ md: AnnotationMD? __ expr: Expression __ ";" {
        return new SProperty (
            type as AnnotationType,
            expr,
            md === null ? undefined : md,
            makeRange(location(), options as ParseOptions)
        );
    }

DatastructurePath_Index =
    "[" __ id: Identifier __"]" { return id; }

DatastructurePath_Field =
    "." id: Identifier { return id.name; }

IndexPath =
    (DatastructurePath_Field / DatastructurePath_Index)*

// TODO: Eventually remove hacky '/' from if_updated rule. This is to work around
// limitations in Solidity - it throws if it sees natspec on internal state vars
If_Updated =
    ("/" __)? type: IF_UPDATED __ md: AnnotationMD? __ expr: Expression __ ";" {
        return new SIfUpdated(
            expr,
            [],
            md === null ? undefined : md,
            makeRange(location(), options as ParseOptions)
        );
    }

If_Assigned =
    ("/" __)? type: IF_ASSIGNED path: IndexPath __ md: AnnotationMD? __ expr: Expression __ ";" {
        return new SIfAssigned(
            expr,
            path,
            md === null ? undefined : md,
            makeRange(location(), options as ParseOptions)
        );
    }

TypedArgs =
    head: (
        type: Type __ name: Identifier {
            return [name, type];
        }
    )
    tail: (
        __ "," __ type: Type __ name: Identifier {
            return [name, type];
        }
    )* {
        return tail.reduce(
            (acc: any, el: any) => {
                acc.push(el);
                
                return acc;
            },
            [head]
        );
    }

UserFunctionDefinition =
    type: DEFINE __ md: AnnotationMD? __ name: Identifier __ "(" __ args: TypedArgs? __ ")" __ returnType: Type __ "=" __ body: Expression {
        return new SUserFunctionDefinition(
            name,
            args === null ? [] : args,
            returnType,
            body,
            md === null ? undefined : md,
            makeRange(location(), options as ParseOptions)
        );
    }

IdentiferList =
    head: (Identifier)
    tail: (__ "," __ Identifier)* {
        return tail.reduce(
            (acc: any, el: any) => {
                acc.push(el[3]);

                return acc;
            },
            [head]
        );
    }

Macro = 
    type: MACRO __ md: AnnotationMD? name: Identifier __ "(" __ args: IdentiferList? __ ")" ";" {
        return new SMacro(
            name,
            args === null ? [] : args,
            md === null ? undefined : md,
            makeRange(location(), options as ParseOptions)
        );
    }

// Terminals

PrimitiveWhiteSpace =
    "\t"
    / "\v"
    / "\f"
    / " "
    / "\u00A0"
    / "\uFEFF"
    / Zs

WhiteSpace "whitespace" =
    PrimitiveWhiteSpace
    / LineTerminator PrimitiveWhiteSpace* ("*" / "///")

StartingWhiteSpace "whitespace" =
    PrimitiveWhiteSpace* LineTerminator? PrimitiveWhiteSpace* ("*" / "///")? __

// Separator, Space

Zs =
    [\u0020\u00A0\u1680\u2000-\u200A\u202F\u205F\u3000]

LineTerminator =
    [\n\r\u2028\u2029]

LineTerminatorSequence =
    "\n"
    / "\r\n"
    / "\r"
    / "\u2028"
    / "\u2029"

__ =
    (WhiteSpace / LineTerminator)*

TRUE = "true"
FALSE = "false"
OLD = "old"
LET = "let"
IN = "in"
BOOL = "bool"
HEX = "hex"
ADDRESS = "address"
PAYABLE = "payable"
BYTES = "bytes"
STRING = "string"
BYTE = "byte"
MEMORY = "memory"
STORAGE = "storage"
CALLDATA = "calldata"
MAPPING = "mapping"
FUNCTION = "function"
RETURNS = "returns"
EXTERNAL = "external"
INTERNAL = "internal"
PURE = "pure"
VIEW = "view"
NONPAYABLE = "nonpayable"
RESULT = "$result"
INVARIANT = "invariant"
IF_SUCCEEDS = "if_succeeds"
ASSERT = "assert"
IF_UPDATED = "if_updated"
IF_ASSIGNED = "if_assigned"
DEFINE = "define"
FORALL = "forall"
TRY = "try"
REQUIRE = "require"
MACRO = "macro"

Keyword =
    TRUE
    / FALSE
    / OLD
    / LET
    / IN
    / BOOL
    / HEX
    / ADDRESS
    / PAYABLE
    / BYTES
    / BYTE
    / MEMORY
    / STORAGE
    / CALLDATA
    / STRING
    / MAPPING
    / FUNCTION
    / RETURNS
    / EXTERNAL
    / INTERNAL
    / PURE
    / VIEW
    / NONPAYABLE
    / RESULT
    / FORALL

NumberUnit =
    "wei"
    / "gwei"
    / "ether"
    / "seconds"
    / "minutes"
    / "hours"
    / "days"
    / "weeks"

// expression

Identifier =
    !(Keyword ![a-zA-Z0-9_]) id:([a-zA-Z_][a-zA-Z0-9_]*) {
        return new SId(text(), makeRange(location(), options as ParseOptions));
    }

HexDigit =
    [0-9a-f]i

HexNumber =
    "0x"i digits: HexDigit+ {
        const num = digits.join('');

        // 20-byte hex literals are implicitly treated as address constants.
        if (digits.length === 40) {
            return new SAddressLiteral('0x' + num, makeRange(location(), options as ParseOptions));
        }

        return new SNumber(BigInt('0x' + num), 16, makeRange(location(), options as ParseOptions));
    }

DecDigit =
    [0-9]

ExponentIndicator =
    "e" / "E"

SignedInteger =
    [+-]? DecDigit+

ExponentPart =
    ExponentIndicator SignedInteger

DecNumber =
    DecDigit+ ExponentPart? {
        /**
         * Note that bigInt(...).toString() is used here to support scientific notation (1e10).
         * Native bigint is unable to parse such values yet.
         */
        return new SNumber(BigInt(bigInt(text()).toString()), 10, makeRange(location(), options as ParseOptions));
    }

Number =
    value: (HexNumber / DecNumber) unit: (__ NumberUnit)? {
        if (unit === null) {
            return value;
        }

        if (value instanceof SAddressLiteral || value.radix === 16) {
            throw new Error(`Cannot use units with hex literals`);
        }

        return new SNumber(BigInt(value.num), value.radix, makeRange(location(), options as ParseOptions), unit[1]);
    }

BooleanLiteral =
    val: (TRUE / FALSE) {
        return new SBooleanLiteral(text() === "true", makeRange(location(), options as ParseOptions));
    }

HexLiteral =
    HEX '"' val: HexDigit* '"' {
        return new SHexLiteral(val.join(""), makeRange(location(), options as ParseOptions));
    }
    / HEX "'" val: HexDigit* "'" {
        return new SHexLiteral(val.join(""), makeRange(location(), options as ParseOptions));
    }

StringLiteral =
    "'" chars: SingleStringChar* "'" {
        return new SStringLiteral(chars.join(""), makeRange(location(), options as ParseOptions));
    }
    / '"' chars: DoubleStringChar* '"' {
        return new SStringLiteral(chars.join(""), makeRange(location(), options as ParseOptions));
    }

AnyChar =
    .

DoubleStringChar =
    !('"' / "\\" / LineTerminator) AnyChar { return text(); }
    / "\\" sequence: EscapeSequence { return sequence; }
    / LineContinuation

SingleStringChar =
    !("'" / "\\" / LineTerminator) AnyChar { return text(); }
    / "\\" sequence: EscapeSequence { return sequence; }
    / LineContinuation

LineContinuation =
    "\\" LineTerminatorSequence { return ""; }

EscapeSequence =
    CharEscapeSequence
    / "0" !DecDigit { return "\0"; }
    / HexEscapeSequence
    / UnicodeEscapeSequence

CharEscapeSequence =
    SingleEscapeChar
    / NonEscapeChar

SingleEscapeChar =
    "'"
    / '"'
    / "\\"
    / "b"  { return "\b"; }
    / "f"  { return "\f"; }
    / "n"  { return "\n"; }
    / "r"  { return "\r"; }
    / "t"  { return "\t"; }
    / "v"  { return "\v"; }

NonEscapeChar =
    !(EscapeChar / LineTerminator) AnyChar { return text(); }

EscapeChar =
    SingleEscapeChar
    / DecDigit
    / "x"
    / "u"

HexEscapeSequence =
    "x" digits: $(HexDigit HexDigit) {
        return String.fromCharCode(parseInt(digits, 16));
    }

UnicodeEscapeSequence
    = "u" digits: $(HexDigit HexDigit HexDigit HexDigit) {
        return String.fromCharCode(parseInt(digits, 16));
    }

PrimaryExpression =
    HexLiteral
    / Identifier
    / Number
    / BooleanLiteral
    / StringLiteral
    / (
        "(" __ expr: Expression __ ")" { return expr; }
    )
    / (RESULT { return new SResult(makeRange(location(), options as ParseOptions)); })
    / For_All

OldExpression =
    OLD __ "(" __ expr: Expression __ ")" {
        return new SUnaryOperation("old", expr, makeRange(location(), options as ParseOptions));
    }
    / PrimaryExpression

MemberAccessExpression =
    head: (OldExpression / Type)
    tail: (
        __ "." __ property: Identifier { return { property: property }; }
        / __ "[" __ index: Expression __ "]" { return { index: index }; }
        / "(" __ args: ArgumentList? __ ")" { return { args: args } ; }
    )* {
        return tail.reduce(
            (acc: any, el: any) => {
                if (el.hasOwnProperty("index")) {
                    return new SIndexAccess(acc, el.index, makeRange(location(), options as ParseOptions));
                }

                if (el.hasOwnProperty("property")) {
                    return new SMemberAccess(acc, el.property.name, makeRange(location(), options as ParseOptions));
                }

                const args = el.args === null ? [] : el.args;

                return new SFunctionCall(acc, args, makeRange(location(), options as ParseOptions));
            },
            head
        );
    }

ArgumentList =
    head: (Expression)
    tail: (__ "," __ expr: Expression)* {
        return tail.reduce(
            (acc: any, el: any) => {
                acc.push(el[3]);

                return acc;
            },
            [head]
        );
    }

UnaryExpression =
    (
        operator: UnaryOperator __ subexp: UnaryExpression {
            return new SUnaryOperation(operator as UnaryOperator, subexp, makeRange(location(), options as ParseOptions));
        }
    )
    / MemberAccessExpression

UnaryOperator =
    "-"
    / "!"

PowerExpression =
    head: UnaryExpression
    tail: (__ op: "**" __ UnaryExpression)* {
        return buildBinaryExpression(head, tail, makeRange(location(), options as ParseOptions));
    }

MultiplicativeOperator =
    $("*") { return text() as MultiplicativeBinaryOperator; }
    / $("/") { return text() as MultiplicativeBinaryOperator; }
    / $("%") { return text() as MultiplicativeBinaryOperator; }

MultiplicativeExpression =
    head: PowerExpression
    tail: (__ op: MultiplicativeOperator __ PowerExpression)* {
        return buildBinaryExpression(head, tail, makeRange(location(), options as ParseOptions));
    }

AdditiveOperator =
    $("+") { return text() as AdditiveBinaryOperator; }
    / $("-") { return text() as AdditiveBinaryOperator; }

AdditiveExpression =
    head: MultiplicativeExpression
    tail: (__ AdditiveOperator __ MultiplicativeExpression)* {
        return buildBinaryExpression(head, tail, makeRange(location(), options as ParseOptions));
    }

ShiftExpression =
    head: AdditiveExpression
    tail: (__ ShiftOperator __ AdditiveExpression)* {
        return buildBinaryExpression(head, tail, makeRange(location(), options as ParseOptions));
    }

ShiftOperator =
    $("<<") { return text() as ShiftBinaryOperator; }
    / $(">>") { return text() as ShiftBinaryOperator; }

BitwiseANDExpression =
    head: ShiftExpression
    tail: (__ "&" __ ShiftExpression)* {
        return buildBinaryExpression(head, tail, makeRange(location(), options as ParseOptions));
    }

BitwiseXORExpression =
    head: BitwiseANDExpression
    tail: (__ "^" __ BitwiseANDExpression)* {
        return buildBinaryExpression(head, tail, makeRange(location(), options as ParseOptions));
    }

BitwiseORExpression =
    head: BitwiseXORExpression
    tail: (__ "|" __ BitwiseXORExpression)* {
        return buildBinaryExpression(head, tail, makeRange(location(), options as ParseOptions));
    }

RelationalExpression =
    (
        left: BitwiseORExpression __ op: RelationalOperator __ right: BitwiseORExpression {
            return new SBinaryOperation(left, op as RelationalBinaryOperator, right, makeRange(location(), options as ParseOptions));
        }
    )
    / BitwiseORExpression

RelationalOperator =
    '<=' { return text(); }
    / '>=' { return text(); }
    / '<' { return text(); }
    / '>' { return text(); }

EqualityExpression =
    head: RelationalExpression
    tail: (__ EqualityOperator __ RelationalExpression)* {
        return buildBinaryExpression(head, tail, makeRange(location(), options as ParseOptions));
    }

EqualityOperator =
    "==" { return text(); }
    / "!=" { return text(); }

LogicalANDExpression =
    head: EqualityExpression
    tail: (__ "&&" __ EqualityExpression)* {
        return buildBinaryExpression(head, tail, makeRange(location(), options as ParseOptions));
    }

LogicalORExpression =
    head: LogicalANDExpression
    tail: (__ "||" __ LogicalANDExpression)* {
        return buildBinaryExpression(head, tail, makeRange(location(), options as ParseOptions));
    }

ImplicationExpression =
    precedent: LogicalORExpression
    tail: (__ "==>" __  ImplicationExpression)* {
        return buildBinaryExpression(precedent, tail, makeRange(location(), options as ParseOptions));
    }

ConditionalExpression =
    head: ImplicationExpression
    tail: (
        __ "?" __ trueExpr: Expression __ ":" __ falseExpr: Expression {
            return [trueExpr, falseExpr];
        }
    )* {
        return tail.reduce(
            (acc: any, [trueExpr, falseExpr]: any) => new SConditional(acc, trueExpr, falseExpr, makeRange(location(), options as ParseOptions)),
            head
        )
    }

LetExpression =
    LET __ bindings: LhsBindings __ ":=" __ rhs: Expression __ IN __ inExpr: Expression {
        return new SLet(bindings, rhs, inExpr, makeRange(location(), options as ParseOptions));
    }
    / ConditionalExpression

LhsBindings =
    head: Identifier __ tail: ("," __ id: Identifier __ { return id; })* {
        return tail.reduce(
            (acc: any, cur: any) => {
                acc.push(cur);
                
                return acc;
            },
            [head]
        );
    }

// Types

Type =
    FunctionType

SimpleType =
    BoolType
    / AddressType
    / IntType
    / BytesType
    / FixedSizeBytesType
    / StringType
    / UserDefinedType

BoolType =
    BOOL {
        return new BoolType(makeRange(location(), options as ParseOptions))
    }

AddressType =
    ADDRESS __ payable:(PAYABLE?) {
        return new AddressType(payable !== null, makeRange(location(), options as ParseOptions));
    }

IntType =
    unsigned: ("u"?) "int" width: (Number?) {
        const isSigned = unsigned === null;
        const bitWidth = width === null ? 256 : Number(width.num);

        return new IntType(bitWidth, isSigned, makeRange(location(), options as ParseOptions));
    }

FixedSizeBytesType =
    BYTES width: Number {
        return new FixedBytesType(Number(width.num), makeRange(location(), options as ParseOptions));
    }
    / BYTE {
        return new FixedBytesType(1, makeRange(location(), options as ParseOptions));
    }

BytesType =
    BYTES !Number {
        return new BytesType(makeRange(location(), options as ParseOptions));
    }

StringType =
    STRING {
        return new StringType(makeRange(location(), options as ParseOptions));
    }

UserDefinedType =
    base: Identifier "." field: Identifier {
        return makeUserDefinedType(base.name + '.' + field.name, options as ParseOptions, makeRange(location(), options as ParseOptions));
    }
    / name: Identifier {
        return makeUserDefinedType(name.name, options as ParseOptions, makeRange(location(), options as ParseOptions));
    }

ArrayType =
    head: SimpleType
    tail: ( __ "[" __ size: Number? __ "]")* {
        return tail.reduce(
            (acc: any, cur: any) => {
                const size = cur[3];

                return new ArrayType(
                    acc,
                    size === null ? undefined : BigInt(size.num),
                    makeRange(location(), options as ParseOptions)
                );
            },
            head
        )
    }

MappingType =
    MAPPING __ "(" __ keyType: SimpleType __ "=>" __ valueType: MappingType __ ")" {
        return new MappingType(keyType, valueType, makeRange(location(), options as ParseOptions));
    }
    / ArrayType

DataLocation =
    MEMORY
    / STORAGE
    / CALLDATA

PointerType =
    toType: MappingType __ dataLocation: (DataLocation?) {
        return dataLocation === null
            ? toType
            : new PointerType(toType, dataLocation as DataLocation, undefined, makeRange(location(), options as ParseOptions));
    }

TypeList =
    head: PointerType
    tail: (__ "," __ PointerType)* {
        return tail.reduce(
            (acc: any, cur: any) => {
                acc.push(cur[3]);
                
                return acc;
            },
            [head]
        );
    }

FunctionVisibility =
    EXTERNAL
    / INTERNAL

FunctionMutability =
    PURE
    / VIEW
    / PAYABLE
    / NONPAYABLE

FunctionDecorator =
    FunctionVisibility
    / FunctionMutability

FunctionDecoratorList =
    head: FunctionDecorator
    tail: (__ FunctionDecorator)* {
        return tail.reduce(
            (acc: any, cur: any) => {
                acc.push(cur[1]);

                return acc;
            },
            [head]
        )
    }

FunctionType =
    FUNCTION __ "(" __ args: TypeList? __ ")" __ decorators: (FunctionDecoratorList?) __ returns: (RETURNS __ "(" __ (TypeList) __ ")")? {
        const argTs = args === null ? [] : args;
        const retTs = returns === null ? [] : returns[4];
        const decoratorsList = decorators === null ? [] : decorators;

        const [visibility, mutability] = getFunctionAttributes(decoratorsList);

        return new FunctionType(undefined, argTs, retTs, visibility, mutability, makeRange(location(), options as ParseOptions));
    }
    / PointerType
