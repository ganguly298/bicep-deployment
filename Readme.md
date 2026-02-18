# Secure Multi-Tier Web Application Infrastructure

This repository contains a modular Bicep Infrastructure-as-Code (IaC) project for deploying a secure, multi-tier web application architecture in Azure. 

The design follows the Azure Well-Architected Framework, emphasizing network isolation, identity-based security, and parameter-driven environments.

## Architecture Overview

The infrastructure provisions the following core components into an existing Resource Group:
* **Networking:** A Virtual Network (VNet) with dedicated subnets for the frontend, backend, database, and private endpoints, secured by Network Security Groups (NSGs).
* **Compute:** Two Azure App Services (Frontend Web App and Backend API) running on a shared App Service Plan, utilizing Regional VNet Integration for secure outbound traffic.
* **Database:** Azure Database for PostgreSQL Flexible Server, secured via native VNet delegation and a Private DNS Zone (no public IP).
* **Security:** Azure Key Vault configured with a Private Endpoint and Azure RBAC authorization. Public network access is completely disabled.
* **Monitoring:** Application Insights backed by a Log Analytics Workspace for centralized telemetry.

## Project Structure

```text
/infrastructure
├── main.bicep                  # Orchestrator file
├── parameters/                 
│   ├── dev.bicepparam          # Development environment parameters
│   └── prod.bicepparam         # Production environment parameters
└── modules/                    
    ├── network.bicep           # VNet, Subnets, and NSGs
    ├── compute.bicep           # App Service Plan, Frontend, and Backend Apps
    ├── database.bicep          # PostgreSQL Flexible Server and DNS
    ├── security.bicep          # Key Vault and Private Endpoint
    └── monitoring.bicep        # Log Analytics and App Insights