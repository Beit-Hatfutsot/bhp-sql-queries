-- INSERT
select	operationslog.operationDate, 
		operationslog.UnitId,
		isnull(Units.UnitType, 15)
from operationslog.UnitId
left join Units on operationslog.UnitId=Units.UnitId and operationslog.IsSynonym=0
where OperationDescription='INSERT'
and operationslog
and (IsSynonym=0 or UnitId not in (select UnitId from operationslog where IsSynonym=1 and OperationDescription='DELETE'))
and operationDate >= from_date
and operationDate <= to_date

-- UPDATE
select	Oplog.operationDate, 
		Oplog.UnitId,
		isnull(Units.UnitType, 15) UnitType
from (select *,row_number() over(partition by UnitId order by operationDate desc) OperationNum
      from   operationslog
	  where OperationDescription in ('UPDATE','CHANGE_STATUS')
	 /* and operationDate >= from_date
	  and operationDate <= to_date*/
	  and (IsSynonym=0 or 
			UnitId not in (select UnitId from operationslog where IsSynonym=1 and OperationDescription='DELETE'))) Oplog
left join Units on (Oplog.UnitId=Units.UnitId and Oplog.IsSynonym=0)
where Oplog.OperationNum=1

-- DELETE
select	operationslog.operationDate, 
		operationslog.UnitId,
		isnull(Units.UnitType, 15)
from operationslog
left join Units on operationslog.UnitId=Units.UnitId and operationslog.IsSynonym=0
where OperationDescription='DELETE'
and operationDate >= from_date
and operationDate <= to_date;