# Code-deploy-AWS-EC2

## Intro
This repository is the automated code for AWS Cloud deployment and performance measurement of AuditChain, a private blockchain system.

## About AuditChain: Permissioned Blockchain Platform 
AuditChain is a private blockchain system using PBFT-like consensus with linear communication complexity, assuming a partially synchronous network. While the traditional PBFT consensus algorithm is monolithic, block generation steps are separated from the consensus layer in AuditChain.

<p align="center">
  <img alt="Example preview image" src="./img/auditchain_archi.png" width="458">
</p>

As shown in Figure 1, AuditChain has two types of nodes: A Block Service Provider (BSP) and consensus nodes called auditors. BSP is responsible for creating blocks, while auditors forming a consensus network are responsible for agreement on blocks received from the BSP. 