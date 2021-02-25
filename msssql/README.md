# Disable all constraints

```
DECLARE @sql NVARCHAR(MAX) = N'';

;WITH x AS 
(
  SELECT DISTINCT obj = 
      QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + '.' 
    + QUOTENAME(OBJECT_NAME(parent_object_id)) 
  FROM sys.foreign_keys
)
SELECT @sql += N'ALTER TABLE ' + obj + ' NOCHECK CONSTRAINT ALL;
' FROM x;

EXEC sp_executesql @sql;
```

# Delete all data from all tables

```
SELECT 'USE [' + db_name() +']';
;WITH a AS 
(
     SELECT 0 AS lvl, 
            t.object_id AS tblID 
     FROM sys.TABLES t
     WHERE t.is_ms_shipped = 0
       AND t.object_id NOT IN (SELECT f.referenced_object_id 
                               FROM sys.foreign_keys f)
     UNION ALL

     SELECT a.lvl + 1 AS lvl, 
            f.referenced_object_id AS tblId
     FROM a
     INNER JOIN sys.foreign_keys f ON a.tblId = f.parent_object_id 
                                   AND a.tblID <> f.referenced_object_id
)
SELECT 
    'Delete from ['+ object_schema_name(tblID) + '].[' + object_name(tblId) + ']' 
FROM a
WHERE not a.tblID like 'oauth%'
GROUP BY tblId 
ORDER BY MAX(lvl),1
```

# Enable all constraints

```
DECLARE @sql NVARCHAR(MAX) = N'';

;WITH x AS 
(
  SELECT DISTINCT obj = 
      QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + '.' 
    + QUOTENAME(OBJECT_NAME(parent_object_id)) 
  FROM sys.foreign_keys
)
SELECT @sql += N'ALTER TABLE ' + obj + ' WITH CHECK CHECK CONSTRAINT ALL;
' FROM x;

EXEC sp_executesql @sql;
```
