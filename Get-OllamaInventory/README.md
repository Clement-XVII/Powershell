

# 📦 Get‑OllamaInventory.ps1  



**A PowerShell utility that scans a list of Ollama servers, builds a compact table + a detailed listing of every model installed on each host, and (optionally) exports the data to CSV.**  



---  



## Table of Contents

1. [What it does](#what-it-does)  

2. [Prerequisites](#prerequisites)  

3. [Installation / Download](#installation--download)  

4. [Usage](#usage)  

5. [Parameters](#parameters)  

6. [Example output (table + detail)](#example-output-table--detail)  

7. [CSV export & file‑lock handling](#csv-export--file‑lock-handling)  




---  



## What it does

- **Collects** the list of models (`/api/tags`) from every Ollama server you provide.  

- **Displays** a one‑line **summary table** (Server | OK? | #Models | Largest Model | Size (B) | Models).  

- **Prints** a **human‑readable detailed view** for each server (largest model highlighted, all models listed).  

- **Exports** the data to a CSV file, with a built‑in mechanism that removes or waits for a locked file so the script never crashes because the CSV is open in Excel.  



---  



## Prerequisites

| Requirement | Minimum version |

|-------------|-----------------|

| PowerShell | **7.0** (parallel processing) – works on Windows PowerShell 5.1 as well (without `-Parallel`). |

| Network access | Ability to reach each Ollama server on port **11434** (default). |

| `Invoke‑RestMethod` | Built‑in, no extra modules required. |



---  



## Installation / Download  



```powershell

# 1️⃣ Clone the repository (or just download the .ps1 file)

git clone https://github.com/your‑username/ollama‑inventory.git

cd ollama‑inventory



# 2️⃣ (Optional) Unblock the script if you downloaded it from the web

Unblock-File -Path .Get-OllamaInventory.ps1

```



> **Tip** – If you only need the script, you can download it directly:  

> <https://raw.githubusercontent.com/your‑username/ollama‑inventory/main/Get-OllamaInventory.ps1>



---  



## Usage  



```powershell

.Get-OllamaInventory.ps1 `

&nbsp;   -IpListPath  'C:pathtoservers.txt' `

&nbsp;   -OutputCsv   'C:pathtoOllama_Inventory.csv' `

&nbsp;   -ExpandAllModels   # (optional) one CSV row per model

```



### Minimal call (just console output)



```powershell

.Get-OllamaInventory.ps1 -IpListPath .servers.txt

```



### Full call (table + detail + CSV)



```powershell

.Get-OllamaInventory.ps1 `

&nbsp;   -IpListPath  '.servers.txt' `

&nbsp;   -OutputCsv   '.Ollama_Inventory_$(Get-Date -Format "yyyyMMdd_HHmmss").csv'

```



---  



## Parameters  



| Parameter | Type | Description | Example |

|-----------|------|-------------|---------|

| **`-IpListPath`** | `string` | Path to a plain‑text file that contains one server IP or hostname per line. Blank lines and lines starting with `#` are ignored. | `'C:servers.txt'` |

| **`-TimeoutSec`** | `int` | Seconds to wait for each HTTP request before timing out. | `10` (default) |

| **`-OutputCsv`** | `string` | Full path of the CSV file to create. If omitted, no CSV is written. | `'C:OllamaReport.csv'` |

| **`-ExpandAllModels`** | `[switch]` | When set, the CSV contains **one row per model** (full detail). Without it, the CSV is **one row per server** (compact). | `-ExpandAllModels` |

| **`-ExpandAllModels`** | `[switch]` | Export a detailed CSV (one row per model) instead of the compact one‑row‑per‑server format. | `-ExpandAllModels` |



---  



## Example output (table + detail)  



### 1️⃣ Summary table (exactly the format you asked for)



```

=== Tableau récapitulatif ===



Server         OK? #Models Largest Model                Size (B) Models

------         --- ------- -------------                -------- ------

86.148.18.162  ✔        14 llama4:latest               67436859900 minimax-m2:cloud, qwen3-vl:235b-cloud, qwen3:4b, …

82.24.85.22    ✔         2 llama3:70b                  39969745349 smollm2:135m, llama3:70b

…

```



### 2️⃣ Detailed view (printed right after the table)



```

=== Détail de chaque serveur ===



Server: 86.148.18.162   OK? ✔   #Models: 14

&nbsp; → Plus gros modèle : llama4:latest  (67436859900 B)

&nbsp; → Tous les modèles installés :

&nbsp;     • minimax-m2:cloud  (0 B)

&nbsp;     • qwen3-vl:235b-cloud  (0 B)

&nbsp;     • qwen3:4b  (0 B)

&nbsp;     • gemma3:4b  (0 B)

&nbsp;     • llava:latest  (0 B)

&nbsp;     • …

```



> The **green check** (`✔`) means the server answered, a **red cross** (`✖`) indicates a failure (timeout, connection refused, etc.).  



---  



## CSV export & file‑lock handling  



### What happens if the CSV is already open?  



The script tries to **remove the existing file** before writing. If the file is locked (e.g., opened in Excel) it:



1. Shows a warning, waits **5 seconds**, then retries the delete.  

2. If it still can’t delete the file, it aborts the export and prints an error message – the console output (table + detail) is **still displayed**.



### Example of a successful CSV export  



```powershell

.Get-OllamaInventory.ps1 -IpListPath .servers.txt -OutputCsv .Ollama_Inventory.csv

```



```text

CSV exporté avec succès → C:pathtoOllama_Inventory.csv

```



### CSV format (compact)



| Server | OK? | ModelCount | LargestModel | LargestSize | Models |

|--------|-----|------------|--------------|------------|--------|

| 86.148.18.162 | True | 14 | llama4:latest | 67436859900 | minimax-m2:cloud, qwen3-vl:235b-cloud, … |



### CSV format (expanded, one row per model)



| Server | OK? | ModelName | ModelSize |

|--------|-----|-----------|-----------|

| 86.148.18.162 | True | minimax-m2:cloud | 0 |

| 86.148.18.162 | True | qwen3-vl:235b-cloud | 0 |

| … | … | … | … |



---  



### 🎉 Ready to go!  



```powershell

# Quick start

.Get-OllamaInventory.ps1 -IpListPath .servers.txt -OutputCsv .Ollama_Inventory_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv

```



Happy scanning! 🚀



