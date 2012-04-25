using System;
using System.Collections.Generic;
using System.Linq;
using System.Timers;
using System.IO;
using System.Xml;
using MoCS.BuildService.Business;
using MoCS.Business.Objects;
using MoCS.Business.Facade;
using System.Configuration;
using MoCS.BuildService.Business.Interfaces;
using System.Threading;
using System.Collections;

namespace MoCS.BuildService
{

    public class SubmitWatcher
    {
        private Hashtable _runningSubmitsHT;
        private System.Timers.Timer _timer;
        private SystemSettings _systemSettings;
        private IFileSystem _fileSystem;

        private delegate void DoWorkNeedsTimeOutDelegate(ValidationProcess submit);

        public SubmitWatcher()
        {
            Hashtable ht2 = CreateSynchronizedWrappedHashtable();
            _systemSettings = SettingsFactory.CreateSystemSettings();
            _fileSystem = new MoCS.BuildService.Business.FileSystemWrapper();
        }

        private Hashtable CreateSynchronizedWrappedHashtable()
        {
            Hashtable ht2 = new Hashtable();
            _runningSubmitsHT = Hashtable.Synchronized(ht2);
            return ht2;
        }

        public void StartWatching()
        {
            ClientFacade facade = new ClientFacade();
            List<Submit> submits = facade.GetUnprocessedSubmits();
            StartWatchingNewSubmits(submits);

            StartPolling();
        }

        private void _timer_Elapsed(object sender, ElapsedEventArgs e)
        {
            ClientFacade facade = new ClientFacade();
            List<Submit> submits = facade.GetUnprocessedSubmits();
            StartWatchingNewSubmits(submits);
            TerminateOldSubmits();
            TraceStatus();
        }

        private void StartPolling()
        {
            _timer = new System.Timers.Timer();
            _timer.Interval = GetPollingInterval();
            _timer.Elapsed += new ElapsedEventHandler(_timer_Elapsed);
            _timer.Start();

        }

        private int GetPollingInterval()
        {
            string pollingIntervalValue = ConfigurationManager.AppSettings["PollingInterval"];
            int pollingInterval = Convert.ToInt32(pollingIntervalValue);
            return pollingInterval;

        }

        private void StartWatchingNewSubmits(List<Submit> submits)
        {
            int millisecondsToWait = GetTimeOut();

            //start new submits
            foreach (Submit s in submits)
            {
                if (!_runningSubmitsHT.ContainsKey(s.Id.ToString()))
                {
                    //create a new thread
                    ParameterizedThreadStart threadStart = new ParameterizedThreadStart(this.BuildSolution);
                    Thread t = new Thread(threadStart);

                    ValidationProcess process = new ValidationProcess(s, DateTime.Now);
                    process.SetThread(t);

                    _runningSubmitsHT.Add(s.Id.ToString(), process);
                    t.Start(process);
                }
            }
        }

        /// <summary>
        /// get the timeout from the config
        /// </summary>
        /// <returns></returns>
        private int GetTimeOut()
        {
            int millisecondsToWait = int.Parse(ConfigurationManager.AppSettings["ProcessingTimeOut"]);
            return millisecondsToWait;
        }

        private void TerminateOldSubmits()
        {
            int timeOut = GetTimeOut();

            List<string> keysToDelete = new List<string>();

            //see if any thread has timed out
            foreach (string key in _runningSubmitsHT.Keys)
            {
                Thread t = ((ValidationProcess)_runningSubmitsHT[key]).Thread;
                ValidationProcess validationProcess = null;

                validationProcess = (ValidationProcess)_runningSubmitsHT[key];
                
                bool terminate = validationProcess.IsReady();
               
                if(!terminate)
                {
                    terminate = validationProcess.CheckForTimeOut(DateTime.Now, timeOut);
                    if(terminate)
                    {
                        validationProcess.SaveStatusToDatabase();
                    }
                }

                if(terminate)
                {
                    //remind wich key to delete. this can't be done inside the enumeration
                    keysToDelete.Add(key);

                    //kill the thread 
                    t.Abort();

                    //terminate running processes
                    if (validationProcess.Validator != null)
                    {
                        validationProcess.Validator.Terminate();
                    }
                }
            }

            //remove this outside the foreach loop
            foreach (string key in keysToDelete)
            {
                //remove the submit
                if (_runningSubmitsHT.ContainsKey(key))
                {
                    _runningSubmitsHT.Remove(key);
                }
            }

        }

        public void BuildSolution(object vp)
        {
            ValidationProcess validationProcess = (ValidationProcess)vp;
            try
            {
                ProcessTeamSubmit(validationProcess, _systemSettings);
            }
            catch (ThreadAbortException)
            {
                Submit submit = validationProcess.Submit;
                Log("Timeout for " + submit.Team.Name + " on " + submit.TournamentAssignment.Assignment.Name);
            }
            catch (Exception ex)
            {
                Submit submit = validationProcess.Submit;
                Log(string.Format("ERROR DURING BUILD FOR: {0}-{1}:{2}: ", submit.Team.Name, submit.TournamentAssignment.Assignment.Name, ex.Message + " " + ex.GetType().ToString()));
            }
        }

        private void TraceStatus()
        {
            Console.WriteLine(DateTime.Now.ToLongTimeString() + "  submits: " + _runningSubmitsHT.Count.ToString());
        }

        private static void Log(string message)
        {
            Console.WriteLine(DateTime.Now.ToLongTimeString() + " " + message);
        }

        private static void ProcessTeamSubmit(ValidationProcess validationProcess, SystemSettings sysSettings)
        {
            validationProcess.PrepareProcessing(sysSettings);
            validationProcess.Process(sysSettings);
            validationProcess.FinishProcessing();
        }
    }
}
