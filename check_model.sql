create or replace function check_model(raw json) returns bool as $$

  var checkModel = function(model) {
    if (!model.date) {
      return 'date not set';
    }
    if (!model.desc) {
      return 'description missing';
    }
    if (model.desc.length < 5) {
      return 'description too short';
    }
    if (model.desc.length > 100) {
      return 'description too long';
    }
    if (!(model.bumpCount >= 0)) {
      return 'bump count not positive';
    }
  };

  return checkModel( JSON.parse(raw) ) === undefined;

$$ LANGUAGE plv8 IMMUTABLE STRICT;

ALTER TABLE hopes ADD CONSTRAINT check_model CHECK (check_model(data));
