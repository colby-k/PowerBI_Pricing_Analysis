USE 
    LoanProduction

SELECT
    PE.LoanNumber
    ,CONCAT('''', PE.loannumber, ''',') AS 'SQL'
    ,PE.[PeNumber]
    ,PE.[CostCenterCode]
    ,PE.[SubmissionNumber]
    ,CONVERT(varchar(10), PE.[SubmitDate], 101) AS SubmitDate
    ,CONVERT(varchar(10), PE.[LockDate], 101) AS LockDate
    ,PE.[SubmissionState]
    ,PE.[Reason]
    ,PE.[Notes]
    ,PE.[Cost]
    ,PE.[LoanPurpose]
    ,PE.[HouseAccount] --House Account
    ,PE.[LoanAmount]
    ,PE.[NetPrice]
    ,PE.[SubmissionName]
    ,PE.[LoDiscretionRule]
    ,PE.[LoanProgram]
    ,PE.[Rule]
    ,PE.[UsedVolumePercentIfApproved]
    ,PE.[BasePrice]
    ,PE.[PreviousApprovedAllInPrice]
    ,PE.[UsedUnitPercentIfApproved]
    ,PE.[ApprovalState]
    ,PE.[AllInPrice]
    ,PE.[ApprovedAllInPrice]
    ,PE.[ActualCost]
    ,CONVERT(varchar(10), PE.[LoadDateTime], 101) AS LoadDateTime
    ,PE.[DeletedFlag]
    ,CONVERT(varchar(10), FL.HmdaActionTakenDate, 101) AS HmdaActionTakenDate
    ,DL.HmdaActionTaken

FROM --Grouped subselection to get the most recent PE submission for each loan number
    ( 
    SELECT
        LoanNumber
        ,MAX(SubmissionNumber) AS MaxSubmission
    FROM
        [LoanProduction].[dw].[FactServiceNowPricingException]
    GROUP BY LoanNumber --Group by loan number to get the most recent PE submission for each loan number
) AS s --Subselection to get the most recent PE submission for each loan number
    JOIN [LoanProduction].[dw].[FactServiceNowPricingException] PE ON PE.LoanNumber = s.LoanNumber AND PE.SubmissionNumber = s.MaxSubmission
    JOIN DataCore.dw.DimLoan DL ON PE.LoanNumber = DL.LoanNumber
    JOIN LoanProduction.dw.FactLoanProduction FL ON DL.DimLoanId = FL.DimLoanId
    JOIN LoanProduction.dw.FactPricingException FPE ON FPE.DimLoanId = FL.DimLoanId

WHERE --Filter to get the most recent PE submission for each Originated Loan between the dates of interest (8/1/2023 - 11/28/2023)
    1=1
    AND FL.HmdaActionTakenDate BETWEEN '08-01-2023' AND '11-28-2023'
    AND DL.HmdaActionTaken ='Loan originated'
--AND PE.LoanNumber IN ( --Filter to get the most recent PE submission for specific loans using their loan numbers
--)
ORDER BY PE.LoanNumber DESC, PE.SubmissionNumber DESC
