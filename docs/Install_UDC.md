# Install Sense UDC (User Directory Connector)

## First install the ODBC Text Driver

Download the actual Microsoft Access Runtime.
At the moment this is 2016.

[LINK](https://www.microsoft.com/de-DE/download/details.aspx?id=50040)

## Second install ETL App and generate Files

1. Create a directory there you store the users and the attributes files
2. Create a new Empty app
3. Create a Connection to that directory
4. Create a REST Connection to the REST Datasource
   ![REST1](images/screenshot_sense_udc_restconnection1.png)
   ![REST2](images/screenshot_sense_udc_restconnection2.png)
5. Add the following (modified) script.
   Very important is the yellow marked point. That you save the files
   with a semicolon as the separator. Otherwise you run into problems
   on different cultures, because the comma and point have different
   meanings for example in the english and in the german culture.
   
   You have here two possibilities. One is to create two differenet
   dataconnection one for the userdata and one for the attributes.
   Here you can remove the the gray blocks. The other way is to use
   only one dataconnection and override the url with the apikey with
   the URL setting.
   ![SCRIPT](images/screenshot_sense_udc_script.png)




```SQL
LIB CONNECT TO 'REDMINE_USERDATA_REST';

attributes:
LOAD "ID"
	,"userid"
	,"type"
    ,"value"
	,"group"
; SQL SELECT 
	"ID"
	,"userid"
	,"type"
	,"value"
	,"group"
FROM JSON (wrap on) "root"
	WITH CONNECTION(
    	URL "https://support.qlik2go.net/qswebticket/attributes?key=876324kkjhsadasdASD"
        );

STORE attributes into [lib://REDMINE_USERDATA_DIR/attributes.csv] (txt, delimiter is ';');

users:
LOAD "ID"
	,"userid"
	,"name"
; SQL SELECT 
	 "ID"
	,"userid"
	,"name"
FROM JSON (wrap on) "root"
	WITH CONNECTION(
    	URL "https://support.qlik2go.net/qswebticket/users?key=876324kkjhsadasdASD"
        );

STORE users into [lib://REDMINE_USERDATA_DIR/users.csv] (txt, delimiter is ';');

```

## Third install UDC

Connection String:
```
Driver={Microsoft Access Text Driver (*.txt, *.csv)};Extensions=csv;Dbq=C:\PATH_TO_YOUR_CSVS;
```
![UDC](images/screenshot_sense_udc_connection.png)
