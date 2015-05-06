select	operationslog.operationDate, 
		operationslog.UnitId
from operationslog
left join Units 
on operationslog.UnitId=Units.UnitId and operationslog.IsSynonym=0
where (IsSynonym=0 or operationslog.UnitId not in 
(select UnitId 
from    operationslog 
where   IsSynonym=1 and OperationDescription='DELETE'))
and (case OperationDescription when 'CHANGE_STATUS' then 'UPDATE' else OperationDescription end)=%s
and operationDate >= dateadd(s, %s, '19700101')
and operationDate <= dateadd(s, %s, '19700101')
and isnull(Units.UnitType, 0)=%s