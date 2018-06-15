Before installation, you need to:
	* download the SAG Installer as SoftwareAGInstaller.jar
	* create the SAG Install Image as is_rhel_x86-64.zip
	* place the IS License file in islicense.xml

To create the SAG Install Image:
	* Edit is_designer_image.script, inserting correct Empower User and Password
	* Run the command:
		java -jar SoftwareAGInstaller.jar -readImageScript is_designer_image.script is_rhel_x86-64.zip

