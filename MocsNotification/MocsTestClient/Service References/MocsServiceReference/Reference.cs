﻿//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by a tool.
//     Runtime Version:4.0.30128.1
//
//     Changes to this file may cause incorrect behavior and will be lost if
//     the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace MocsTestClient.MocsServiceReference {
    using System.Runtime.Serialization;
    
    
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.Runtime.Serialization", "4.0.0.0")]
    [System.Runtime.Serialization.DataContractAttribute(Name="MessageType", Namespace="http://schemas.datacontract.org/2004/07/MocsServiceHost")]
    public enum MessageType : int {
        
        [System.Runtime.Serialization.EnumMemberAttribute()]
        Chat = 0,
        
        [System.Runtime.Serialization.EnumMemberAttribute()]
        Info = 1,
        
        [System.Runtime.Serialization.EnumMemberAttribute()]
        Warning = 2,
        
        [System.Runtime.Serialization.EnumMemberAttribute()]
        Error = 3,
    }
    
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.ServiceModel", "4.0.0.0")]
    [System.ServiceModel.ServiceContractAttribute(ConfigurationName="MocsServiceReference.INotify")]
    public interface INotify {
        
        [System.ServiceModel.OperationContractAttribute(IsOneWay=true, Action="http://tempuri.org/INotify/NotifyAll")]
        void NotifyAll(MocsTestClient.MocsServiceReference.MessageType messageType, System.DateTime dateTime, string teamId, string category, string text);
    }
    
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.ServiceModel", "4.0.0.0")]
    public interface INotifyChannel : MocsTestClient.MocsServiceReference.INotify, System.ServiceModel.IClientChannel {
    }
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.ServiceModel", "4.0.0.0")]
    public partial class NotifyClient : System.ServiceModel.ClientBase<MocsTestClient.MocsServiceReference.INotify>, MocsTestClient.MocsServiceReference.INotify {
        
        public NotifyClient() {
        }
        
        public NotifyClient(string endpointConfigurationName) : 
                base(endpointConfigurationName) {
        }
        
        public NotifyClient(string endpointConfigurationName, string remoteAddress) : 
                base(endpointConfigurationName, remoteAddress) {
        }
        
        public NotifyClient(string endpointConfigurationName, System.ServiceModel.EndpointAddress remoteAddress) : 
                base(endpointConfigurationName, remoteAddress) {
        }
        
        public NotifyClient(System.ServiceModel.Channels.Binding binding, System.ServiceModel.EndpointAddress remoteAddress) : 
                base(binding, remoteAddress) {
        }
        
        public void NotifyAll(MocsTestClient.MocsServiceReference.MessageType messageType, System.DateTime dateTime, string teamId, string category, string text) {
            base.Channel.NotifyAll(messageType, dateTime, teamId, category, text);
        }
    }
}
