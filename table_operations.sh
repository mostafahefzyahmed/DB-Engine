#!/bin/bash

DATABASE_DIR="./databases"

# Database Menu
database_menu() {
    local database_name="$1"

    while true; do
        echo -e "\nDatabase Menu:"
        echo "1. Create Table"
        echo "2. List Tables"
        echo "3. Drop Table"
        echo "4. Insert into Table"
        echo "5. Select From Table"
        echo "6. Delete From Table"
        echo "7. Update Table"
        echo "8. Back"

        read -p "Enter option number: " option

        case $option in
            1) read -p "Enter table name: " table_name; create_table "$database_name" "$table_name";;
            2) list_tables "$database_name";;
            3) read -p "Enter table name to drop: " table_name; drop_table "$database_name" "$table_name";;
            4) read -p "Enter table name: " table_name; insert_into_table "$database_name" "$table_name";;
            5) read -p "Enter table name: " table_name; select_from_table "$database_name" "$table_name";;
            6) read -p "Enter table name: " table_name; delete_from_table "$database_name" "$table_name";;
            7) read -p "Enter table name: " table_name; update_table "$database_name" "$table_name";;
            8) break;;
            *) echo "Invalid option.";;
        esac
    done
}

# Create Table
create_table() {
 local path="${DATABASE_DIR}"
    local dbname="$1"
    local invalid="ERROR: "
    local base=""
    local note="Note: "
  
# get table name&check
read -p "Enter table name : " tablename
while [[ -z $tablename || $tablename =~ ^[0-9] || $tablename == *['!''@#/$\"*{^})(+|,;:~`.%&/=-]>[<?']* ]]  
do
echo -e "$invalid Invaild Name $base"
done
# convert every space to _
while [[ $tablename == *" "* ]] ; do
tablename="${tablename/ /_}"    
done
if [ -f $path"/"$dbname"/"$tablename ] ; then
echo -e "${invalid} Table ${tablename} already exists ${base}" 
else
touch $path"/"$dbname"/"$tablename
echo -e "${note} Table ${tablename} created succssfully ${base}"
# create metadata of table
read -p "Enter Num.Of Columns For Table ${tablename} : " numCols
# check if input is valid [number]
#try convert input to integer
while ! [[ $numCols =~ ^[1-9][0-9]*$  ]]
do
echo -e "$invalid Invaild Number $base"
read -p "Enter Num.Of Columns For Table ${tablename} : " numCols
done
# convert numCols to intger [enable us to operate]
let numCols=$numCols
#Database Engine Tables accept at least two columns 
#i don`t need make empty table (file)
while [[ $numCols < 2 ]]
do
    echo -e "$invalid Minimum Number Of Columns Is 2 $base"
    read -p "Enter Num.Of Columns For Table ${tablename} : " numCols
done
# by default first field name:id & constraint:PK
# loop until numCols to get table columns name&type [string&int]
echo -e "${note}Note that first column name is id and it is PK ${base}"
record_name=''
record_type=''
for ((i=2;i<=$numCols;i++))
 do
    read -p "Enter Column ${i} Name : " colName
# start check col name
    while [[ -z $colName || $colName =~ ^[0-9] || $colName == *['!''@#/$\"*{^})(+|,;:~`.%&/=-]>[<?']* ]]  
    do
            echo -e "${invalid} Invaild colName ${base}"
            read -p "Enter Column ${i} Name : " colName
    done
# end check col name
# convert every space to _
    while [[ $colName == *" "* ]] ; do
    colName="${colName/ /_}"    
    done
# end convert
# check if colName found or not 
    while [[ $record_name  == *"${colName}"* ]] ; do
    echo -e "${invalid} Filed ${colName} FOUND ${base}"
    read -p "Enter Column ${i} Name : " colName
    done
 # set 1st col=> id:primary key => if this first loop iteration
# not ? append new column name
    if [ $i -eq 2 ] ; then   #check
            record_name+="id:"$colName
    else
            record_name+=":"$colName
    fi
    # end append col name to record
done
# write columns name in table file
    echo $record_name >> $path"/"$dbname"/"$tablename
#  Get Columns Name Data Types
echo -e "${note} Enter Data Types [string|integer] ${base}"
# get Columns name from table
colNames=`cut -d ':' -f 2-$numCols $path"/"$dbname"/"$tablename`
IFS=':' read -ra colArray <<< $colNames
let c=0
for ((i=2;i<=$numCols;i++))
do
echo "*** Enter data type for [" ${colArray[$c]} "] filed : "
c+=1
# only support string and integer
select choice in "string" "integer" "varchar"
do
case $choice in
"string" ) 
			if [ $i -eq 2 ]
			then 
			record_type=integer:string
            else
			record_type+=:string
	    	fi
		break;;
"integer" )
if [ $i -eq 2 ] ; then
	record_type=integer:integer
	else 
	record_type+=:integer
fi
break ;;		

"varchar" )
if [ $i -eq 2 ] ; then
	record_type=integer:varchar
	else 
	record_type+=:varchar
fi
break;;

* )
		echo -e " ${invalid} Invaild data type ${base}"
		continue;;
esac
# end select
done
# end for
done
echo $record_type >> $path"/"$dbname"/"$tablename
echo -e "${note} Your table [${tablename}] meta data is : \n $record_name \n $record_type ${base}"
fi
}

# List Tables
list_tables() {
local path="${DATABASE_DIR}"
    local dbname="$1"
    local invalid="ERROR: "
    local base=""
    local note="Note: "
    let count=`ls  $path"/"$dbname | wc -l`
if [[ $count  >   0 ]] ; then
echo  -e "${note}**** Your Tables [${count}] ****${base}"
ls -F $path"/"$dbname 
else
echo -e "${invalid} No Tables Found ${base}"
fi
}

# Drop Table
drop_table() {
local path="${DATABASE_DIR}"
    local dbname="$1"
    local invalid="ERROR: "
    local base=""
    local note="Note: "
   read -p  "Enter Table Name To Drop : "  tablename
if [ -f $path"/"$dbname"/"$tablename -a ! -z $tablename ] ; then
echo -e "${invalid}Are you sure to delete ${tablename} [y/n] : ${base}  " 
read ans
    if [ $ans == "y" -o $ans == "Y" ] ; then 
    rm $path"/"$dbname"/"$tablename
    echo -e "${note} Table ${tablename} deleted succssfully. ${base}"
    fi
elif [[ -z $tablename || ! -f $path"/"$dbname"/"$tablename  ]] ; then
    echo -e "${invalid} Table Not Found ${base}"
    
fi
}

# Insert into Table
insert_into_table() {
local path="${DATABASE_DIR}"
    local dbname="$1"
    local invalid="ERROR: "
    local base=""
    local note="Note: "
  
echo  -e "${note} Database ${dbname} Tables ==>"
         ls  ${path}/${dbname}
echo -e "${base}"         
 read -p  "Enter Table Name To Insert data : "  tablename
# check table exists
if [ -f $path"/"$dbname"/"$tablename ] ; then

# get Columns name from table
 colNames=`cut -d ':' -f 1- $path"/"$dbname"/"$tablename`
 IFS=':' read -ra colArray <<< $colNames

# using awk
types=`awk -F":" '{if(NR==2) print $0}'  $path"/"$dbname"/"$tablename `
IFS=':' read -ra typeArray <<< $types
echo "Types" ${typeArray[@]}

# get All Pks in table
pks=(`awk -F":" '{if(NR>2) print $1}' $path"/"$dbname"/"$tablename `)

# define record to store inputs
record=() 
for (( i=0;i<${#colArray[@]};i++))
do
# check PK
if [[ ${colArray[$i]} == "id" ]] ; then
    echo "Enter " ${colArray[$i]} "["${typeArray[$i]}"&Unique] Value "  
    read value
        if [[  ${pks[@]} =~  $value  ]] ; then
        echo -e "${invalid}  ID must be unique :) ${base}"
        
        elif [[  $value -le 0 || ! $value =~ ^[1-9][0-9]*$  ]] ; then
        echo -e "${invalid}  ID must be integer :) ${base}"
        
        else
        record[$i]=$value
        fi
# remaining fields
else
    echo "Enter " ${colArray[$i]} "["${typeArray[$i]}"] Value "  
    read value
# check datatype
# string datatype
if [[ ${typeArray[$i]} = "string" ]] ;  then
    if [[ ! $value == *[a-zA-z0-9]* ]] ; then      
        echo -e "${invalid}" ${colArray[$i]} " must be string :) ${base}"
        
    else
    # convert every space to _
    while [[ $value == *" "* ]] ; do
    value="${value/ /_}"    
    done
    # end convert
            record[$i]=$value
    fi
# Integer
elif [[ ${typeArray[$i]} = "integer" ]] ;  then
    if [[ ! $value =~ ^[0-9]*$ ]] ; then
        echo -e "${invalid}" ${colArray[$i]} " must be integer :) ${base}"
        
    else
            record[$i]=$value
    fi    

# Varchar
elif [[ ${typeArray[$i]} = "varchar" ]] ;  then
    if [[ ! $value =~ ^[a-zA-Z0-9]*$ ]] ; then
        echo -e "${invalid}" ${colArray[$i]} " must be varchar :) ${base}"
        
    else
            record[$i]=$value
    fi    

fi
# end if => loop remaining names
fi
done
# echo "Your record => " ${record[@]}
echo "---------------------"
data=""
for item in ${record[@]} 
do
data+=$item":"
done
# remove last :
    data="${data%?}"
    echo $data >>  $path"/"$dbname"/"$tablename
    echo -e "${note} Inserted Succsfully" $data "${base}" 

# Table not found
else
echo -e "${invalid} Table  ${tablename} Not Found ${base}"

fi
}

# Select From Table
select_from_table() {
local path="${DATABASE_DIR}"
    local dbname="$1"
    local invalid="ERROR: "
    local base=""
    echo  -e "${note} Database ${dbname} Tables ==>"
         ls  ${path}/${dbname}
echo -e "${base}"        
read -p  "Enter Table Name To Select data : "  tablename
# check table exists
if [ -f $path"/"$dbname"/"$tablename ] ; then
    # check if contains record
    count=`cat $path"/"$dbname"/"$tablename | wc -l `
    if [[ $count > 2 ]] ; then
    # Ask to select all or by specific id
echo -e "${note} Select Record[s] : ${base}"
select type in "All" "By Id" "Exit"
do
case $type in 
"All" ) 
awk -F: '{ if(NR==1) print $0  } {if(NR>2) print $0  }  ' $path"/"$dbname"/"$tablename 
;;
"By Id" )
read -p "Enter Record id : " id
if [[  ! $id =~ ^[1-9][0-9]*$  ]] ; then
    echo -e "${invalid}  ID must be integer :) ${base}"
    
else
# # search if first field is = id return entire record
row=`awk -F":" -v id=$id '{if($1==id) print $0}' $path"/"$dbname"/"$tablename`
    if [[ -z $row ]] ; then
            echo -e "${invalid} Record Not Found ${base}"
           
    else
        awk -v id=$id -F":" '{if(NR>2 && $1==id) print $0}' $path"/"$dbname"/"$tablename 
    fi    
fi
;;
"Exit" ) break ;;
* ) echo -e "${invalid} Invalid Option ${base} ";;
esac
done
# if table hasnot data
    else
    echo -e "${invalid} Table ${tablename} dose not contain any records ${base}"
    fi

else
    echo -e "${invalid} Table  ${tablename} Not Found ${base}"
    
fi
}

# Delete From Table
delete_from_table() {
local path="${DATABASE_DIR}"
    local dbname="$1"
    local invalid="ERROR: "
    local base=""
    local note="Note: "
  
echo  -e "${note} Database ${dbname} Tables ==>"
         ls  ${path}/${dbname}
echo -e "${base}"         

read -p  "Enter Table Name To Delete data : "  tablename
# check table exists 
if [ -f $path"/"$dbname"/"$tablename ] ; then
    # check if contains record
    count=`cat $path"/"$dbname"/"$tablename | wc -l ` 
    if [[ $count> 2 ]] ; then
    # Ask to delete all or by specific id
echo -e "${invalid} Delete : ${base}"
select type in "All" "By Id" "Exit"
do
case $type in 
"All" ) 
echo -e "${invalid}Are you sure to delete  all records ${tablename} [y/n] : ${base}  " 
read ans
if [ $ans == "y" -o $ans == "Y" ] ; then 
    sed -i '3,$d' $path"/"$dbname"/"$tablename 
    echo -e "${note} ${tablename} Records deleted succssfully. ${base}"
    
fi
;;
"By Id" )
    read -p "Enter Record id : " id
if [[  ! $id =~ ^[1-9][0-9]*$  ]] ; then
    echo -e "${invalid}  ID must be integer :) ${base}"
   
else
# delete now
row=`awk -F":" -v id=$id '{if($1==id) print $0}' $path"/"$dbname"/"$tablename`
        if [[ -z $row ]] ; then
            echo -e "${invaild} Record Not Found ${base}"
            
        else
        echo -e "${invalid}Are you sure to delete Record ${row} [y/n] : ${base}  " 
        read ans
        if [ $ans == "y" -o $ans == "Y" ] ; then 
            sed -i '/'${row}'/d' $path"/"$dbname"/"$tablename
            echo -e "${note} Record deleted from ${tablename}  succssfully. ${base}"
        fi
          
        fi

fi
;;
"Exit" ) break 
     ;;
* ) 
echo -e "${invalid} Invalid Option ${base} "

;;
esac
done
    # table is empty
    else
    echo -e "${invalid} Table ${tablename} dose not contain any records ${base}"
    
fi
# table not exit
else
    echo -e "${invalid} Table  ${tablename} Not Found ${base}"
    
fi
}

# Update Table
update_table() {
local path="${DATABASE_DIR}"
    local dbname="$1"
    local invalid="ERROR: "
    local base=""
    local note="Note: "
echo  -e "${note} Database ${dbname} Tables ==>"
         ls  ${path}/${dbname}
echo -e "${base}"         
read -p  "Enter Table Name To Update data : "  tablename
# check table exists
 if [ -f $path"/"$dbname"/"$tablename ] ; then
    # check if contains record
    count=`cat $path"/"$dbname"/"$tablename | wc -l `
    if [[ $count  > 2 ]] ; then   

# get Columns name from table
colNames=`cut -d ':' -f 2- $path"/"$dbname"/"$tablename`
IFS=':' read -ra colArray <<< $colNames

# get Columns data types from table [second record]
typeArray=`head -2 $path"/"$dbname"/"$tablename | tail -1 | cut -d ':' -f 2- `
IFS=':' read -ra dataType <<< $typeArray


read -p "Enter Record Id : " id

if [[  ! $id =~ ^[1-9][0-9]*$  ]] ; then
    echo -e "${invalid}  ID must be integer :) ${base}"
   
else
# # search if first field is = id return entire record
current=`awk -v id=$id -F":" '{if(NR>2 && $1==id) print $0}' $path"/"$dbname"/"$tablename `

        if [[ ! -z $current ]] ; then
        record=()
# loop for fileds&datatype
for (( i=0;i<${#colArray[@]};i++))
do
echo "Enter New Value Of " ${colArray[$i]}  "["${dataType[$i]}"]" 
read value
        # check data type
        if [[ ${dataType[$i]} = "string" ]] ;  then
            if [[ ! $value == *[a-zA-z0-9]* ]] ; then      
                echo -e "${invalid}" ${colArray[$i]} " must be string :) ${base}"
                
            else
            # convert every space to _
            while [[ $value == *" "* ]] ; do
            value="${value/ /_}"    
            done
            # end convert
                    record[$i]=$value
            fi
        # Integer
        elif [[ ${dataType[$i]} = "integer" ]] ;  then
            if [[ ! $value =~ ^[0-9]*$ ]] ; then
                echo -e "${invalid}" ${colArray[$i]} " must be integer :) ${base}"
                
            else
                    record[$i]=$value
            fi  
        # Varchar
        elif [[ ${dataType[$i]} = "varchar" ]] ;  then
            if [[ ! $value =~ ^[a-zA-Z0-9]*$  ]] ; then
                echo -e "${invalid}" ${colArray[$i]} " must be varchar :) ${base}"
                
            else
                    record[$i]=$value
            fi        
        fi
        # end if => loop remaining names
done
# end loop
    data=""
    for item in ${record[@]} 
    do
    data+=$item":"
    done
    data=$id":"$data
    updateRecord="${data%?}"
    
    sed -i "/^$id/s/$current/$updateRecord/" $path"/"$dbname"/"$tablename
    else
     echo -e "${invalid} Record Not Found ${base}"
        
    fi
fi
    echo -e "${note} Record Update Succssfully.  ${base}"
      
# table is empty
    else
    echo -e "${invalid} Table ${tablename} dose not contain any records ${base}"
    
    fi
# table not exit
else
    echo -e "${invalid} Table  ${tablename} Not Found ${base}"
    
fi
}
