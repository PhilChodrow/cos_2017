# Computing in Optimization and Statistics

Course materials for "Computing in Optimization and Statistics", an MIT IAP 2017 course covering essential software skills for research in operations research.

Before the first class, please complete the following tasks.

## Task 1: Make a Github Account

* We will be using Github to distribute code. Please go to www.github.com and make a free account. 

## Task 2: Download `R` and RStudio

We will be learning the `R` programming language for statistical computation. To interact with `R`, we will use RStudio to write and execute `R` commands. 

* **Install `R`**: Navigate to https://cran.cnr.berkeley.edu/ and follow the instructions for your operating system. 
* **Download RStudio**: Navigate to https://www.rstudio.com/products/rstudio/download/ and download RStudio Desktop with an Open Source License. 
* **Test Your Installation**: Open RStudio and type 1+2 into the Console window, and type "Enter."
* Later in the class we will require the most recent version of R (>= 3.3.1). If you already had R installed on your computer, you may have an earlier version. To check and update the R version, you can either follow the **Install `R`** instructions above or follow the steps in pre-lecture-assignment-1.R.

## Task 3 (Windows Users Only): Download Putty

* We will be learning how to interact with computers through a "terminal". Windows users should navigate to http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html, and download the "putty.exe" program found on that page
* Under "Host Name", type athena.dialup.mit.edu, and click "Open"
* When prompted, type in your MIT id username and password.
* Verify you see the text "Welcome to athena.dialup.mit.edu".

### (Windows 10 Users Only) Download Compatability software
* https://github.com/tuiSSE/win-sshfs
* Click on the Download link at the bottom of the page
* Download FiSSH_Package.zip
* Open up the zip file, and extract DokanInstaller by right-clicking on the DokanInstaller icon and clicking “Extract”
* Right-click on DokanInstaller, click on Compatability, and set Compatability mode to “Windows 7”
* Double click on DokanInstall_0.6.0 to install it.
* Go through the rest of the instructions


## Task 4 (Windows Users Only): Download win-sshfs

* Windows users will be utilizing the MIT athena clusters for some of the class material. win-sshfs lets Windows users access files on the MIT athena clusters from their own computers. To download, go to https://code.google.com/p/win-sshfs/downloads/list, and download the "win-sshfs-0.0.1.5-setup.exe" file. Go through the installation steps. 
* After going through the installation steps, verify that you can "mount the athena as a local drive". To do this, click the "+ Add" button. 
** Next to "Drive Name: ", type: <your mit id>@'athena.dialup.mit.edu'
   where <your mit id> is replaced by your MIT log-in id. 
** Next to "Host: ", type: athena.dialup.mit.edu
** Next to "Port: ", leave the default number.
** Next to "Username: ", type: <your mit id>
** Next to "Authentication method", select "Password"
** Next to "Password", type your MIT log-in password.
* Click "Save", and then click "Mount". Open Windows Exporer, and verify that there is a new folder called <your mit id>@'athena.dialup.mit.edu'. Click on it, and there will be some folders in it.

No results need to be submitted on Stellar for this pre-assignment.
