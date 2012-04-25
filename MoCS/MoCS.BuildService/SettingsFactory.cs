using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MoCS.BuildService.Business;
using System.Configuration;
using MoCS.Business.Objects;

namespace MoCS.BuildService
{
    public class SettingsFactory
    {
        public static SystemSettings CreateSystemSettings()
        {
            SystemSettings sysSettings = new SystemSettings();

            string cscPath = ConfigurationManager.AppSettings["CscPath"];
            string nunitAssemblyPath = ConfigurationManager.AppSettings["NunitAssemblyPath"];
            string nunitConsolePath = ConfigurationManager.AppSettings["NunitConsolePath"];

            nunitAssemblyPath = RemoveTrailingSlashFromPath(nunitAssemblyPath);
            nunitConsolePath = RemoveTrailingSlashFromPath(nunitConsolePath);
         
            sysSettings.CscPath = cscPath;
            sysSettings.NunitAssemblyPath = nunitAssemblyPath;
            sysSettings.NunitConsolePath = nunitConsolePath;
            sysSettings.NunitTimeOut = int.Parse(ConfigurationManager.AppSettings["ProcessingTimeOut"]);

            sysSettings.AssignmentsBasePath = ConfigurationManager.AppSettings["AssignmentBasePath"];

            sysSettings.BaseResultPath = ConfigurationManager.AppSettings["ResultBasePath"];
            if (!sysSettings.BaseResultPath.EndsWith(@"\"))
            {
                sysSettings.BaseResultPath += @"\";
            }

            return sysSettings;
        }

        public static string RemoveTrailingSlashFromPath(string path)
        {
            if (path == null)
                return null;

            if (path.EndsWith(@"\"))
            {
                path = path.Substring(0, path.Length - 1);
            }
            return path;
        }

        public static SubmitSettings CreateSubmitSettings(string teamName, string teamSubmitDirName, string assignmentId)
        {
            SubmitSettings submitSettings = new SubmitSettings();
            submitSettings.TeamId = teamName;
            submitSettings.BasePath = teamSubmitDirName;
            submitSettings.TimeStamp = DateTime.Now;
            submitSettings.AssignmentId = assignmentId;
            return submitSettings;
        }

        public static AssignmentSettings CreateAssignmentSettings(Assignment assignment, string assignmentName)
        {
            AssignmentSettings assignmentSettings = new AssignmentSettings();
            assignmentSettings.AssignmentId = assignmentName;
            assignmentSettings.ClassnameToImplement = assignment.ClassNameToImplement;
            assignmentSettings.InterfaceNameToImplement = assignment.InterfaceNameToImplement;
            return assignmentSettings;
        }
    }
}
