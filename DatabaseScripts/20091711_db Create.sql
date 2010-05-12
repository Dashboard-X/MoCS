SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Assignment]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Assignment](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](200) NOT NULL,
 CONSTRAINT [PK_Assignment] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [IX_Assignment] UNIQUE NONCLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Tournament]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Tournament](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_Tournament] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [IX_Tournament] UNIQUE NONCLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Team]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Team](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[TeamName] [nvarchar](50) NOT NULL,
	[TeamMembers] [nvarchar](50) NULL,
	[Password] [nvarchar](50) NOT NULL,
	[CreationDate] [datetime] NOT NULL,
	[IsAdmin] [bit] NULL,
 CONSTRAINT [PK_Team] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TournamentAssignment]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[TournamentAssignment](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[TournamentID] [int] NOT NULL,
	[AssignmentID] [int] NOT NULL,
	[AssignmentOrder] [int] NOT NULL,
	[Points1] [int] NOT NULL,
	[Points2] [int] NOT NULL,
	[Points3] [int] NOT NULL,
	[Active] [bit] NOT NULL,
 CONSTRAINT [PK_TournamentAssignment] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [IX_TournamentAssignment] UNIQUE NONCLUSTERED 
(
	[TournamentID] ASC,
	[AssignmentID] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TeamSubmitStatus]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[TeamSubmitStatus](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[TeamID] [int] NOT NULL,
	[TeamSubmitID] [int] NOT NULL,
	[StatusCode] [int] NOT NULL,
	[Details] [nvarchar](1000) NULL,
	[CreationDate] [datetime] NOT NULL,
 CONSTRAINT [PK_TeamSumbitStatus] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TeamTournamentAssignment]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[TeamTournamentAssignment](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[TeamId] [int] NOT NULL,
	[TournamentAssignmentId] [int] NOT NULL,
	[StartDate] [datetime] NOT NULL,
 CONSTRAINT [PK_TeamTournamentAssignment] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TeamSubmit]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[TeamSubmit](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[TeamID] [int] NOT NULL,
	[TeamTournamentAssignmentID] [int] NOT NULL,
	[FileName] [nvarchar](255) NOT NULL,
	[FileStream] [varbinary](max) NOT NULL,
	[CreationDate] [datetime] NOT NULL,
	[CurrentStatusID] [int] NULL,
	[IsFinished] [bit] NOT NULL,
 CONSTRAINT [PK_TeamSubmit] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TeamTournamentAssignment_Select]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[TeamTournamentAssignment_Select]
	@ID int = NULL
	,@TournamentID int = NULL
	,@TeamID int = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

IF(@ID IS NULL)
BEGIN
select tta.id, ISNULL(tta.teamId, @TeamID) AS TeamId, ta.ID as TournamentAssignmentId, tta.StartDate, ta.TournamentId
,ta.AssignmentId, ta.Points1, ta.Points2, ta.Points3, ta.Active, a.Name as AssignmentName
FROM TournamentAssignment ta
INNER JOIN Assignment a ON ta.assignmentid = a.id AND ta.TournamentID = @TournamentID
LEFT JOIN TeamTournamentAssignment tta ON tta.tournamentAssignmentID = ta.id AND  tta.teamid = @TeamID
ORDER BY ta.AssignmentOrder

END 
ELSE

select tta.id, ISNULL(tta.teamId, @TeamID) AS TeamId, ta.ID as TournamentAssignmentId, tta.StartDate, ta.TournamentId
,ta.AssignmentId, ta.Points1, ta.Points2, ta.Points3, ta.Active, a.Name as AssignmentName
FROM TournamentAssignment ta
INNER JOIN Assignment a ON ta.assignmentid = a.id
INNER JOIN TeamTournamentAssignment tta ON tta.tournamentAssignmentID = ta.id AND tta.ID = @ID
ORDER BY ta.AssignmentOrder



END







' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TeamSubmit_SelectUnprocessed]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [dbo].[TeamSubmit_SelectUnprocessed] 
AS
BEGIN

select ts.ID, t.id as TeamID, t.teamname as TeamName, a.id as AssignmentID, a.Name as AssignmentName
, ts.FileName, ts.CreationDate as SubmitDate, ts.FileStream, ts.CurrentStatusID, tss.StatusCode 
from teamsubmit ts
INNER JOIN teamsubmitstatus tss on ts.currentstatusid = tss.id
INNER JOIN teamtournamentassignment tta ON tta.id = ts.teamtournamentassignmentid
INNER JOIN tournamentassignment ta ON ta.id = tta.tournamentassignmentid
INNER JOIN assignment a ON a.id = ta.assignmentID
INNER JOIN Team t ON ts.TeamID = t.ID
WHERE ts.IsFinished = 0
and tss.statuscode = 0 
order by ts.creationdate asc


END



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Assignment_Save]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Assignment_Save]
	@ID	int
	,@Name nvarchar(200)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

IF(@ID=-1)
	BEGIN
		INSERT INTO Assignment (Name)
		VALUES(@Name)

		SELECT @@Identity
	END

ELSE
	UPDATE Assignmnet
	SET Name = @Name
	WHERE ID = @ID

END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Assignment_Delete]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Assignment_Delete]
	@ID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DELETE 
	FROM Assignment
	WHERE ID = @ID

END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Assignment_Select]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Assignment_Select]
	@ID	int = NULL
AS
BEGIN
	SELECT ID, Name
	FROM Assignment
	WHERE (@ID IS NULL OR ID = @ID)
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TournamentAssignment_Select]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[TournamentAssignment_Select]
	@TournamentAssignmentID	int = NULL
	,@TournamentID	int	= NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		select ta.ID, ta.TournamentID, ta.AssignmentID, ta.AssignmentOrder, 
		ta.Points1, ta.Points2, ta.Points3, ta.Active, a.Name as AssignmentName 
		from tournamentassignment ta
		INNER JOIN Assignment a ON ta.assignmentId = a.id
		WHERE (@TournamentID IS NULL OR tournamentID = @TournamentID)
		AND (@TournamentAssignmentID IS NULL OR ta.ID = @TournamentAssignmentID)
		ORDER BY AssignmentOrder, AssignmentName

END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TeamSubmitStatus_Insert]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[TeamSubmitStatus_Insert]
	@TeamID			int
	,@TeamSubmitID	int
	,@StatusCode	int
	,@Details		nvarchar(1000) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO TeamSubmitStatus (TeamID, TeamSubmitID, StatusCode, Details, CreationDate)
	VALUES(@TeamID, @TeamSubmitID, @StatusCode, @Details, GetDate())

	declare @newTeamSubmitStatusID int
	set @newTeamSubmitStatusID = @@identity

	UPDATE TeamSubmit
	Set CurrentStatusID = @newTeamSubmitStatusID
	WHERE ID = @TeamSubmitID

END


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TeamSubmit_Select]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[TeamSubmit_Select]
	@ID	int = NULL
	,@TournamentAssignmentId int = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF(@ID IS NULL)
	BEGIN
		select ts.ID, ts.TeamID, ta.AssignmentID, ta.TournamentID, ts.TeamTournamentAssignmentID, ts.FileName, 
		ts.FileStream, ts.CreationDate as SubmitDate, ts.CurrentStatusID, ts.IsFinished, tss.StatusCode, tss.Details, tss.CreationDate as StatusDate
		 from teamsubmit ts
		INNER JOIN teamsubmitstatus tss on ts.CurrentStatusID = tss.ID
		INNER JOIN teamtournamentassignment tta on tta.ID = ts.TeamTournamentAssignmentID
		INNER JOIN tournamentassignment ta ON tta.tournamentassignmentid = ta.id
		where tta.id = @TournamentAssignmentId
	END
	ELSE
		select ts.ID, ts.TeamID, ta.AssignmentID, ta.TournamentID, ts.TeamTournamentAssignmentID, ts.FileName, 
		ts.FileStream, ts.CreationDate as SubmitDate, ts.CurrentStatusID, ts.IsFinished, tss.StatusCode, tss.Details, tss.CreationDate as StatusDate
		 from teamsubmit ts
		INNER JOIN teamsubmitstatus tss on ts.CurrentStatusID = tss.ID
		INNER JOIN teamtournamentassignment tta on tta.ID = ts.TeamTournamentAssignmentID
		INNER JOIN tournamentassignment ta ON tta.tournamentassignmentid = ta.id
		where ts.ID=@ID


END





' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TeamSubmit_Delete]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[TeamSubmit_Delete] 
	@ID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

DELETE FROM TeamSubmitStatus 
WHERE TeamSubmitID = @ID


	DELETE FROM TeamSubmit WHERE ID = @ID

END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TeamSubmit_Finished]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[TeamSubmit_Finished] 
@SubmitID			int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

UPDATE TeamSubmit
Set IsFinished = 1
WHERE ID = @SubmitID

END
' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Tournament_Submits_SelectAll]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Tournament_Submits_SelectAll]
	@TournamentId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

SELECT ts.ID, tta.teamid, ta.assignmentid, tta.startdate, ts.CreationDate as SubmitDate, ts.IsFinished, tss.StatusCode
FROM TeamSubmit ts 
INNER JOIN (select teamid as t, teamtournamentassignmentid as tid, max(creationdate) as MaxDate from teamsubmit
	group by teamid, teamtournamentassignmentid) as ls ON ts.teamtournamentassignmentid = ls.tid
INNER JOIN TeamTournamentAssignment tta ON tta.id = ts.teamtournamentassignmentid
INNER JOIN TournamentAssignment ta ON ta.id = tta.tournamentAssignmentID
INNER JOIN TeamSubmitStatus tss ON tss.ID = ts.CurrentStatusID
AND ta.tournamentid = @TournamentID
--ALL ASSIGNMENTS THAT WERE STAREN BUT HAVE NO SUBMITS
UNION
SELECT NULL as ID, tta.teamid, ta.assignmentid, NULL as StartDate, NULL as SubmitDate, 0 as IsFinished, 0 as SatusCode
 FROM TEAM tm
JOIN teamtournamentassignment tta ON tm.Id = tta.teamid
INNER JOIN tournamentassignment ta ON ta.id = tta.tournamentassignmentid
AND ta.TournamentID = @TournamentID
AND NOT EXISTS (Select * from TeamSubmit ts where ts.TeamId = tm.ID and tta.ID = ts.teamtournamentassignmentid)


END



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Tournament_Save]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Tournament_Save]
	@ID	int
	,@Name nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

IF(@ID=-1)
	BEGIN
		INSERT INTO Tournament (Name)
		VALUES(@Name)

		SELECT @@Identity
	END

ELSE
	UPDATE Tournamnet
	SET Name = @Name
	WHERE ID = @ID

END
' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Tournament_Select]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Tournament_Select]
	@ID	int = NULL
AS
BEGIN
	SELECT ID, Name
	FROM Tournament
	WHERE (@ID IS NULL OR ID = @ID)
END
' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Tournament_Delete]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Tournament_Delete]
	@ID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DELETE 
	FROM Tournament
	WHERE ID = @ID

END
' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TournamentAssignment_Delete]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[TournamentAssignment_Delete]
	@ID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DELETE FROM TournamentAssignment
	WHERE ID = @ID

END
' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TournamentAssignment_Save]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[TournamentAssignment_Save]
	@ID int,
	@TournamentID int,
	@AssignmentID int,
	@AssignmentOrder int,
	@Points1 int, 
	@Points2 int, 
	@Points3 int, 
	@Active	bit


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	IF(@ID=-1)
		BEGIN
			
			INSERT INTO TournamentAssignment (TournamentID, AssignmentID, AssignmentOrder, Points1, Points2, Points3, Active)
			VALUES(@TournamentID, @AssignmentID, @AssignmentOrder, @Points1, @Points2, @Points3, @Active)

			SELECT @@IDENTITY
		END
	ELSE
		UPDATE TournamnetAssignment 
		SET TournamentID = @TournamentID
		, AssignmentID = @AssignmentID
		, AssignmentOrder = @AssignmentOrder
		, Points1 = @Points1
		, Points1 = @Points1
		, Points1 = @Points1
		, Active = @Active

		WHERE ID = @ID





END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TeamTournamentAssignment_Save]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[TeamTournamentAssignment_Save]
	@ID	int,
	@TeamID int,
	@TournamentAssignmentID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF(@ID=-1)
		BEGIN
			INSERT INTO TeamTournamentAssignment (TeamID, TournamentAssignmentID, StartDate)
				VALUES (@TeamID, @TournamentAssignmentID, GetDate())

			SELECT @@IDENTITY

		END
	ELSE
		UPDATE TeamTournamentAssignment
		Set TeamID = @TeamID
		, TournamentAssignmentID = @TournamentAssignmentID
		WHERE ID = @ID



END
' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TeamTournamentAssignment_Delete]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[TeamTournamentAssignment_Delete]
	@ID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DELETE FROM TeamTournamentAssignment
	WHERE ID = @ID

END
' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Team_Save]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- ====
CREATE PROCEDURE [dbo].[Team_Save]
	@ID			int,
	@TeamName	nvarchar(50),
	@Password	nvarchar(50),
	@TeamMembers nvarchar(100),
	@IsAdmin bit

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF(@ID=-1)
		BEGIN
			INSERT INTO TEAM(TeamName, Password,CreationDate, IsAdmin, TeamMembers)
			VALUES (@TeamName, @Password, GetDate(), @IsAdmin, @TeamMembers)
	
			Select @@Identity

		END

	ELSE
			UPDATE Team
			SET TeamName = @TeamName,
			TeamMembers = @TeamMembers,
			IsAdmin = @IsAdmin
			WHERE ID = @ID

END' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Team_Select]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Team_Select]
	@ID	int	= NULL,
	@TeamName	nvarchar(50) = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT ID, TeamName, TeamMembers, Password, CreationDate, IsAdmin
	FROM Team
	WHERE (@ID IS NULL OR ID = @ID) AND (@TeamName IS NULL OR TeamName = @TeamName)

END
' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Team_Delete]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Team_Delete] 
	@ID	int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DELETE FROM Team WHERE ID = @ID

END
' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TeamSubmit_Insert]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[TeamSubmit_Insert] 
	 @TeamID			int
	,@TeamTournamentAssignmentID	int
	,@FileName		nvarchar(255)
	,@FileStream	varbinary(max)
AS
BEGIN

	SET NOCOUNT ON;

	INSERT INTO TeamSubmit(TeamID, TeamTournamentAssignmentID, FileName, FileStream, CreationDate, isFinished) 
	VALUES(@TeamID, @TeamTournamentAssignmentID, @FileName, @FileStream, GetDate(), 0)

	declare @newTeamSubmitID int 
	set @newTeamSubmitID = @@identity

	exec TeamSubmitStatus_Insert @TeamID, @newTeamSubmitID, 0, null

	SELECT @newTeamSubmitID

END
' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_TournamentAssignment_Assignment]') AND parent_object_id = OBJECT_ID(N'[dbo].[TournamentAssignment]'))
ALTER TABLE [dbo].[TournamentAssignment]  WITH CHECK ADD  CONSTRAINT [FK_TournamentAssignment_Assignment] FOREIGN KEY([AssignmentID])
REFERENCES [dbo].[Assignment] ([ID])
GO
ALTER TABLE [dbo].[TournamentAssignment] CHECK CONSTRAINT [FK_TournamentAssignment_Assignment]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_TournamentAssignment_Tournament]') AND parent_object_id = OBJECT_ID(N'[dbo].[TournamentAssignment]'))
ALTER TABLE [dbo].[TournamentAssignment]  WITH CHECK ADD  CONSTRAINT [FK_TournamentAssignment_Tournament] FOREIGN KEY([TournamentID])
REFERENCES [dbo].[Tournament] ([ID])
GO
ALTER TABLE [dbo].[TournamentAssignment] CHECK CONSTRAINT [FK_TournamentAssignment_Tournament]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_TeamSubmitStatus_Team]') AND parent_object_id = OBJECT_ID(N'[dbo].[TeamSubmitStatus]'))
ALTER TABLE [dbo].[TeamSubmitStatus]  WITH CHECK ADD  CONSTRAINT [FK_TeamSubmitStatus_Team] FOREIGN KEY([TeamID])
REFERENCES [dbo].[Team] ([ID])
GO
ALTER TABLE [dbo].[TeamSubmitStatus] CHECK CONSTRAINT [FK_TeamSubmitStatus_Team]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_TeamSubmitStatus_TeamSubmit]') AND parent_object_id = OBJECT_ID(N'[dbo].[TeamSubmitStatus]'))
ALTER TABLE [dbo].[TeamSubmitStatus]  WITH CHECK ADD  CONSTRAINT [FK_TeamSubmitStatus_TeamSubmit] FOREIGN KEY([TeamSubmitID])
REFERENCES [dbo].[TeamSubmit] ([ID])
GO
ALTER TABLE [dbo].[TeamSubmitStatus] CHECK CONSTRAINT [FK_TeamSubmitStatus_TeamSubmit]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_TeamTournamentAssignment_Team]') AND parent_object_id = OBJECT_ID(N'[dbo].[TeamTournamentAssignment]'))
ALTER TABLE [dbo].[TeamTournamentAssignment]  WITH CHECK ADD  CONSTRAINT [FK_TeamTournamentAssignment_Team] FOREIGN KEY([TeamId])
REFERENCES [dbo].[Team] ([ID])
GO
ALTER TABLE [dbo].[TeamTournamentAssignment] CHECK CONSTRAINT [FK_TeamTournamentAssignment_Team]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_TeamTournamentAssignment_TournamentAssignment]') AND parent_object_id = OBJECT_ID(N'[dbo].[TeamTournamentAssignment]'))
ALTER TABLE [dbo].[TeamTournamentAssignment]  WITH CHECK ADD  CONSTRAINT [FK_TeamTournamentAssignment_TournamentAssignment] FOREIGN KEY([TournamentAssignmentId])
REFERENCES [dbo].[TournamentAssignment] ([ID])
GO
ALTER TABLE [dbo].[TeamTournamentAssignment] CHECK CONSTRAINT [FK_TeamTournamentAssignment_TournamentAssignment]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_TeamSubmit_Team]') AND parent_object_id = OBJECT_ID(N'[dbo].[TeamSubmit]'))
ALTER TABLE [dbo].[TeamSubmit]  WITH CHECK ADD  CONSTRAINT [FK_TeamSubmit_Team] FOREIGN KEY([TeamID])
REFERENCES [dbo].[Team] ([ID])
GO
ALTER TABLE [dbo].[TeamSubmit] CHECK CONSTRAINT [FK_TeamSubmit_Team]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_TeamSubmit_TeamTournamentAssignment]') AND parent_object_id = OBJECT_ID(N'[dbo].[TeamSubmit]'))
ALTER TABLE [dbo].[TeamSubmit]  WITH CHECK ADD  CONSTRAINT [FK_TeamSubmit_TeamTournamentAssignment] FOREIGN KEY([TeamTournamentAssignmentID])
REFERENCES [dbo].[TeamTournamentAssignment] ([ID])
GO
ALTER TABLE [dbo].[TeamSubmit] CHECK CONSTRAINT [FK_TeamSubmit_TeamTournamentAssignment]
