------------
-- Insert --
------------

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[pBHPInsertSynonym]
(
	@Synonym nvarchar(100),
	@LanguageCode int,
	@Num int -- = Null output
)
AS
SET NOCOUNT OFF;
begin try
if(charindex('$',@Synonym) <> 0)
	exec iBHPRaisError @ErrorNumber=16	

--if(@Num is null or @Num = -1)
--	set @Num = (select max(Num) from [Synonyms]) + 1
DECLARE @SynKey int

Insert Synonyms(Num,LanguageCode,[Synonym])
Values(@Num,@LanguageCode,@Synonym)

set @SynKey=@@IDENTITY

Insert Into operationsLog (OperationDate, UnitId, OperationDescription, IsSynonym)
Values (GetDATE(),@SynKey,'INSERT',1)
	
end try
begin catch
	exec iBHPErrorLogInsert;
	exec iBHPErrorRethrow;	
end catch
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

------------
-- Update --
------------

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[pBHPUpdateSynonym]
(
	@SynonymKey int,
	@Num int,
	@LanguageCode int,
	@Synonym nvarchar(100)
)
AS
SET NOCOUNT OFF;
begin try
Update Synonyms Set [Synonym] = @Synonym, LanguageCode = @LanguageCode
where Num = @Num AND SynonymKey = @SynonymKey

Insert Into operationsLog (OperationDate, UnitId, OperationDescription, IsSynonym)
Values (GetDATE(),@SynonymKey ,'UPDATE',1)

end try
begin catch
	exec iBHPErrorLogInsert;
	exec iBHPErrorRethrow;	
end catch


--select US1.[Synonym] as SynonymKey,dbo.fbhpGeneralConcatenates(US2.[Synonym]) as SynonymValues 
--FROM Synonyms US1,Synonyms US2 
--WHERE 
--US1.[Synonym] IN (select Data from dbo.fbhpSplit('Cohen','$'))
--and
--US1.Num=US2.Num
--GROUP BY US1.[Synonym]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

------------
-- Delete --
------------


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[pBHPDeleteSynonym]
(
	@Num int,
	@Synonym nvarchar(100)
)
AS
SET NOCOUNT OFF;
begin try
declare @listOfSynKeys table (SynKey int);

delete Synonyms
output DELETED.SynonymKey INTO @listOfSynKeys
where Num = @Num and [Synonym] = @Synonym

Insert Into operationsLog (OperationDate, UnitId, OperationDescription, IsSynonym)
select GetDATE(),SynKey,'DELETE',1
from @listOfSynKeys;

end try
begin catch
	exec iBHPErrorLogInsert;
	exec iBHPErrorRethrow;	
end catch
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

  
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[pBHPDeleteSynonymUnit]
(
	@Num int
)
AS
SET NOCOUNT OFF;
begin try
declare @listOfSynKeys table (SynKey int);

delete Synonyms
OUTPUT DELETED.SynonymKey INTO @listOfSynKeys
where Num = @Num

Insert Into operationsLog (OperationDate, UnitId, OperationDescription, IsSynonym)
select GetDATE(),SynKey,'DELETE',1
from @listOfSynKeys
--Values (GetDATE(),@SynonymKey ,'DELETE',1,0)

end try
begin catch
	exec iBHPErrorLogInsert;
	exec iBHPErrorRethrow;	
end catch
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO





