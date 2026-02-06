# On-prem-RAC-Migrating-to-Azure-Vm
migration process of on premisis RAC to Azure Vm 


PRE-REQUISITES

**LICENSES**

 Oracle Enterprise Edition 
(EE) license
 Active Data Guard license
 GoldenGate license


 
**IN RAC** 

Oracle RAC is stable and healthy
ARCHIVELOG mode enabled
DBA access available
Space for export and replication
GoldenGate installed or installable

**IN AZURE VM**
Azure subscription ready----------
Two Azure VMs:
Primary DB VM
Standby DB VM (for ADG)
Oracle Linux installed
Separate managed disks 
attached for database storage

**retain and retire strategy**

Retain: Preserve critical data such as financial 
records, audit logs, compliance-related history, 
and business-critical schemas for validation, 
reporting, and rollback during the post-migration 
period. 
---------------Retire: Decommission non-critical, duplicate data 
such as old test schemas, temporary tables, 
outdated logs, and unused historical backups that 
no longer provide business or compliance value.

**Architecture Explanation--------------**

 
1. This architecture is selected to migrate a mission-critical Oracle RAC database from on-premises to Azure with minimal downtime, 
high availability, and low risk. It preserves existing database behavior while ensuring business continuity during and after migration.
2.High availability and disaster recovery are achieved using Oracle Active Data Guard, which maintains a synchronized standby 
database in Azure. In case of failure, the standby can be promoted quickly to ensure service continuity.
3. Key trade-offs and assumptions: The architecture assumes stable, low-latency network connectivity through ExpressRoute 
and availability of skilled Oracle DBA support. Higher operational complexity and licensing costs are accepted in exchange for stability 
and near-zero downtime.
4. Oracle-specific considerations:Oracle Enterprise Edition is mandatory to support GoldenGate and Active Data Guard. Storage 
layout, redo logging, backup, and licensing must strictly follow Oracle best practices to remain compliant and supported.
5. Risks and mitigation strategies:Replication lag or failure risks are mitigated through continuous monitoring and validation. 
Rollback is ensured by retaining the on-premises RAC environment until the Azure setup is fully stable

 
 **Migration Strategy Analysis**-**-----------------------


Migration Strategy: We migrate mission-critical Oracle RAC workloads from on-prem to Azure using GoldenGate for near-zero-downtime 
replication and Active Data Guard for high availability and disaster recovery.This approach supports continuous business operations, strict 
availability requirements, and data consistency during migration.It minimizes risk by avoiding application changes while meeting enterprise 
performance, reliability, and compliance expectations.


REHOST: Not used because RAC cannot be lifted directly into Azure as-is.
Azure does not natively support Oracle RAC shared storage.

REPLATFORM: Used because RAC is converted to single-instance Oracle on Azure VM with GoldenGate and ADG.
This keeps Oracle while adapting it to Azure infrastructure safely.

REPLACE: Not used because replacing Oracle with SaaS or another database impacts functionality.
Such changes are not acceptable for this mission-critical workload.

REFACTOR: Not used because application code changes increase risk and timeline.
The business requires the same application behavior after migration


**Tools & Accelerators**

1. Terraform and Github actions or Azure Devops reduce manual effort and human error by automating infrastructure 
creation and repeatable deployment steps.
2. Using Terraform we can create resources like Resource group, VNET, VM, NSG etc
3. Using pipelines we can automate IAC using Terraform and creation of oracle DB in VM ,GoldenGate Setup.
4. Used during the provisioning and deployment phase, before and during database and GoldenGate setup
5.Cloud engineers and DB platform teams use these tools to standardize and control environment.
6. They automate setup but do not replace runtime monitoring or DBA validation, which must still be done manually.

 
 **Homogeneous vs Heterogeneous Migration Comparison**
Oracle → Oracle (Homogeneous migration) keeps the same database platform, so schemas, SQL/PLSQL, tools, and DBA skills 
remain unchanged. This results in low risk, minimal downtime, easy rollback, and predictable behavior, making it ideal for 
mission-critical and regulated workloads, though Oracle licensing continues.
Oracle → Non-Oracle (Heterogeneous migration) requires schema and code changes, new tools, and team retraining. It reduces 
licensing cost but introduces higher risk, longer testing, complex rollback, and greater effort, making it unsuitable for time-critical 
migrations
In this scenario we are using Homogeneous migration the most practical and reliable choice because it ensures near-zero downtime, 
low risk, and business continuity for a legacy Oracle-dependent application. Using GoldenGate and Active Data Guard enables a 
faster, vendor-supported migration to Azure with minimal change.--------------

 
