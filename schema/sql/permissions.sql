-- Permissions

-- Requires setting the variable 'database_name' (this is to accommodate test scripts)
--------------------------------------------------------------------------------

-- TODO: Consider using groups?


-- Public Schema Permissions
--------------------------------------------------------------------------------
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO heimdall;
GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA public TO heimdall;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO heimdall;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO heimdall_ro;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO heimdall_ro;

-- This should allow us to use all the functions we need to; any that
-- modify tables should be blocked by the lack of mutation permissions
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO heimdall_ro;

-- The read-only user is intended for actual humans to use
-- interactively for debugging purposes; sometimes creating temporary
-- tables is a nice thing to be able to do in that situation.  We
-- don't need temporary tables as the 'heimdall' user, though; that's
-- for the API server.
GRANT TEMPORARY ON DATABASE :database_name TO heimdall_ro;

-- Debug Schema Permissions
--------------------------------------------------------------------------------
GRANT USAGE ON SCHEMA debug TO heimdall;
GRANT USAGE ON SCHEMA debug TO heimdall_ro;

-- This is really for granting SELECT on all VIEWs, but there isn't a
-- bulk GRANT command for views per se.  Also, we're not going to have
-- tables in this schema.
GRANT SELECT ON ALL TABLES IN SCHEMA debug TO heimdall;
GRANT SELECT ON ALL TABLES IN SCHEMA debug TO heimdall_ro;
