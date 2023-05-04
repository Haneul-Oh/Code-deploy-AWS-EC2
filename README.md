# Code-deploy-AWS-EC2

## Intro
This repository is the automated code for AWS Cloud deployment and performance measurement of AuditChain, a private blockchain system.

## About AuditChain: a Private Blockchain Platform 
AuditChain is a private blockchain system using PBFT-like consensus with linear communication complexity, assuming a partially synchronous network. While the traditional PBFT consensus algorithm is monolithic, block generation steps are separated from the consensus layer in AuditChain.

<p align="center">
  <img alt="Example preview image" src="./img/auditchain_archi.png" width="100%">
  <figcaption>Fig 1. AuditChain architecture consists of three components: a client, a BSP, and auditors.</figcaption>
</p>

As shown in Fig 1, AuditChain has two types of nodes: A Block Service Provider (BSP) and consensus nodes called auditors. BSP is responsible for creating blocks, while auditors forming a consensus network are responsible for agreement on blocks received from the BSP. 

<p align="center">
  <img alt="Example preview image" src="./img/auditchain_flow.png" width="100%">
  <figcaption>Fig 2. Message pattern of AuditChain</figcaption>
</p>

The consensus algorithm shown in Fig 2 is like PBFT but with linear O(n) communication complexity. The difference with PBFT is that it is linearized and has an additional node, BSP, as a static block producer.

## Deployment Setup on Amazon EC2
I deployed AuditChain on AWS EC2 as shown in the table below. We also deployed client servers for performance evaluation and evaluated performance according to the workloads below.

<p align="center">
  <img alt="Example preview image" src="./img/setup_tb.png" width="100%">
  <figcaption>Table 1. 2Message pattern of AuditChain</figcaption>
</p>

**Workload**. Performance (throughput, latency) is measured for 1 minute after the first 30 seconds after the test starts. We use the Hyperledger Caliper benchmarking tool to test the performance. In Every test, for a total of 2 minutes, the client submits a SendPayment transaction to BSP. When referring to latency, we mean the time elapsed from the client submits the transaction to the client receives the f+1 commit events from auditors. 

## Two scenarios
We run our experiments on two scenarios: a local-distributed scenario, where every node is deployed in the Seoul region, and a global-distributed scenario, where auditor nodes are distributed across two AWS regions: Seoul (ap-northeast-2), N.Virginia (us-east-1).

<p align="center">
  <img alt="Scenario 1" src="./img/sn1.png" width="45%">
&nbsp; &nbsp; &nbsp; &nbsp;
  <img alt="Scenario 1" src="./img/sn2.png" width="45%">
</p>