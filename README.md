# Useful-Scripts
This repository contains a collection of scripts designed to automate various tasks using PowerShell, Python, Bash, and other scripting languages. Each script is tailored to streamline specific operations, enhance productivity, and reduce manual effort.

## Scripts Included
<img src="https://img.shields.io/badge/powershell-5391FE?style=for-the-badge&logo=powershell&logoColor=white"/>

1. [Backup Acumatica Artifacts to AWS-S3](./powershell-bat-Scripts/artifacts_backup_to_s3.ps1)
2. [Clean temporary files from local](./powershell-bat-Scripts/clean_temp_files.ps1)
3. [Encrypt web.config files of ASP.NET sites using regiis.exe](./powershell-bat-Scripts/Web.config_encryptor.ps1)
4. [Scripts to create user and add to User Groups (custom and Windows Groups)](./powershell-bat-Scripts/Create%20Users/)

<img src="https://img.shields.io/badge/Python-FFD43B?style=for-the-badge&logo=python&logoColor=blue"/>

1. [Stop instance based on tags](./Python-Scripts/ec2_Instance_Stopper_by_tag.py)
2. [List object from s3 which are 3 days old](./Python-Scripts/list_objects_last_three_days.py)
3. [Export list of processes running in AWS-RDS](./Python-Scripts/rds_processlist_innodb_export.py)
4. [Automate toggle of slow-query-logs parameter of AWS-RDS](./Python-Scripts/rds_slow_query_parameter_toggle.py)


<img src = "https://img.shields.io/badge/Shell_Script-121011?style=for-the-badge&logo=gnu-bash&logoColor=whit"/>

1. [File ecnryption using GNU Privacy Guard](./shell-Scripts/encrypt.sh)
2. [Automated MySQL Schema Backup and Upload to S3 Script](./shell-Scripts/mysql_db_backup.sh)



## Getting Started
To use any of these scripts, follow these steps:
**1. Clone the repository:**
```bash
    git clone https://github.com/N1kh1lS1ngh25/Useful-Scripts.git
``` 
**2.Navigate to the Repo directory:**
```
    cd Useful-Scripts/Python-Scripts

    cd Useful-Scripts/powershell-bat-Scripts/

    cd Useful-Scripts/shell-Scripts
```
 **3. Run the script:**
1. To run PowerShell scripts: 
```
  ./scriptname.ps1
```
2. To run Python Scripts:
```
  python scriptname.py

```
3. To Run Bash Scripts:
```
 ./scriptname.sh

```
<br>

## Contributing
Contributions are welcome! If you have a script that you think would be useful to others, feel free to submit a pull request. Please ensure your scripts are well-documented and follow best practices.

### License
This project is licensed under the MIT License - see the LICENSE file for details.

## Contact
For questions or suggestions, please open an issue or contact .


