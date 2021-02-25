-- Get all existing indexes, but NOT the primary keys
DECLARE cIX CURSOR FOR
   SELECT OBJECT_NAME(SI.Object_ID), SI.Object_ID, SI.Name, SI.Index_ID, SC.name
      FROM Sys.Indexes SI 
         LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS TC ON SI.Name = TC.CONSTRAINT_NAME AND OBJECT_NAME(SI.Object_ID) = TC.TABLE_NAME
         LEFT JOIN SYS.tables TB ON (OBJECT_NAME(SI.Object_ID) = TB.name)
         LEFT JOIN SYS.schemas SC ON (TB.schema_id=SC.schema_id)
      WHERE TC.CONSTRAINT_NAME IS NULL
         AND OBJECTPROPERTY(SI.Object_ID, 'IsUserTable') = 1
      ORDER BY OBJECT_NAME(SI.Object_ID), SI.Index_ID

DECLARE @IxTable SYSNAME
DECLARE @IxTableID INT
DECLARE @IxName SYSNAME
DECLARE @IxID INT
DECLARE @IxSchema SYSNAME
DECLARE @PKSQL VARCHAR(50)

-- Loop through all indexes
OPEN cIX
FETCH NEXT FROM cIX INTO @IxTable, @IxTableID, @IxName, @IxID, @IxSchema
WHILE (@@FETCH_STATUS = 0)
BEGIN
   DECLARE @IXSQL NVARCHAR(4000) 
   SET @PKSQL = ''
   SET @IXSQL = 'IF NOT EXISTS(SELECT TOP 1 1 FROM sys.indexes WHERE name=''' + @IxName + ''' AND object_id = OBJECT_ID(''' + @IxSchema + '.' + @IxTable + '''))'
   SET @IXSQL = @IXSQL + CHAR(13) + CHAR(10)
   SET @IXSQL = @IXSQL + 'BEGIN'
   SET @IXSQL = @IXSQL + CHAR(13) + CHAR(10)
   SET @IXSQL = @IXSQL + CHAR(9) + 'CREATE '

   -- Check if the index is unique
   IF (INDEXPROPERTY(@IxTableID, @IxName, 'IsUnique') = 1)
      SET @IXSQL = @IXSQL + 'UNIQUE '
   -- Check if the index is clustered
   IF (INDEXPROPERTY(@IxTableID, @IxName, 'IsClustered') = 1)
      SET @IXSQL = @IXSQL + 'CLUSTERED '

   SET @IXSQL = @IXSQL + 'INDEX [' + @IxName + '] ON [' + @IxSchema + '].[' + @IxTable + ']('

   -- Get all columns of the index
   DECLARE cIxColumn CURSOR FOR 
      SELECT SC.Name
      FROM Sys.Index_Columns IC
         JOIN Sys.Columns SC ON IC.Object_ID = SC.Object_ID AND IC.Column_ID = SC.Column_ID
      WHERE IC.Object_ID = @IxTableID AND Index_ID = @IxID
      ORDER BY IC.Index_Column_ID

   DECLARE @IxColumn SYSNAME
   DECLARE @IxFirstColumn BIT, @ColumnCount INT 
   SET @IxFirstColumn = 1
   SET @ColumnCount = 0

   -- Loop throug all columns of the index and append them to the CREATE statement
   OPEN cIxColumn
   FETCH NEXT FROM cIxColumn INTO @IxColumn
   WHILE (@@FETCH_STATUS = 0)
   BEGIN
      IF (@ColumnCount < 16)
      BEGIN
          IF (@IxFirstColumn = 1)
             SET @IxFirstColumn = 0
          ELSE
             SET @IXSQL = @IXSQL + ', '

          SET @IXSQL = @IXSQL + '[' + @IxColumn + ']'
          SET @ColumnCount = @ColumnCount + 1
      END
      FETCH NEXT FROM cIxColumn INTO @IxColumn
   END
   CLOSE cIxColumn
   DEALLOCATE cIxColumn

   SET @IXSQL = @IXSQL + ')'

   SET @IXSQL = @IXSQL + CHAR(13) + CHAR(10)
   SET @IXSQL = @IXSQL + 'END'
   -- Print out the CREATE statement for the index
   IF(LEN(@IXSQL) > 10)
    PRINT @IXSQL

   FETCH NEXT FROM cIX INTO @IxTable, @IxTableID, @IxName, @IxID, @IxSchema
END

CLOSE cIX
DEALLOCATE cIX