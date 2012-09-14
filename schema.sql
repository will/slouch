create extension plv8;
create extension "uuid-ossp";

create or replace function valid_json(json text)
returns bool as $$
  try { JSON.parse(json); return true }
  catch(e) { return false }
$$ LANGUAGE plv8 IMMUTABLE STRICT;
create domain json
  as text check(valid_json(VALUE));

CREATE TABLE hopes (
  id uuid primary key default (uuid_generate_v4())
  , data json);
