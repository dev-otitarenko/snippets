declare @catalog nvarchar(250);
declare @schema nvarchar(250);
declare @tbl nvarchar(250);
DECLARE i CURSOR LOCAL FAST_FORWARD FOR select
                                        TABLE_CATALOG,
                                        TABLE_SCHEMA,
                                        TABLE_NAME
                                        from INFORMATION_SCHEMA.TABLES
                                        where
                                        TABLE_TYPE = 'BASE TABLE'
                                        AND TABLE_NAME != 'sysdiagrams'
                                        AND TABLE_NAME != '__RefactorLog'
										AND NOT TABLE_NAME like 'oauth%'

OPEN i;
FETCH NEXT FROM i INTO @catalog, @schema, @tbl;
WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @sql NVARCHAR(MAX) = N'UPDATE STATISTICS [' + @catalog + '].[' + @schema + '].[' + @tbl + '];'
        /* Make sure these are the commands you want to execute before executing */
        PRINT 'Executing statement: ' + @sql
        EXECUTE sp_executesql @sql
        FETCH NEXT FROM i INTO @catalog, @schema, @tbl;
    END
CLOSE i;
DEALLOCATE i;

EXEC sp_updatestats;