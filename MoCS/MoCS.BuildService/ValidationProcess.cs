using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MoCS.Business.Objects;
using System.Threading;
using MoCS.BuildService.Business;
using System.Configuration;
using MoCS.Business.Facade;
using System.IO;
using MoCS.BuildService.Business.Interfaces;

namespace MoCS.BuildService
{
    public class ValidationProcess
    {
        private DateTime _startTime;
        private Submit _submit;
        private SubmitValidator _validator;
        private IFileSystem _fileSystem;


        public Thread Thread { get; private set; }

        public ValidationProcess(Submit submit, DateTime startTime)
        {
            _submit = submit;
            _startTime = startTime;
            _fileSystem = new MoCS.BuildService.Business.FileSystemWrapper();
        }

        public void SetFileSystem(IFileSystem fileSystem)
        {
            _fileSystem = fileSystem;
        }

        public DateTime ProcessingDate { get { return _startTime; } }

        public Submit Submit { get { return _submit; } }

        public void SetThread(Thread thread)
        {
            Thread = thread;
        }

        public void SetValidator(SubmitValidator validator)
        {
            _validator = Validator;
        }

        public SubmitValidator Validator
        { get { return _validator; } }

        public ValidationResult Result { get; set; }

        public bool IsReady()
        {
            return this.Result != null && this.Result.Status != SubmitStatusCode.Unknown;
        }

        public bool HasTimedOut()
        {
            return this.Result != null && this.Result.Status == SubmitStatusCode.TimeOut;
        }

        public bool CheckForTimeOut(DateTime checkMoment, int maxRunningMilliSeconds)
        {
            TimeSpan span = checkMoment.Subtract(this.ProcessingDate);

            if (span.TotalMilliseconds > maxRunningMilliSeconds)
            {               
                if (this.Result == null)
                {
                    this.Result = new ValidationResult();
                }
                this.Result.Status = SubmitStatusCode.TimeOut;
                this.Result.Messages.Add("TimeOut - it took more than " + maxRunningMilliSeconds.ToString() + " ms");

                return true;
            }

            return false;
        }

        private static void Log(string message)
        {
            //TODO: ADD AN INTERFACE FOR THIS
            Console.WriteLine(DateTime.Now.ToLongTimeString() + " " + message);
        }

        private string _teamSubmitDirName = string.Empty;

        public void PrepareProcessing(SystemSettings sysSettings)
        {
           string teamName = Submit.Team.Name;
           string assignmentName = Submit.TournamentAssignment.Assignment.Name;

            Log(string.Format("Processing teamsubmit {0} for assignment {1}", teamName, assignmentName));

            //create the validator
            SubmitValidator validator = new SubmitValidator(new MoCS.BuildService.Business.FileSystemWrapper(), new ExecuteCmd());
            SetValidator(validator);

            //prepare directory and files for processing
            _teamSubmitDirName = CreateTeamDirectory(sysSettings, teamName, Submit.TournamentAssignment.Assignment);
            ClientFacade facade = new ClientFacade();
            MoCS.Business.Objects.Assignment assignment = facade.GetAssignmentById(Submit.TournamentAssignment.Assignment.Id, true);

            CopyFiles(assignment, Submit, _teamSubmitDirName, sysSettings);
        }

        public void Process(SystemSettings sysSettings)
        {
            Assignment assignment = Submit.TournamentAssignment.Assignment;
            //settings that are read from the assignment
            AssignmentSettings assignmentSettings = SettingsFactory.CreateAssignmentSettings(assignment, AssignmentName);
            //settings that are from the submitprocess/team submit
            SubmitSettings submitSettings = SettingsFactory.CreateSubmitSettings(Submit.Team.Name, _teamSubmitDirName, AssignmentName);

            ClientFacade facade = new ClientFacade();
            //set status of submit to 'processing'
            facade.UpdateSubmitStatusDetails(Submit.Id, SubmitStatus.Processing, "This submitted is currently processed.", DateTime.Now);

             Result = Validator.Process(sysSettings, assignmentSettings, submitSettings);

            Log(Result.Status + " for " + Submit.Team.Name + " on " + Submit.TournamentAssignment.Assignment.Name);

        }

        public void FinishProcessing()
        {
            SaveStatusToDatabase();

            // Delete nunit.framework.dll from the submit dir to keep things clean
            CleanupFiles(_teamSubmitDirName);
        }

        public void CleanupFiles(string teamSubmitDirName)
        {
            MoCS.BuildService.Business.FileSystemWrapper fileSystem = new Business.FileSystemWrapper();
            fileSystem.FileDelete(Path.Combine(teamSubmitDirName, "nunit.framework.dll"));
        }

        public string AssignmentName
        {
            get { return Submit.TournamentAssignment.Assignment.Name; }
        }

        public void SaveStatusToDatabase()
        {
            string details = "";
            foreach (string detail in Result.Messages)
            {
                details += detail;
            }
            if (details.Length > 1000)
            {
                details = details.Substring(0, 999);
            }

            ClientFacade facade = new ClientFacade();

            //process result
            switch (Result.Status)
            {
                case SubmitStatusCode.Unknown:
                    facade.UpdateSubmitStatusDetails(Submit.Id, SubmitStatus.ErrorUnknown, details, DateTime.Now);
                    break;
                case SubmitStatusCode.CompilationError:
                    facade.UpdateSubmitStatusDetails(Submit.Id, SubmitStatus.ErrorCompilation, details, DateTime.Now);
                    break;
                case SubmitStatusCode.ValidationError:
                    facade.UpdateSubmitStatusDetails(Submit.Id, SubmitStatus.ErrorValidation, details, DateTime.Now);
                    break;
                case SubmitStatusCode.TestError:
                    facade.UpdateSubmitStatusDetails(Submit.Id, SubmitStatus.ErrorTesting, details, DateTime.Now);
                    break;
                case SubmitStatusCode.ServerError:
                    facade.UpdateSubmitStatusDetails(Submit.Id, SubmitStatus.ErrorServer, details, DateTime.Now);
                    break;
                case SubmitStatusCode.Success:
                    facade.UpdateSubmitStatusDetails(Submit.Id, SubmitStatus.Success, details, DateTime.Now);
                    break;
                default:
                    break;
            }
        }

        public void CopyFiles(Assignment assignment, Submit submit, string teamSubmitDirName, SystemSettings systemSettings)
        {
            MoCS.BuildService.Business.FileSystemWrapper fileSystem = new Business.FileSystemWrapper();

            // Copy nunit.framework.dll to this directory
            fileSystem.FileCopy(Path.Combine(systemSettings.NunitAssemblyPath, "nunit.framework.dll"),
                        Path.Combine(teamSubmitDirName, "nunit.framework.dll"), true);

            //copy the file to this directory
            using (Stream target = fileSystem.FileOpenWrite(Path.Combine(teamSubmitDirName, submit.FileName)))
            {
                try
                {
                    target.Write(submit.Data, 0, submit.Data.Length);
                }
                finally
                {
                    target.Flush();
                }
            }

            // Copy the interface file
            //delete the file if it existed already
            AssignmentFile interfaceFile = assignment.AssignmentFiles.Find(af => af.Name == "InterfaceFile");

            fileSystem.DeleteFileIfExists(Path.Combine(teamSubmitDirName, interfaceFile.FileName));

            fileSystem.FileCopy(Path.Combine(assignment.Path, interfaceFile.FileName),
                        Path.Combine(teamSubmitDirName, interfaceFile.FileName));

            //copy the server testfile
            //delete the file if it existed already
            AssignmentFile serverTestFile = assignment.AssignmentFiles.Find(af => af.Name == "NunitTestFileServer");

            fileSystem.DeleteFileIfExists(Path.Combine(teamSubmitDirName, serverTestFile.FileName));

            fileSystem.FileCopy(Path.Combine(assignment.Path, serverTestFile.FileName),
                        Path.Combine(teamSubmitDirName, serverTestFile.FileName));

            //copy additional serverfiles
            List<AssignmentFile> serverFilesToCopy = assignment.AssignmentFiles.FindAll(af => af.Name == "ServerFileToCopy");
            foreach (AssignmentFile serverFileToCopy in serverFilesToCopy)
            {

                fileSystem.DeleteFileIfExists(Path.Combine(teamSubmitDirName, serverFileToCopy.FileName));

                fileSystem.FileCopy(Path.Combine(assignment.Path, serverFileToCopy.FileName),
                            Path.Combine(teamSubmitDirName, serverFileToCopy.FileName));
            }

            //copy the client testfile
            AssignmentFile clientTestFile = assignment.AssignmentFiles.Find(af => af.Name == "NunitTestFileClient");

            //delete the file if it existed already
            fileSystem.DeleteFileIfExists(Path.Combine(teamSubmitDirName, clientTestFile.FileName));

            fileSystem.FileCopy(Path.Combine(assignment.Path, clientTestFile.FileName),
                        Path.Combine(teamSubmitDirName, clientTestFile.FileName));

        }

        public string _teamDirName = string.Empty;

        public string CreateTeamDirectory(SystemSettings sysSettings, string teamName, Assignment assignment)
        {
          // MoCS.BuildService.Business.FileSystemWrapper fileSystem = new Business.FileSystemWrapper();

            //prepare processing
            //create a new directory for the basepath
            _fileSystem.CreateDirectoryIfNotExists(sysSettings.BaseResultPath);

            //create a directory for the assignment
            _fileSystem.CreateDirectoryIfNotExists(sysSettings.BaseResultPath + assignment.Name);

            _teamDirName = teamName + "_" + DateTime.Now.ToString("ddMMyyyy_HHmmss");
            string teamSubmitDirName = sysSettings.BaseResultPath + assignment.Name + @"\" + _teamDirName;
            //create a new directory for the teamsubmit
            _fileSystem.CreateDirectory(teamSubmitDirName);

            return teamSubmitDirName;
        }
  

        
    }
}
