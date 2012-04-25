using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MoCS.BuildService.Business.Tests
{
    [TestClass]
    public class SubmitResultTests
    {
        [TestMethod]
        public void Constructor_NoParameters_TestProperties()
        {
            SubmitResult r = new SubmitResult();
            Assert.AreEqual(SubmitStatusCode.Unknown, r.Status);
            Assert.AreEqual(0, r.Messages.Count);
        }
    }
}
