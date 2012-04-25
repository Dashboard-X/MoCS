using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using MoCS.BuildService;

namespace MoCS.BuildService.Tests
{
    [TestClass]
    public class SettingsFactoryTests
    {
        [TestMethod]
        public void RemoveTrailingSlashFromPath_TrailingSlash_SlashRemoved()
        {
            Assert.AreEqual(@"C:\tests", SettingsFactory.RemoveTrailingSlashFromPath(@"C:\tests\"));
        }

        [TestMethod]
        public void RemoveTrailingSlashFromPath_NoTrailingSlash_SameOutput()
        {
            Assert.AreEqual(@"C:\tests", SettingsFactory.RemoveTrailingSlashFromPath(@"C:\tests"));
        }

        [TestMethod]
        public void RemoveTrailingSlashFromPath_Null_Null()
        {
            Assert.AreEqual(null, SettingsFactory.RemoveTrailingSlashFromPath(null));
        }

        [TestMethod]
        public void RemoveTrailingSlashFromPath_EmptyString_EmptyString()
        {
            Assert.AreEqual(String.Empty, SettingsFactory.RemoveTrailingSlashFromPath(String.Empty));
        }
    }
}
