#### What is SAP BOPF (Business Object Processing Framework)

​    BOBF  we see standard BO delivered by SAP

![img](https://i.stechies.com/650x377/userfiles/images/BOPF_st.jpg)



###### **Who all uses Business Object Processing Framework?**

Business Object Processing Framework is a well-established framework ad not really a new one. It has been used in multiple modules such as in **SAP Business suite applications**, **SAP ByDesign** and products – for example, in SAP Supplier Lifecycle Management,**Environment, Health and Safety (EH&S)**, Transportation Management (TM), SAP Quality Issue Management, SAP customer Management of Change, to name but a few. BOPF is also used in the development of customer projects, apart from being used in the internal development of SAP.

   Business Object Builder (BO Builder) is an application that allows you to create, change, and enhance business objects and business object enhancements (enhancements) in Business Object Processing Framework (BOPF)。

<!-- 基础语法  -->

**generic ABAP type**

Predefined generic data type. The generic ABAP types are: any, any table, c, clike, csequence, data, decfloat, hashed table, index table, n, numeric, p, simple, sorted table, standard table, table, x, and xsequence.

**interface work area**

Specific type of data object that can act as a cross-program interface between programs and dynpros, and between programs and logical databases. Interface work areas are either table work areas or common areas (obsolete). All programs in a program group access the same data of an interface work area.

**TABLES table_wa.**

This statement is not allowed in classes and declares a data object table_wa as a table work area whose data type is taken from the identically named structured data type table_wa in ABAP Dictionary

Table work areas declared using TABLES are interface work areas and should only be declared in the global declaration part of a program

**Internal tables** − Internal tables are a means of storing data in the fixed format in working memory of ABAP. The data is stored line by line. So it is necessary for the data to be in a fixed format. Generally, they are used to store data in database tables to be used in ABAP programs.

**Structures**−  Structures are basically data objects consisting of various components or fields of any data types. It differs from the tables in a way that it simulates the format of the table and is used to hold one row of data whereas table has multiple rows of data.

**Work-Areas** −  Work area is basically variables used to store a single row of data. It is similar to structure apart from the fact that it can only be used at program level whereas structure can be used at data dictionary level as well.   

​     A work area is also a structure which holds single data at runtime and has pre allocated memory in database.

As Convention the include name start with "CI_" and are available in Various Enhancements accessible using ***SMOD*** and ***CMOD*** Transactions



