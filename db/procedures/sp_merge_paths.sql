--------------------------------------------------------------------------------
--  Copyright 2007-2008 Codehaus Foundation
--
--  Licensed under the Apache License, Version 2.0 (the "License");
--  you may not use this file except in compliance with the License.
--  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
--  Unless required by applicable law or agreed to in writing, software
--  distributed under the License is distributed on an "AS IS" BASIS,
--  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--  See the License for the specific language governing permissions and
--  limitations under the License.
--------------------------------------------------------------------------------


-- select * from paths where path like '%A%' order by id asc limit 1;
-- select sp_merge_paths('/MANAGE_EMAIL/SCM%40SXC.CODEHAUS.ORG');

-- select sp_merge_paths(path) from paths where path ~ '%[A-Z]%' order by id asc limit 1;
-- select sp_merge_paths(path) from paths where path like '%A%'  order by id asc limit 1;
-- select count(*) from paths where path ~ '[A-Z]';

-- If the caller supplies the normalized version of the path; then we use that. Assumes they know what
-- they are doing (i.e. lower case etc)
CREATE OR REPLACE FUNCTION sp_merge_paths(source_path varchar, target_path varchar) RETURNS integer AS $$
  DECLARE source PATHS%ROWTYPE;
  DECLARE source_path_total PATH_TOTALS%ROWTYPE;
  DECLARE target PATHS%ROWTYPE;
  DECLARE target_path_total PATH_TOTALS%ROWTYPE;
  DECLARE msg VARCHAR;
BEGIN
  RAISE NOTICE 'Processing %', source_path;
  
  SELECT * INTO source FROM PATHS WHERE path = source_path;
  SELECT * INTO target FROM PATHS WHERE path = target_path;
  
  IF source IS NULL AND target IS NULL THEN
    RETURN NULL;
  END IF;
    
  IF source IS NULL AND target IS NOT NULL THEN
    RETURN NULL;
  END IF;
    
  IF source IS NOT NULL AND target IS NULL THEN
    RAISE NOTICE 'No existing targets found; normalizing to %', target_path;
    UPDATE PATHS SET path = target_path WHERE id = source.id;
    RETURN source.id;
  END IF;
  
  IF (source.id = target.id) THEN
    RETURN target.id;
  END IF;
    
  RAISE NOTICE 'Moving data from % to %', source.id, target.id;
  FOR source_path_total IN SELECT * FROM PATH_TOTALS WHERE path_id = source.id LOOP
    
    SELECT * INTO target_path_total 
    FROM PATH_TOTALS 
    WHERE path_id = target.id
      AND vhost_id = source_path_total.vhost_id
      AND period_id = source_path_total.period_id
      LIMIT 1;
      
    -- If we can't find another target, flip this one
    -- If we find another target, merge
    IF target_path_total IS NULL THEN
      UPDATE PATH_TOTALS SET PATH_ID = target.id WHERE ID = source_path_total.id;
    ELSE
      UPDATE PATH_TOTALS TPT
      SET 
        response_count = response_count + source_path_total.response_count,
        response_bytes = response_bytes + source_path_total.response_bytes,
        response_bytes_square = response_bytes_square + source_path_total.response_bytes_square,
        response_time = response_time + source_path_total.response_time,
        response_time_square = response_time_square + source_path_total.response_time_square
      WHERE ID = target_path_total.id;
      
    END IF;
  END LOOP;

  DELETE FROM PATH_TOTALS 
  WHERE path_id = source.id;
    
  DELETE FROM PATHS
  WHERE id = source.id;

  RETURN target.id;
END;
$$ LANGUAGE plpgsql;
