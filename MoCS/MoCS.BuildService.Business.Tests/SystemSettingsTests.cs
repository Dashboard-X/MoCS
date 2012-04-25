using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.Reflection;

namespace MoCS.BuildService.Business.Tests
{
    [TestClass]
    public class SystemSettingsTests
    {
        [TestMethod]
        public void PropertyTest_FillAll_ReadAll()
        {
            SystemSettings sys = new SystemSettings();
            sys.AssignmentsBasePath = "a";
            sys.NunitAssemblyPath = "b";
            sys.CscPath = "c";

            Assert.AreEqual("a", sys.AssignmentsBasePath);
            Assert.AreEqual("b", sys.NunitAssemblyPath);
            Assert.AreEqual("c", sys.CscPath);
        }
    }
}
