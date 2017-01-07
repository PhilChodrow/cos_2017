#### These are instructions to update R to the latest version if R
#### was already installed on your computer.  If you are new and 
#### have just installed R, then you can skip to the end of this pre-assignment.  

#### To run each line, copy and paste into the console

# Get R version with:
version
# It is listed under version.string.  Package 'tm' used later requires
# version >= 3.3.1. 

# If your version is out-of-date, then you can update it within RStudio
# by running the following chunks of code if you have Mac or Windows:

# For Mac: (replace 'Admin user password' with the password used to
# login to your computer)
install.packages("devtools")
library(devtools)
install_github('andreacirilloac/updateR')
library(updateR)
updateR(admin_password = 'Admin user password')
# After this, you should obtain the following message:
# everything went smoothly
# open a Terminal session and run 'R' to assert that latest version was installed

# For Windows:
if(!require(installr)) {
  install.packages("installr"); require(installr)}
check.for.updates.R()
install.R()
copy.packages.between.libraries()
# This code also copies the packages from your
# previous R version to package folder for the updated R version

# Follow the installation instructions as they pop up.  
# Afterwards, restart RStudio.

######## If you have the latest version of R already installed, START HERE
# Now, you should be able to install and load the package "tm".
# The final output should be: "Loading required package: NLP"
install.packages("tm")
library(tm)
