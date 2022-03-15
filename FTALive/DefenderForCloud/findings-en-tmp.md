#### [prev](./Pre-requisites.md) | [home](./welcome.md) 
# Pre-deployment considerations

This is a temporary file and will be deleted soon

## What Defender for Cloud detects
[Azure Security Benchmark](https://docs.microsoft.com/ja-jp/security/benchmark/azure/)  
By default, Defender for Cloud evaluates workloads using Azure security benchmarks, which include security controls categorized into network, identity management, privileged access, logging and threat detection, and other categories. The security baseline consists of a security baseline that describes the individual security controls to be considered for each Azure resource. Some of the security controls listed in the security baseline are mapped to the Azure Policy used by Defender for Cloud.

It is important to note that not all of the recommendations in the security baseline will be satisfied by meeting all of Defender for Cloud's recommendations. For a more secure environment, use the Defender for Cloud recommendations as an automated baseline, but understand the security baselines for each resource individually and implement the necessary security controls.

## Enable Secure Score
What are [security policies, initiatives, and recommendations](https://docs.microsoft.com/ja-jp/azure/defender-for-cloud/security-policy-concept)  
The security posture assessment by Defender for Cloud is enabled by the assignment of the Azure Policy initiative "Azure Security Benchmark". If you do not see a secure score, go to **[Preferences]** in Defender for Cloud, select your current subscription, and from the Policy tab, make sure **[Default Initiative]** is assigned. Once assigned to a management group, Secure Score will be enabled for all subscriptions belonging to the management group. If enabled for the root administrative group, Secure Score will be calculated for all subscriptions in the entire tenant.
Scans by policy are performed periodically, but can be initiated by running Start-AzPolicyComplianceScan in the Cloud Console. Please note that it will take some time for the scan to complete and the results to be displayed.

! [Enable Initiative](. /images/enabledefenderforcloud.png)

## About Subscription Splitting
[Microsoft Defender for Cloud の強化されたセキュリティ機能](https://docs.microsoft.com/ja-jp/azure/defender-for-cloud/enhanced-security-features-overview#can-i-enable-microsoft-defender-for-servers-on-a-subset-of-servers-in-my-subscription)  
The enhanced security features of Microsoft defender for Cloud are enabled for each resource present in the subscription. Subscriptions should be split if you want to use Defender for Cloud for protection and do not want to use Defender for Cloud for other client VMs.

>Citation.
>Can I enable Microsoft Defender for servers for a subset of servers in my subscription?
>
>No. If you enable Microsoft Defender for servers in your subscription, all machines in your subscription will be protected by Defender for servers.
>Another option is to enable Microsoft Defender for servers at the Log Analytics workspace level. In this case, only servers reporting to that workspace will be protected and charged. However, some features will not be available. Examples include Just-in-Time VM access, network discovery, regulatory compliance, adaptive network security enforcement features, and adaptive application control.

## About workspace configuration
[Microsoft Sentinel Workspace Architecture Best Practices](https://docs.microsoft.com/ja-jp/azure/sentinel/best-practices-workspace-architecture)  
It is recommended that as few Log Analytics workspaces as possible be used for security monitoring, often one workspace per tenant.
Consider splitting the workspace if there are compliance requirements, such as data storage locations, or if significant costs are incurred in data-to-data communication.
If you wish to separate workspaces by access rights, consider whether you can substitute "resource context" access rights or "table-level Azure RBAC" instead of separate workspaces.  
- [Control access using Azure permissions](https://docs.microsoft.com/ja-jp/azure/azure-monitor/logs/manage-access#manage-access-using-azure- permissions)
- [Azure RBAC at table level](https://docs.microsoft.com/ja-jp/azure/azure-monitor/logs/manage-access#table-level-azure-rbac)


  

## About agent configuration
Defender for Cloud uses the Log Analytics agent to gather information inside VMs, so some recommendations require the Log Analytics agent to be installed. The Azure Monitor agent is not currently supported by Defender for Cloud, although it is being released as a new mechanism for gathering information about
These agents can be installed simultaneously, so you can use the Log Analytics agent for Defender for Cloud functionality and the Azure Monitor agent for collecting performance and event logs in the VMs. The configuration can be made in such a way as to

[Azure Monitor Agent Overview](https://docs.microsoft.com/ja-jp/azure/azure-monitor/agents/agents-overview)
>Citation:
>Log Analytics Agent is used to
>- Collect log and performance data from Azure virtual or hybrid machines hosted outside of Azure.
>- Send data to the Log Analytics workspace to take advantage of features supported by Azure Monitor logs, such as log queries.
>- Use VM insights, which can monitor a machine at large and its dependencies on its processes, other resources and external processes.
>- Use Microsoft Defender for Cloud or Microsoft Sentinel to manage machine security.
>- Use VM insights, which can monitor a machine at large and its dependencies on its processes, other resources and external processes.
>- Monitor specific services or applications using a variety of solutions.
>


### Azure Monitor Agent for Windows Features
||Azure Monitor Agent || Diagnostic Extensions (WAD) || Log Analytics Agent || Dependency Agent
| ---- | ---- | ---- | ---- | ---- |
|Azure<br>Other Cloud (Azure Arc)<br>On-Premise (Azure Arc)|Azure |Azure<br>Other Cloud<br>On-Premise|Azure<br>Other Cloud<br>On-Premise|Azure
|None|None|None|Log Analytics agent required||
|Data Collected |Event Logs<br>Performance|Event Logs<br>ETW Events<br>Performance<br>File Base Logs<br>IIS Logs<br>.NET App Logs<br>Crash Dumps<br>Agent Diagnostic Logs|Event Logs<br> Performance<br>File-based logs<br>IIS logs<br>Analytical information and solutions<br>Other services|Process dependencies<br>Network connection metrics|
|Azure Monitor logs<br>Azure Monitor metric|Azure Storage<br>Azure Monitor metric<br>Event hubs|Azure Monitor logs|Azure Monitor logs (Log Analytics Agent)
|Log Analytics<br>Metrics Explorer|Metrics Explorer|VM insights <br>Log Analytics<br>Azure Automation<br>Microsoft Defender for Cloud<br>Microsoft Sentinel|VM insights<br>Services Map|





# Explanation of recommendations

Posture Management in Microsoft Defender for Cloud can measure the security status of many resources at no cost. Here are some of the most frequently asked questions and findings from actual customer engagements [Findings / Recommendations](https://docs.microsoft.com/ja-jp/azure/security-center/recommendations-reference), focusing on items in the Computing and Networking categories.



## Detection items related to the subscription owner
- MFA must be enabled for accounts with owner access permissions in subscriptions
- Multiple owners must be assigned to a subscription
- Subscriptions require up to 3 owners to be named

Administrative accounts with high privileges are prime attack targets and must be properly protected; Microsoft Defender for Cloud provides [Azure RBAC best practices](https://docs.microsoft.com/ja-jp/ azure/role-based-access-control/best-practices) to verify the subscription owner's account. Assigning multiple owners is recommended as a precaution in case of problems with a particular administrative account, but too many is considered a risk. Also, password-only authentication is not secure, so setting up MFA is recommended.

> [Azure AD security prescriptive value set](https://docs.microsoft.com/ja-jp/azure/active-directory/fundamentals/concept-) even if you don't have a license such as Azure AD Premium fundamentals-security-defaults) can be enabled to use multifactor with mobile apps.
>If you have an Azure AD Premium license, you can use more flexible conditional access (Azure AD Premium P1) or Azure AD Privilege Identity Management (Azure AD Premium P2), which allows temporary privilege escalation. The following is an example of a user-friendly system.


[特権アクセス: 戦略](https://docs.microsoft.com/ja-jp/security/compass/privileged-access-strategy)
![](https://docs.microsoft.com/ja-jp/security/compass/media/overview/end-to-end-approach.png)
Protecting privileged access has traditionally been an important issue, and Microsoft provides comprehensive guidance on privilege management covering on-premise and cloud.








## Computing recommendations

### Azure Defender for Servers must be enabled / Azure Defender for servers must be enabled in the workspace

Microsoft Defender for Cloud's enhanced security provides real-time threat detection and alerting for a variety of workloads. Enhanced Security for Servers has multiple security features in addition to this and correlates with other recommendations. Below are some typical features of Enhanced Security for Servers and related recommendations.
>Microsoft Defender for Cloud for Servers enhanced security can be enabled on a per-subscription and per-workspace basis. Some features are not available when activated on a per workspace basis.

![Azure Defender](./images/sample-defender-dashboard.png)

### Integration with Microsoft Defender for Endpoint
Threat detection for servers integrated with Microsoft Defender for Endpoint. It detects activity on servers and generates alerts. Microsoft Defender for Endpoint is separate from the anti-malware functionality, and there are no functional dependencies. The two systems work separately, though they are not identical.
You can also configure your system to use Microsoft Defender for Endpoint and a third-party anti-malware product. Please note that this will limit your ability to change the configuration of anti-malware features and some features of Microsoft Defender for Endpoint.
[Compatibility with other Microsoft Defender antivirus security products](https://docs.microsoft.com/ja-jp/microsoft-365/security/defender-endpoint/microsoft-defender-antivirus-compatibility?view=o365-worldwide#microsoft-defender-antivirus-and-non-microsoft-antivirusantimalware-solutions)

> Microsoft Defender for Servers is a set of security features provided by Midrosoft Defender for Cloud and does not refer to anti-malware features. VMs have Microsoft Defender antivirus enabled by default for both client and server.



### Just-in-Time VM Access
This feature allows a specific port to be open to a specific IP address for a limited time. It can be used to open ports to a minimal range when you want to perform administrative tasks from a public network. Note, however, that opening a port to a public IP that serves as a gateway to a site may allow communication from an unintended computer on the site's network.

Related recommendations
* The management port of the virtual machine must be closed.
* The virtual machine management port must be protected by Just-In-Time network access control

### Adaptive Application Control
It learns about the processes running on the computer and alerts the user to the startup of processes that are not normally observed. Since server workloads are basically a fixed set of processes that are launched each time depending on the services they provide, the launch of a new process that has not been observed before, such as during a period when system changes are not planned, can indicate unintended changes or security breaches. Such events can be detected.

![Adaptive Application Control](./images/aac.png)

Related recommendations
* Adaptive application control must be enabled on the machine for secure application definition
* Need to update permission list rules in Adaptive Application Control policy

### Adaptive Network Control
This function analyzes network communications and suggests ports to be restricted. While it is a security best practice to minimize the number of open ports, this feature can be used to identify unused ports from actual communications, thereby minimizing the impact on availability.

![Adaptive Network Control](./images/anc.png)

Related recommendations
* Adaptive network enhancement recommendations need to be applied to Internet-connected virtual machines.

### Check file integrity
This function detects file and registry tampering. This feature can be used in a variety of ways, for example, to detect unintentional application changes or site tampering in VMs that provide web services, or to monitor files that are likely to be modified during a security breach, thereby alerting the user to signs of a breach. The following is a list of the most important features of the system.

![File Integrity Monitoring](./images/fileintegrity.png)

Related recommendations
* File integrity monitoring needs to be enabled on the server.


### Vulnerability Scanner
Defender for Cloud uses a vulnerability scanner to show vulnerabilities on detected virtual machines. While vulnerabilities in operating systems and Microsoft products covered by Windows Update are generally addressed on a regular basis, third-party software and services are managed on a document basis or not managed at all, leaving vulnerabilities unaddressed. In some cases, the
Defender for Cloud offers two vulnerability scanners by default, Qualys and the vulnerability scan built into Microsoft Defender for Servers. The Vulnerability Scanner can be used to detect known vulnerabilities in third-party software and services that are not covered by Windows Update.

Related recommendations
* Vulnerability assessment solution must be enabled on the virtual machine
* Virtual machine vulnerabilities need to be repaired.





## vTPM must be enabled on supported virtual machines
In addition to files and processes generated on the OS, there are other types of attack code called rootkits and bootkits that run before the OS boots to avoid detection by security functions.
Windows has a mechanism in place to check the hardware-based boot flow of the OS all the way to boot and maintain code integrity, which is also available for Azure VMs. Secure Boot checks the code signatures of boot components to ensure that only pre-registered trusted binaries are working. vTPM measures the components that boot into the boot and compares them to a successful boot to prove that the boot was successful. Enabling these features can make it more difficult to perpetuate attacks.

Related recommendations
* Secure boot must be enabled on supported Windows virtual machines
* vTPM must be enabled on supported virtual machines
* The state of the guest configuration certificate for the virtual machine must be normal.

> ~~~ This is a recommendation related to the features currently offered in preview. Please note that it is not recommended for use on production workloads as described in multiple [documents](https://docs.microsoft.com/ja-jp/azure/virtual-machines/trusted-launch). ~~
[Ref: Trusted Startup of Azure Virtual Machines](https://docs.microsoft.com/ja-jp/azure/virtual-machines/trusted-launch)


# Detection items related to network
## Virtual machine management ports must be protected with Just-In-Time network access control
This item is detected when a virtual machine management port, such as RDP or SSH, is open to the public Internet. This is rarely the case when a system is designed, but it is possible that a management port is opened for a newly created VM during production, or that a management port is left open for troubleshooting during build time.


>Azure Bastion is a feature that provides management access from within Azure Portal, which is limited to screen transfers only, but does not open the management port to the Internet and does not require a secure connection to Azure Portal. Conditional access and Azure MFA can be applied during access, allowing for more secure management tasks.



## <resource> must use private links
This is an example of an item that requires careful attention when activating recommendations. Some recommendations contribute to securing the environment, but may affect availability and overall architecture.

Private Link is a feature that allows access from private endpoints that create an accessible route to PaaS components in the virtual network. Access from the public Internet can also be prohibited, allowing access restrictions to be enforced more strictly.

While this can secure network access to a resource, it should be thoroughly investigated and verified in advance, since any components that originally require access to the resource via the Internet will be affected by this setting.

[Ref: DNS configuration for Azure private endpoints](https://docs.microsoft.com/ja-jp/azure/private-link/private-endpoint-dns)
[Ref: Using Azure Private Link to connect your network to Azure Monitor](https://docs.microsoft.com/ja-jp/azure/azure-monitor/logs/private-link- security)

## Need to disable public network access to Azure SQL Database
This requires a thorough understanding of the background of the setting.

Azure SQL security best practice is to deny access to Azure SQL from the public Internet and limit access only via private endpoints. Many customer environments use Azure SQL's firewall features to control access.

Azure SQL databases evaluate access to individual databases first, even if access to multiple databases as a whole is denied at the server level. Thus, even if access is denied at the server level, the administrator of each database may configure individual database-level firewalls to allow access from any network. If you have Azure SQL firewalls restricting network access, you should also periodically audit these database-level network accesses to ensure that unwanted network accesses are not allowed.

![Azure SQL Firewall Rule](./images/manage-connectivity-flowchart.png)


## Need to enable Azure DDoS Protection Standard
Please check the actual requirements thoroughly for this recommendation.

Azure DDoS Protection is available in Basic and Standard, and Basic automatically handles datacenter-scale DDoS attacks. For example, a bandwidth-consuming DDoS attack could be in the hundreds of gigabytes to several terabytes per second, but your application may not be able to continue providing service with a much smaller attack. This means that attacks targeting specific customer applications may not be protected by DDoS Protection Basic.

Azure DDoS Protection uses adaptive tuning to automatically analyze traffic to specific services and adjust thresholds, providing better protection for applications. If the nature of your organization or application requires you to anticipate targeted DDoS attacks as a threat, Azure DDoS Protection Standard.
![Azure DDoS Protection](./images/ddosprotection.png)

Azure DDoS Protection Standard [Simulation Testing with BreakingPoint](https://docs.microsoft.com/ja-jp/azure/ddos-protection/test-through- simulations).

[Ref: Testing through Simulation](https://docs.microsoft.com/ja-jp/azure/ddos-protection/test-through-simulations)




## Virtual networks must be protected by Azure Firewall

Some recommendations detect Azure Firewall deficiencies When controlling network access with Azure Firewall, consider the configuration of the network architecture as well to optimize costs and effectively control network access. The following is a brief overview of the

### Hub & spoke model with Azure Firewall

To run virtual machines in Azure, a logical network called a virtual network (Vnet) must be created to which the virtual machines are connected. A virtual network can have multiple subnets. By default, all subnets within the same virtual network are allowed to communicate by default, so if you want to restrict communication between networks, you would configure an NSG for each subnet to restrict network communication. This configuration loses scalability and flexibility because rule maintenance becomes cumbersome as more subnets are added.

Therefore, it is recommended that multiple virtual networks be interconnected and that the boundary of each system be separated in terms of virtual network units for scalability and flexibility. This configuration is called the hub-and-spoke model, since only one Vnet commonly used by multiple systems is placed at the center, and multiple Vnets created for each system are placed from the center Vnet like spokes on a wheel.

Spoke Vnets cannot communicate with each other by default, facilitating segment isolation. In addition, when a new system with a separate security perimeter is added, the spoke Vnets can be connected to the hub, making the configuration easy to expand in the future.

Many environments have requirements for communication from components on Azure to the public Internet. While we typically restrict communication to trusted destinations, especially if there are many server VMs, network-level restrictions based on IP address and port using NSG are not suitable for controlling outbound communication to the public Internet. Azure allows the use of Azure Firewall as a 1st party NVA.

Azure Firewall features vary between Standard and Premium, with Standard offering the most features for network access control, including the ability to restrict communication with the Azure network by IP, port or FQDN, and the ability to control the number of users on the Azure network. Pre-defined tags can be used to limit the use of the system. Threat Intelligence can also be used to detect threats to the target. Premium offers more flexible URL control and TLS inspection, so you can detect threats to the content of HTTPS-encrypted communications.

Azure Firewall communications and security events are logged in Azure Monitor logs, which can be linked to any monitoring solution.

![Hub-Spoke](./images/hubspoke.png)

[Azure Firewall Features](https://docs.microsoft.com/ja-jp/azure/firewall/features)
- FQDN Filtering
- Network traffic filtering
- FQDN Tag
- Service Tags
- Threat Intelligence
- DNAT / SNAT
- Logs by Azure Monitor
- forced tunneling
- Web Category (FQDN-based)


[Azure Firewall Premium Features](https://docs.microsoft.com/ja-jp/azure/firewall/premium-features)

- TLS Inspection
- IDPS
- URL Filtering
- Web category (URL-based)


# Link
[Become a Microsoft Defender for Cloud Ninja](https://techcommunity.microsoft.com/t5/microsoft-defender-for-cloud/become-a-microsoft-defender-for-cloud-ninja/ba-p/1608761)
[Enable enhanced security features of Microsoft Defender for Cloud](https://docs.microsoft.com/ja-jp/azure/defender-for-cloud/enable-enhanced-security) )


