-- ------------------------------
-- OPTION
-- ------------------------------

OPTION IMPORT;

-- ------------------------------
-- PARAMS
-- ------------------------------

DEFINE PARAM $possible_attribute_kinds VALUE ['Note', 'Text', 'Number', 'Select', 'MultiSelect', 'Checkbox', 'Datetime'] PERMISSIONS FULL;

-- ------------------------------
-- FUNCTIONS
-- ------------------------------

DEFINE FUNCTION fn::attribute::check_type($kind: string) { RETURN IF $kind == 'Select' { 'Select' } ELSE IF $kind == 'MultiSelect' { 'MultiSelect' } ELSE IF $kind == 'Checkbox' { 'Checkbox' } ELSE IF $kind == 'Text' { 'Text' } ELSE IF $kind == 'Number' { 'Number' } ELSE IF $kind == 'Date' { 'Date' } ELSE IF $kind == 'Time' { 'Time' } ELSE IF $kind == 'DateTime' { 'DateTime' } ELSE IF $kind == 'Number' { 'Number' } ELSE IF $kind == 'Date' { 'Date' } ELSE IF $kind == 'Time' { 'Time' } ELSE IF $kind == 'DateTime' { 'DateTime' }; } PERMISSIONS FULL;
DEFINE FUNCTION fn::attribute::equal::checkbox($kind: string, $query: string) { RETURN $kind == 'Checkbox' AND $query == out.name; } PERMISSIONS FULL;
DEFINE FUNCTION fn::attribute::equal::date($kind: string, $query: datetime) { RETURN $kind == 'Date' AND $query == fn::fix_time(out.Date); } PERMISSIONS FULL;
DEFINE FUNCTION fn::attribute::equal::datetime($kind: string, $query: datetime) { RETURN $kind == 'DateTime' AND $query == fn::fix_time(out.DateTime); } PERMISSIONS FULL;
DEFINE FUNCTION fn::attribute::equal::multi_select($kind: string, $query: string) { RETURN $kind == 'MultiSelect' AND $query INSIDE out.MultiSelect; } PERMISSIONS FULL;
DEFINE FUNCTION fn::attribute::equal::number($kind: string, $query: number) { RETURN $kind == 'Number' AND $query == out.Number; } PERMISSIONS FULL;
DEFINE FUNCTION fn::attribute::equal::select($kind: string, $query: string) { RETURN $kind == 'Select' AND $query == out.`Select`; } PERMISSIONS FULL;
DEFINE FUNCTION fn::attribute::equal::text($kind: string, $query: string) { RETURN $kind == 'Text' AND $query == out.Text; } PERMISSIONS FULL;
DEFINE FUNCTION fn::attribute::equal::time($kind: string, $query: datetime) { RETURN $kind == 'Time' AND $query == fn::fix_time(out.Time); } PERMISSIONS FULL;
DEFINE FUNCTION fn::attribute::get_kind($name: string) { RETURN type::record(string::concat('attribute:', $name)).kind; } PERMISSIONS FULL;
DEFINE FUNCTION fn::attribute::in_range::date($kind: string, $start: datetime, $end: datetime) { RETURN $kind == 'Date' AND fn::fix_time(out.Date) INSIDE $start..=$end; } PERMISSIONS FULL;
DEFINE FUNCTION fn::attribute::in_range::datetime($kind: string, $start: datetime, $end: datetime) { RETURN $kind == 'DateTime' AND fn::fix_time(out.DateTime) INSIDE $start..=$end; } PERMISSIONS FULL;
DEFINE FUNCTION fn::attribute::in_range::number($kind: string, $start: number, $end: number) { RETURN $kind == 'Number' AND out.Number INSIDE $start..=$end; } PERMISSIONS FULL;
DEFINE FUNCTION fn::attribute::in_range::time($kind: string, $start: datetime, $end: datetime) { RETURN $kind == 'Time' AND fn::fix_time(out.Time) INSIDE $start..=$end; } PERMISSIONS FULL;
DEFINE FUNCTION fn::fix_time($date: string) { RETURN <datetime> string::concat($date, 'Z'); } PERMISSIONS FULL;
DEFINE FUNCTION fn::validate_attribute_value($data: object) {
LET $def = (SELECT out FROM $data);
IF !$def { THROW 'Attribute validation failed: Linked attribute definition not found.'; };
LET $val = $data.`value`;
LET $kind = $def.kind;
IF $kind == 'Note' { IF !type::is::record($val) OR !string::starts_with(<string> $val, 'note:') { THROW "Attribute validation failed: Value must be a record link to a 'note'."; }; } ELSE IF $kind == 'Text' { IF !type::is::string($val) { THROW 'Attribute validation failed: Value must be a string.'; }; } ELSE IF $kind == 'Number' { IF !type::is::number($val) { THROW 'Attribute validation failed: Value must be a number.'; }; } ELSE IF $kind == 'Checkbox' { IF !type::is::bool($val) { THROW 'Attribute validation failed: Value must be a boolean (true or false).'; }; } ELSE IF $kind == 'Datetime' { IF !type::is::datetime($val) { THROW 'Attribute validation failed: Value must be a datetime.'; }; } ELSE IF $kind == 'Select' {
IF !type::is::string($val) { THROW 'Attribute validation failed: Select value must be a string.'; };
IF !$def.options OR !($val INSIDE $def.options) { THROW 'Attribute validation failed: Value is not a permitted option for this Select attribute.'; };
} ELSE IF $kind == 'MultiSelect' {
IF !type::is::array($val) { THROW 'Attribute validation failed: MultiSelect value must be an array.'; };
IF !$def.options { THROW 'Attribute validation failed: No options defined for this MultiSelect attribute.'; };
IF !array::all($val, |$item: any| $item INSIDE $def.options) { THROW 'Attribute validation failed: One or more values are not permitted options for this MultiSelect attribute.'; };
};
RETURN true;
} PERMISSIONS FULL;

-- ------------------------------
-- ANALYZERS
-- ------------------------------

DEFINE ANALYZER att_analyzer TOKENIZERS BLANK FILTERS LOWERCASE,SNOWBALL(ENGLISH);
DEFINE ANALYZER note_analyzer TOKENIZERS BLANK FILTERS LOWERCASE,SNOWBALL(ENGLISH);

-- ------------------------------
-- TABLE: attribute
-- ------------------------------

DEFINE TABLE attribute TYPE NORMAL SCHEMAFULL PERMISSIONS NONE;

DEFINE FIELD kind ON attribute TYPE string ASSERT $value INSIDE $possible_attribute_kinds PERMISSIONS FULL;
DEFINE FIELD name ON attribute TYPE string PERMISSIONS FULL;
DEFINE FIELD options ON attribute TYPE option<array<string>> PERMISSIONS FULL;
DEFINE FIELD options[*] ON attribute TYPE string PERMISSIONS FULL;

DEFINE INDEX att_names ON attribute FIELDS name SEARCH ANALYZER att_analyzer BM25(1.2,0.75) DOC_IDS_ORDER 100 DOC_LENGTHS_ORDER 100 POSTINGS_ORDER 100 TERMS_ORDER 100 DOC_IDS_CACHE 100 DOC_LENGTHS_CACHE 100 POSTINGS_CACHE 100 TERMS_CACHE 100;


-- ------------------------------
-- TABLE: embedded
-- ------------------------------

DEFINE TABLE embedded TYPE RELATION IN note OUT embedding SCHEMAFULL PERMISSIONS NONE;

DEFINE FIELD in ON embedded TYPE record<note> PERMISSIONS FULL;
DEFINE FIELD out ON embedded TYPE record<embedding> PERMISSIONS FULL;


DEFINE EVENT note_deleted ON embedded WHEN $event = 'DELETE' THEN { DELETE $before.out; };

-- ------------------------------
-- TABLE: embedding
-- ------------------------------

DEFINE TABLE embedding TYPE NORMAL SCHEMAFULL PERMISSIONS NONE;

DEFINE FIELD changed ON embedding TYPE bool PERMISSIONS FULL;
DEFINE FIELD vectors ON embedding TYPE array<float, 384> DEFAULT array::repeat(0.01f, 384) PERMISSIONS FULL;
DEFINE FIELD vectors[*] ON embedding TYPE float PERMISSIONS FULL;

DEFINE INDEX idx_embeddings ON embedding FIELDS vectors MTREE DIMENSION 384 DIST COSINE TYPE F32 CAPACITY 40 DOC_IDS_ORDER 100 DOC_IDS_CACHE 100 MTREE_CACHE 100;


-- ------------------------------
-- TABLE: has_attribute
-- ------------------------------

DEFINE TABLE has_attribute TYPE RELATION IN note OUT attribute ENFORCED SCHEMAFULL PERMISSIONS NONE;

DEFINE FIELD `value` ON has_attribute TYPE any PERMISSIONS FULL;
DEFINE FIELD assigned_at ON has_attribute TYPE datetime DEFAULT time::now() VALUE time::now() PERMISSIONS FULL;
DEFINE FIELD in ON has_attribute TYPE record<note> PERMISSIONS FULL;
DEFINE FIELD out ON has_attribute TYPE record<attribute> PERMISSIONS FULL;

DEFINE INDEX unique_note_attribute ON has_attribute FIELDS in, out UNIQUE;

DEFINE EVENT attribute_validation ON has_attribute WHEN $event == 'CREATE' OR $event == 'UPDATE' THEN fn::validate_attribute_value($after);

-- ------------------------------
-- TABLE: note
-- ------------------------------

DEFINE TABLE note TYPE NORMAL SCHEMAFULL PERMISSIONS NONE;

DEFINE FIELD content ON note TYPE string DEFAULT '' PERMISSIONS FULL;
DEFINE FIELD path ON note TYPE string DEFAULT '' PERMISSIONS FULL;
DEFINE FIELD title ON note TYPE string DEFAULT 'New Note' PERMISSIONS FULL;

DEFINE INDEX note_content ON note FIELDS content, title SEARCH ANALYZER note_analyzer BM25(1.2,0.75) DOC_IDS_ORDER 100 DOC_LENGTHS_ORDER 100 POSTINGS_ORDER 100 TERMS_ORDER 100 DOC_IDS_CACHE 100 DOC_LENGTHS_CACHE 100 POSTINGS_CACHE 100 TERMS_CACHE 100;
DEFINE INDEX note_title ON note FIELDS title SEARCH ANALYZER note_analyzer BM25(1.2,0.75) DOC_IDS_ORDER 100 DOC_LENGTHS_ORDER 100 POSTINGS_ORDER 100 TERMS_ORDER 100 DOC_IDS_CACHE 100 DOC_LENGTHS_CACHE 100 POSTINGS_CACHE 100 TERMS_CACHE 100;

DEFINE EVENT note_create ON note WHEN $event = 'CREATE' THEN {
LET $embedding = (INSERT INTO embedding { changed: true, id: rand::uuid::v7() });
RELATE $value -> embedded -> $embedding;
};
DEFINE EVENT recalculate_embedding ON note WHEN $before.content != $after.content THEN { UPDATE $value->embedded->embedding SET changed = true; };

