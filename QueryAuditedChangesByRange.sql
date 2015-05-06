-- INSERT/UPDATE
select max(operationslog.operationDate), 
	   operationslog.UnitId
from operationslog
left join Units 
on operationslog.UnitId=Units.UnitId and operationslog.IsSynonym=0
where (IsSynonym=0 or operationslog.UnitId not in 
(select UnitId 
from    operationslog 
where   IsSynonym=1 and OperationDescription='DELETE'))
and (case OperationDescription when 'CHANGE_STATUS' then 'UPDATE' else OperationDescription end)=operation_type
and operationDate >= dateadd(s, from_date, '19700101')
and operationDate <= dateadd(s, to_date, '19700101')
and isnull(Units.UnitType, 0)=unit_type
group by operationslog.UnitId

-- DELETE (Synonyms only)
select	operationslog.operationDate, 
		operationslog.UnitId
from operationslog
--left join Units on operationslog.UnitId=Units.UnitId and operationslog.IsSynonym=0
where OperationDescription='DELETE'
and operationDate >= dateadd(s, from_date, '19700101')
and operationDate <= dateadd(s, to_date, '19700101');