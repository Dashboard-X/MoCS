using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using MoCS.BuildService;
using MoCS.Business.Objects;
using MoCS.BuildService.Business;

namespace BuildService.Tests
{
    /// <summary>
    /// Summary description for ValidationProcessTests
    /// </summary>
    [TestClass]
    public class ValidationProcessTests
    {

        [TestMethod]
        public void PrepareProcessing()
        {
            Submit submit = new Submit();
            submit.Team = new Team() { Name = "Team" };
            submit.TournamentAssignment = new TournamentAssignment();
            submit.TournamentAssignment.Assignment = new Assignment() { Name = "Assignment1" };

            ValidationProcess process = new ValidationProcess(submit, DateTime.Now);
            process.SetFileSystem(null);/// MOQ aanamken?

            SystemSettings sysSettings = new SystemSettings();
            process.PrepareProcessing(sysSettings);
        }

        [TestMethod]
        public void CheckForTimeOut_TimeOut_True()
        {
            int maxRunningMilliseconds = 1000;
            DateTime now = DateTime.Now;
            DateTime startTime = now.AddMilliseconds(-1001);
            ValidationProcess process = new ValidationProcess(null, startTime);
            bool result = process.CheckForTimeOut(now, maxRunningMilliseconds);
            Assert.IsTrue(result);
            Assert.IsNotNull(process.Result);
            Assert.AreEqual(SubmitStatusCode.TimeOut, process.Result.Status);
        }

        [TestMethod]
        public void CheckForTimeOut_ExactlyTimeoutPeriod_False()
        {
            int maxRunningMilliseconds = 1000;
            DateTime now = DateTime.Now;
            DateTime startTime = now.AddMilliseconds(-1000);
            ValidationProcess process = new ValidationProcess(null, startTime);
            bool result = process.CheckForTimeOut(now, maxRunningMilliseconds);
            Assert.IsFalse(result);
            Assert.IsNull(process.Result);
        }

        [TestMethod]
        public void CheckForTimeOut_LessThanTimeoutPeriod_False()
        {
            int maxRunningMilliseconds = 1000;
            DateTime now = DateTime.Now;
            DateTime startTime = now.AddMilliseconds(-999);
            ValidationProcess process = new ValidationProcess(null, startTime);
            bool result = process.CheckForTimeOut(now, maxRunningMilliseconds); 
            Assert.IsFalse(result);
            Assert.IsNull(process.Result);
        }

        [TestMethod]
        public void IsReady_Success_IsTrue()
        {
            ValidationProcess validationProcess = new ValidationProcess(null, DateTime.Now);
            validationProcess.Result = new ValidationResult();
            validationProcess.Result.Status = SubmitStatusCode.Success;

            Assert.IsTrue(validationProcess.IsReady());
        }

        [TestMethod]
        public void IsReady_NoResult_IsFalse()
        {
            ValidationProcess validationProcess = new ValidationProcess(null, DateTime.Now);
            validationProcess.Result = null;

            Assert.IsFalse(validationProcess.IsReady());
        }

        [TestMethod]
        public void IsReady_StatusUnknown_IsFalse()
        {
            ValidationProcess validationProcess = new ValidationProcess(null, DateTime.Now);
            validationProcess.Result = new ValidationResult();
            validationProcess.Result.Status = SubmitStatusCode.Unknown;

            Assert.IsFalse(validationProcess.IsReady());
        }
    }
}
